<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

class SyncApiController
{

    // GET /api/cuestionario?plaza_id=1
    // La app la llama al conectarse para refrescar el catalogo local
    // de preguntas (Room) antes de que el tecnico entre a una tienda.
    public function obtenerCuestionario(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token invalido o vencido']);
            return;
        }

        $plazaId = (int) ($_GET['plaza_id'] ?? 0);
        $pdo = Database::conexion();

        $stmt = $pdo->prepare('SELECT id, nombre FROM cuestionario WHERE plaza_id = :p AND activo = 1 LIMIT 1');
        $stmt->execute(['p' => $plazaId]);
        $cuestionario = $stmt->fetch();

        if (!$cuestionario) {
            echo json_encode(['cuestionario' => null, 'preguntas' => []]);
            return;
        }

        $stmt = $pdo->prepare('SELECT id, texto, orden FROM pregunta WHERE cuestionario_id = :c AND activo = 1 ORDER BY es_fija ASC, orden ASC');
        $stmt->execute(['c' => $cuestionario['id']]);
        $preguntas = $stmt->fetchAll();

        echo json_encode(['cuestionario' => $cuestionario, 'preguntas' => $preguntas]);
    }

    // POST /api/encuestas
    // Body: { "encuestas": [ { id (uuid), folio, tienda_id, cuestionario_id,
    //         comentario, fecha_creacion_local,
    //         respuestas: [ { id (uuid), pregunta_id, calificacion } ] } ] }
    // calificacion es 1-10 (escala NPS: 1-6 detractor, 7-8 pasivo, 9-10 promotor).
    // INSERT IGNORE por uuid: si el WorkManager reintenta el mismo
    // payload (ej. se corto la conexion a medio subir), no duplica.
    public function subirEncuestas(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token invalido o vencido']);
            return;
        }
        if (!$usuario['es_encuestable']) {
            http_response_code(403);
            echo json_encode(['error' => 'este rol no puede contestar encuestas']);
            return;
        }

        $datos = json_decode(file_get_contents('php://input'), true) ?? [];
        $encuestas = $datos['encuestas'] ?? [];

        foreach ($encuestas as $e) {
            $folio = trim((string) ($e['folio'] ?? ''));
            if ($folio === '' || strlen($folio) > 50) {
                http_response_code(422);
                echo json_encode(['error' => 'cada encuesta requiere un folio de 1 a 50 caracteres']);
                return;
            }
        }

        $pdo = Database::conexion();

        $stmtEncuesta = $pdo->prepare('
            INSERT IGNORE INTO encuesta
                (id, usuario_id, tienda_id, cuestionario_id, folio, comentario, fecha_creacion_local, sincronizado, fecha_sincronizacion)
            VALUES
                (:id, :usuario_id, :tienda_id, :cuestionario_id, :folio, :comentario, :fecha_creacion_local, 1, NOW())
        ');
        $stmtRespuesta = $pdo->prepare('
            INSERT IGNORE INTO respuesta_detalle (id, encuesta_id, pregunta_id, calificacion)
            VALUES (:id, :encuesta_id, :pregunta_id, :calificacion)
        ');
        $stmtExiste = $pdo->prepare('SELECT 1 FROM encuesta WHERE id = :id');

        // Una transaccion POR ENCUESTA (no una sola para todo el lote):
        // si una encuesta del lote trae datos invalidos, que falle solo
        // esa -- las demas del mismo lote no se deben perder por su culpa.
        // Android ya soporta esto bien: solo marca sincronizado=true lo
        // que venga en `sincronizadas`, el resto queda pendiente y el
        // WorkManager lo reintenta despues.
        $sincronizadas = [];
        $fallidas = [];

        foreach ($encuestas as $e) {
            $pdo->beginTransaction();
            try {
                $stmtEncuesta->execute([
                    'id' => $e['id'],
                    'usuario_id' => $usuario['id'],
                    'tienda_id' => $e['tienda_id'],
                    'cuestionario_id' => $e['cuestionario_id'],
                    'folio' => trim($e['folio']),
                    'comentario' => $e['comentario'] ?? null,
                    'fecha_creacion_local' => $e['fecha_creacion_local'],
                ]);

                // INSERT IGNORE no lanza excepcion si la fila no se pudo
                // insertar (FK invalida, NOT NULL, etc.) -- rowCount()=0
                // puede significar "ya existia" (reintento normal, bien)
                // O "genuinamente fallo" (mal). Hay que distinguir: si
                // sigue sin existir despues del intento, fallo de verdad
                // y NO hay que insertar sus respuestas (si no, quedan
                // huerfanas sin encuesta padre -- exactamente el bug que
                // dejo 809 encuestas con respuestas pero sin cabecera).
                if ($stmtEncuesta->rowCount() === 0) {
                    $stmtExiste->execute(['id' => $e['id']]);
                    if (!$stmtExiste->fetch()) {
                        throw new Exception("la encuesta {$e['id']} (folio {$e['folio']}) no se pudo guardar -- revisa tienda_id/cuestionario_id/fecha");
                    }
                }

                foreach ($e['respuestas'] as $r) {
                    $stmtRespuesta->execute([
                        'id' => $r['id'],
                        'encuesta_id' => $e['id'],
                        'pregunta_id' => $r['pregunta_id'],
                        'calificacion' => $r['calificacion'],
                    ]);
                }

                $pdo->commit();
                $sincronizadas[] = $e['id'];
            } catch (Exception $ex) {
                $pdo->rollBack();
                $fallidas[] = ['id' => $e['id'], 'folio' => $e['folio'] ?? null, 'error' => $ex->getMessage()];
            }
        }

        if ($fallidas) {
            // No es un 500 -- puede venir mezclado con exitosas. El
            // detalle de fallidas es para diagnostico/logs, Android solo
            // necesita `sincronizadas` para decidir que marcar localmente.
            error_log('subirEncuestas: ' . count($fallidas) . ' encuesta(s) rechazadas: ' . json_encode($fallidas));
        }

        echo json_encode(['sincronizadas' => $sincronizadas, 'fallidas' => $fallidas]);
    }
}
