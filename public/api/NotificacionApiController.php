<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

class NotificacionApiController
{
    public function encuestasNuevas(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token invalido o vencido']);
            return;
        }
        if ($usuario['rol_nombre'] !== 'ATI') {
            http_response_code(403);
            echo json_encode(['error' => 'solo el rol ATI recibe notificaciones']);
            return;
        }

        $desde = $_GET['desde'] ?? '';
        $fecha = DateTime::createFromFormat('!Y-m-d H:i:s', $desde);
        if (!$fecha || $fecha->format('Y-m-d H:i:s') !== $desde) {
            http_response_code(400);
            echo json_encode(['error' => 'desde debe tener formato YYYY-MM-DD HH:MM:SS']);
            return;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            SELECT DISTINCT
                e.id,
                e.folio,
                e.fecha_creacion_local,
                t.nombre AS tienda,
                t.codigo AS tienda_codigo
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            WHERE t.asesor_ti_usuario_id = :ati
              AND e.fecha_creacion_local > :desde
            ORDER BY e.fecha_creacion_local ASC
        ');
        $stmt->execute(['ati' => $usuario['id'], 'desde' => $desde]);
        $encuestas = $stmt->fetchAll();

        echo json_encode([
            'encuestas' => $encuestas,
            'ultima_fecha' => $encuestas ? end($encuestas)['fecha_creacion_local'] : $desde,
        ]);
    }
}
