<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../src/RateLimit.php';

// Pagina PUBLICA (sin login) para contestar la encuesta de oficina en
// remoto. No usa el layout del panel ni ninguna guarda de Auth: cualquiera
// con el link puede responder. Se protege con rate-limit por IP + honeypot
// + validacion estricta. La version movil de esta misma encuesta va por
// POST /api/encuestas con administracion_id.
class EncuestaPublicaController
{
    private const MAX_ENVIOS = 5;      // por IP; el 6º intento en la ventana se rechaza
    private const VENTANA_SEG = 600;   // en 10 minutos

    public function mostrar(): void
    {
        $pdo = Database::conexion();

        $cuestionario = $pdo->query("
            SELECT id, nombre FROM cuestionario
            WHERE tipo = 'oficina' AND activo = 1 LIMIT 1
        ")->fetch();

        $preguntas = [];
        if ($cuestionario) {
            $stmt = $pdo->prepare('
                SELECT id, texto, orden FROM pregunta
                WHERE cuestionario_id = :c AND activo = 1
                ORDER BY orden ASC, id ASC
            ');
            $stmt->execute(['c' => $cuestionario['id']]);
            $preguntas = $stmt->fetchAll();
        }

        $areas = $pdo->query('
            SELECT id, nombre FROM administracion
            WHERE activo = 1 ORDER BY nombre
        ')->fetchAll();

        $enviada = isset($_GET['ok']);
        $error = $_SESSION['error_encuesta_publica'] ?? null;
        unset($_SESSION['error_encuesta_publica']);
        $disponible = $cuestionario && $preguntas && $areas;

        require __DIR__ . '/../views/encuesta_publica/form.php';
    }

    public function enviar(): void
    {
        $ip = $this->ipCliente();
        $claveLimite = 'enc_oficina_' . $ip;
        if (!RateLimit::permitido($claveLimite, self::MAX_ENVIOS, self::VENTANA_SEG)) {
            http_response_code(429);
            header('Content-Type: text/html; charset=utf-8');
            echo '<!doctype html><meta charset="utf-8"><title>Demasiados envios</title>'
                . '<body style="font-family:system-ui,sans-serif;max-width:32rem;margin:15vh auto;padding:0 1.25rem">'
                . '<h1 style="font-size:1.3rem">Demasiados envios</h1>'
                . '<p>Recibimos varias respuestas desde esta conexion en poco tiempo. '
                . 'Espera unos minutos y vuelve a intentar.</p></body>';
            exit;
        }
        RateLimit::registrarFallo($claveLimite); // aqui "fallo" == "intento contabilizado"

        // Honeypot: un bot llena todos los campos; este va oculto y vacio.
        if (trim((string) ($_POST['website'] ?? '')) !== '') {
            header('Location: ' . BASE_URL . '/encuesta-oficina?ok=1');
            exit;
        }

        $pdo = Database::conexion();

        $cuestionario = $pdo->query("
            SELECT id FROM cuestionario WHERE tipo = 'oficina' AND activo = 1 LIMIT 1
        ")->fetch();
        if (!$cuestionario) {
            $this->rebotar('La encuesta no esta disponible en este momento.');
        }

        $adminId = (int) ($_POST['administracion_id'] ?? 0);
        $stmt = $pdo->prepare('SELECT id FROM administracion WHERE id = :id AND activo = 1');
        $stmt->execute(['id' => $adminId]);
        if (!$stmt->fetch()) {
            $this->rebotar('Selecciona un area valida.');
        }

        $stmt = $pdo->prepare('
            SELECT id FROM pregunta
            WHERE cuestionario_id = :c AND activo = 1
            ORDER BY orden ASC, id ASC
        ');
        $stmt->execute(['c' => $cuestionario['id']]);
        $preguntas = $stmt->fetchAll(PDO::FETCH_COLUMN);
        if (!$preguntas) {
            $this->rebotar('La encuesta no tiene preguntas configuradas.');
        }

        $calificaciones = $_POST['calificacion'] ?? [];
        $respuestas = [];
        foreach ($preguntas as $pid) {
            $valor = $calificaciones[$pid] ?? null;
            if ($valor === null || $valor === '' || !ctype_digit((string) $valor)) {
                $this->rebotar('Responde todas las preguntas antes de enviar.');
            }
            $valor = (int) $valor;
            if ($valor < 1 || $valor > 10) {
                $this->rebotar('Las calificaciones van de 1 a 10.');
            }
            $respuestas[(int) $pid] = $valor;
        }

        $comentario = trim((string) ($_POST['comentario'] ?? ''));
        if ($comentario === '') {
            $comentario = null;
        }

        $folio = 'WEB-' . date('Ymd-His') . '-' . bin2hex(random_bytes(2));
        $encuestaId = $this->uuidV4();

        try {
            $pdo->beginTransaction();

            $stmt = $pdo->prepare('
                INSERT INTO encuesta
                    (id, usuario_id, tienda_id, administracion_id, cuestionario_id, folio,
                     comentario, fecha_creacion_local, sincronizado, fecha_sincronizacion)
                VALUES
                    (:id, NULL, NULL, :adm, :cue, :folio, :com, NOW(), 1, NOW())
            ');
            $stmt->execute([
                'id' => $encuestaId,
                'adm' => $adminId,
                'cue' => $cuestionario['id'],
                'folio' => $folio,
                'com' => $comentario,
            ]);

            $stmtR = $pdo->prepare('
                INSERT INTO respuesta_detalle (id, encuesta_id, pregunta_id, calificacion)
                VALUES (:id, :enc, :preg, :cal)
            ');
            foreach ($respuestas as $preguntaId => $cal) {
                $stmtR->execute([
                    'id' => $this->uuidV4(),
                    'enc' => $encuestaId,
                    'preg' => $preguntaId,
                    'cal' => $cal,
                ]);
            }

            $pdo->commit();
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            error_log('[encuesta-oficina/enviar] ' . $e->getMessage());
            $this->rebotar('No pudimos guardar tu respuesta. Intenta de nuevo.');
        }

        header('Location: ' . BASE_URL . '/encuesta-oficina?ok=1');
        exit;
    }

    private function rebotar(string $mensaje): void
    {
        $_SESSION['error_encuesta_publica'] = $mensaje;
        header('Location: ' . BASE_URL . '/encuesta-oficina');
        exit;
    }

    private function ipCliente(): string
    {
        $fwd = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? '';
        if ($fwd !== '') {
            $primera = trim(explode(',', $fwd)[0]);
            if ($primera !== '') {
                return $primera;
            }
        }
        return $_SERVER['REMOTE_ADDR'] ?? 'desconocida';
    }

    private function uuidV4(): string
    {
        $b = random_bytes(16);
        $b[6] = chr((ord($b[6]) & 0x0f) | 0x40);
        $b[8] = chr((ord($b[8]) & 0x3f) | 0x80);
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($b), 4));
    }
}
