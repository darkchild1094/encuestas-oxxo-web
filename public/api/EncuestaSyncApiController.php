<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

/**
 * Controlador para sincronización de encuestas con handshaking
 * Maneja confirmación de recepción, reintentos y logging de errores
 */
class EncuestaSyncApiController
{
    /**
     * Endpoint para iniciar handshake al finalizar encuesta
     * POST /api/encuestas/sync/init-handshake
     * Body: { "encuesta_id": "uuid", "detalles": [...] }
     * Responde: { "handshake_id": "uuid", "estado": "en_espera_confirmacion" }
     */
    public function iniciarHandshake(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token inválido o vencido']);
            return;
        }

        $body = json_decode(file_get_contents('php://input'), true);
        if (!$body || !isset($body['encuesta_id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'encuesta_id requerido']);
            return;
        }

        $encuestaId = $body['encuesta_id'];
        $pdo = Database::conexion();

        try {
            // Verificar que la encuesta existe y pertenece al usuario o su tienda
            $stmt = $pdo->prepare('
                SELECT e.id, e.tienda_id, e.usuario_id, t.plaza_id
                FROM encuesta e
                JOIN tienda t ON t.id = e.tienda_id
                WHERE e.id = ?
            ');
            $stmt->execute([$encuestaId]);
            $encuesta = $stmt->fetch();

            if (!$encuesta) {
                http_response_code(404);
                echo json_encode(['error' => 'encuesta no encontrada']);
                return;
            }

            // PFS solo ve sus propias encuestas (las que el mismo capturo);
            // otros roles tienen acceso mas amplio. Un PFS no tiene una
            // tienda fija asignada -- visita varias dentro de su plaza,
            // la tienda se elige por encuesta, no por usuario.
            if ($usuario['rol_nombre'] === 'PFS' && (int) $encuesta['usuario_id'] !== (int) $usuario['id']) {
                http_response_code(403);
                echo json_encode(['error' => 'no tienes permiso para esta encuesta']);
                return;
            }

            // Generar handshake_id único
            $handshakeId = self::generarUUID();

            // Registrar intento inicial
            $stmt = $pdo->prepare('
                INSERT INTO encuesta_sync_log
                (encuesta_id, usuario_id, tienda_id, estado, handshake_id, intento_numero)
                VALUES (?, ?, ?, ?, ?, 1)
            ');
            $stmt->execute([
                $encuestaId,
                $usuario['id'],
                $encuesta['tienda_id'],
                'pendiente',
                $handshakeId
            ]);

            http_response_code(200);
            echo json_encode([
                'handshake_id' => $handshakeId,
                'estado' => 'en_espera_confirmacion',
                'mensaje' => 'Handshake iniciado. Aguardando confirmación del servidor.'
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'error al iniciar handshake: ' . $e->getMessage()]);
        }
    }

    /**
     * Endpoint para confirmar recepción exitosa del servidor
     * POST /api/encuestas/sync/confirm-handshake
     * Body: { "handshake_id": "uuid" }
     * Responde: { "confirmado": true, "encuesta_id": "uuid" }
     */
    public function confirmarHandshake(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token inválido o vencido']);
            return;
        }

        $body = json_decode(file_get_contents('php://input'), true);
        if (!$body || !isset($body['handshake_id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'handshake_id requerido']);
            return;
        }

        $handshakeId = $body['handshake_id'];
        $pdo = Database::conexion();

        try {
            // Buscar el sync log con este handshake_id
            $stmt = $pdo->prepare('
                SELECT id, encuesta_id, estado
                FROM encuesta_sync_log
                WHERE handshake_id = ?
                LIMIT 1
            ');
            $stmt->execute([$handshakeId]);
            $log = $stmt->fetch();

            if (!$log) {
                http_response_code(404);
                echo json_encode(['error' => 'handshake_id no encontrado']);
                return;
            }

            if ($log['estado'] === 'exito') {
                // Ya fue confirmado
                http_response_code(200);
                echo json_encode([
                    'confirmado' => true,
                    'encuesta_id' => $log['encuesta_id'],
                    'mensaje' => 'Confirmación ya registrada previamente'
                ]);
                return;
            }

            // Actualizar estado a exito y marcar confirmado
            $stmt = $pdo->prepare('
                UPDATE encuesta_sync_log
                SET estado = ?, confirmado_servidor = 1, fecha_confirmacion = NOW()
                WHERE handshake_id = ?
            ');
            $stmt->execute(['exito', $handshakeId]);

            // Actualizar encuesta como sincronizada
            $stmt = $pdo->prepare('
                UPDATE encuesta
                SET sincronizado = 1, fecha_sincronizacion = NOW()
                WHERE id = ?
            ');
            $stmt->execute([$log['encuesta_id']]);

            http_response_code(200);
            echo json_encode([
                'confirmado' => true,
                'encuesta_id' => $log['encuesta_id'],
                'mensaje' => 'Handshake confirmado exitosamente'
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'error al confirmar: ' . $e->getMessage()]);
        }
    }

    /**
     * Registrar error de envío
     * POST /api/encuestas/sync/registrar-error
     * Body: {
     *   "handshake_id": "uuid",
     *   "codigo_respuesta": 500,
     *   "mensaje_error": "Connection timeout",
     *   "intento_numero": 1
     * }
     */
    public function registrarError(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token inválido o vencido']);
            return;
        }

        $body = json_decode(file_get_contents('php://input'), true);
        if (!$body || !isset($body['handshake_id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'handshake_id requerido']);
            return;
        }

        $handshakeId = $body['handshake_id'];
        $codigoRespuesta = $body['codigo_respuesta'] ?? null;
        $mensajeError = $body['mensaje_error'] ?? 'Error desconocido';
        $intentoNumero = $body['intento_numero'] ?? 1;

        $pdo = Database::conexion();

        try {
            $stmt = $pdo->prepare('
                UPDATE encuesta_sync_log
                SET estado = ?, codigo_respuesta = ?, mensaje_error = ?, intento_numero = ?
                WHERE handshake_id = ?
            ');
            $stmt->execute([
                'error',
                $codigoRespuesta,
                $mensajeError,
                $intentoNumero,
                $handshakeId
            ]);

            http_response_code(200);
            echo json_encode([
                'registrado' => true,
                'mensaje' => 'Error registrado. Reintento disponible.'
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'error al registrar: ' . $e->getMessage()]);
        }
    }

    /**
     * Obtener estado de sincronización de una encuesta
     * GET /api/encuestas/sync/status?encuesta_id=uuid
     * Responde: { "encuesta_id": "uuid", "estado": "exito", "intentos": 2, ... }
     */
    public function obtenerStatus(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token inválido o vencido']);
            return;
        }

        $encuestaId = $_GET['encuesta_id'] ?? null;
        if (!$encuestaId) {
            http_response_code(400);
            echo json_encode(['error' => 'encuesta_id requerido']);
            return;
        }

        $pdo = Database::conexion();

        try {
            // Obtener último intento de sincronización
            $stmt = $pdo->prepare('
                SELECT
                    encuesta_id,
                    estado,
                    intento_numero,
                    codigo_respuesta,
                    mensaje_error,
                    handshake_id,
                    confirmado_servidor,
                    fecha_intento,
                    fecha_confirmacion
                FROM encuesta_sync_log
                WHERE encuesta_id = ?
                ORDER BY fecha_intento DESC
                LIMIT 1
            ');
            $stmt->execute([$encuestaId]);
            $status = $stmt->fetch();

            if (!$status) {
                http_response_code(404);
                echo json_encode(['error' => 'encuesta sin historial de sincronización']);
                return;
            }

            // Verificar permiso de visualización: un PFS solo ve el estado
            // de sus propias encuestas (no tiene tienda fija asignada).
            if ($usuario['rol_nombre'] === 'PFS') {
                $stmt = $pdo->prepare('
                    SELECT usuario_id FROM encuesta WHERE id = ?
                ');
                $stmt->execute([$encuestaId]);
                $enc = $stmt->fetch();
                if (!$enc || (int) $enc['usuario_id'] !== (int) $usuario['id']) {
                    http_response_code(403);
                    echo json_encode(['error' => 'no tienes permiso para ver este estado']);
                    return;
                }
            }

            http_response_code(200);
            // Mismo cuidado que en el resto del API: MySQL regresa
            // TINYINT como "0"/"1" via PDO, y json_encode lo manda
            // literal -- Gson en Android espera boolean, no numero.
            $status['confirmado_servidor'] = (bool) $status['confirmado_servidor'];
            $status['intento_numero'] = (int) $status['intento_numero'];
            $status['codigo_respuesta'] = $status['codigo_respuesta'] !== null ? (int) $status['codigo_respuesta'] : null;
            echo json_encode($status);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'error al obtener status: ' . $e->getMessage()]);
        }
    }

    /**
     * Módulo PFS: Listar encuestas pendientes de envío por tienda
     * GET /api/encuestas/pfs/pendientes
     * Responde lista con estado de cada encuesta
     */
    public function listarPendientesPFS(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token inválido o vencido']);
            return;
        }

        if ($usuario['rol_nombre'] !== 'PFS') {
            http_response_code(403);
            echo json_encode(['error' => 'solo rol PFS puede acceder a este módulo']);
            return;
        }

        $pdo = Database::conexion();

        try {
            // Un PFS ve SUS PROPIAS encuestas pendientes (las que el
            // capturo), sin importar de que tienda sean -- no tiene una
            // tienda fija asignada. Por eso cada fila trae su propia
            // tienda_id/tienda_nombre en vez de un solo tienda_id global.
            $stmt = $pdo->prepare('
                SELECT
                    e.id,
                    e.tienda_id,
                    t.nombre AS tienda_nombre,
                    e.folio,
                    e.fecha_creacion_local,
                    e.comentario,
                    e.sincronizado,
                    esl.estado,
                    esl.intento_numero,
                    esl.mensaje_error,
                    esl.fecha_intento,
                    esl.fecha_confirmacion,
                    COUNT(rd.id) as total_respuestas
                FROM encuesta e
                JOIN tienda t ON t.id = e.tienda_id
                LEFT JOIN encuesta_sync_log esl ON esl.encuesta_id = e.id
                LEFT JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
                WHERE e.usuario_id = ?
                GROUP BY e.id
                ORDER BY e.fecha_creacion_local DESC
            ');
            $stmt->execute([$usuario['id']]);
            $encuestas = $stmt->fetchAll();

            foreach ($encuestas as &$enc) {
                $enc['tienda_id'] = (int) $enc['tienda_id'];
                $enc['sincronizado'] = (bool) $enc['sincronizado'];
                $enc['total_respuestas'] = (int) $enc['total_respuestas'];
                $enc['intento_numero'] = $enc['intento_numero'] !== null ? (int) $enc['intento_numero'] : null;
            }
            unset($enc);

            http_response_code(200);
            echo json_encode([
                'total_encuestas' => count($encuestas),
                'encuestas' => $encuestas
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'error al listar: ' . $e->getMessage()]);
        }
    }

    /**
     * Generar UUID v4
     */
    private static function generarUUID(): string
    {
        return sprintf(
            '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }
}
