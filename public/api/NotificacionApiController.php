<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

class NotificacionApiController
{
    public function obtener(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token invalido o vencido']);
            return;
        }

        $desde = $_GET['desde'] ?? '';
        $fecha = DateTime::createFromFormat('!Y-m-d H:i:s', $desde);
        if (!$fecha || $fecha->format('Y-m-d H:i:s') !== $desde) {
            $desde = date('Y-m-d H:i:s', strtotime('-1 hour'));
        }

        $pdo = Database::conexion();
        $notificaciones = [];

        // 1. Nuevas Encuestas (Solo para ATIs y sus tiendas asignadas)
        if ($usuario['rol_nombre'] === 'ATI') {
            $stmt = $pdo->prepare('
                SELECT COUNT(*) as total, MAX(e.fecha_creacion_local) as ultima
                FROM encuesta e
                JOIN tienda t ON t.id = e.tienda_id
                WHERE t.asesor_ti_usuario_id = :ati
                  AND e.fecha_creacion_local > :desde
            ');
            $stmt->execute(['ati' => $usuario['id'], 'desde' => $desde]);
            $res = $stmt->fetch();
            if ($res['total'] > 0) {
                $notificaciones[] = [
                    'tipo' => 'NUEVA_ENCUESTA',
                    'titulo' => 'Resultados Actualizados',
                    'mensaje' => $res['total'] == 1 ? "Se recibió 1 nueva encuesta en tus tiendas." : "Se recibieron {$res['total']} nuevas encuestas.",
                    'data' => ['total' => $res['total']]
                ];
            }
        }

        // 2. Soporte: Nuevos tickets (Solo para Webmaster)
        if ($usuario['rol_nombre'] === 'WEBMASTER') {
            $stmt = $pdo->prepare('SELECT COUNT(*) as total FROM soporte_ticket WHERE fecha_creacion > :desde AND estatus = "ABIERTO"');
            $stmt->execute(['desde' => $desde]);
            $res = $stmt->fetch();
            if ($res['total'] > 0) {
                $notificaciones[] = [
                    'tipo' => 'SOPORTE_NUEVO',
                    'titulo' => 'Nuevo Reporte de Soporte',
                    'mensaje' => "Hay {$res['total']} nuevo(s) reporte(s) de problemas pendientes.",
                    'data' => ['total' => $res['total']]
                ];
            }
        }

        // 3. Soporte: Actualizaciones en tickets propios (Para todos los que tengan tickets)
        // Buscamos nuevos mensajes en tickets donde el usuario es el creador (o el webmaster respondiendo)
        // Pero simplificamos: mensajes nuevos en tickets del usuario que no sean del mismo usuario.
        $stmt = $pdo->prepare('
            SELECT COUNT(*) as total, t.asunto, t.id as ticket_id
            FROM soporte_mensaje m
            JOIN soporte_ticket t ON t.id = m.ticket_id
            WHERE m.fecha > :desde
              AND m.usuario_id != :uid
              AND (t.usuario_id = :uid OR :es_wm = 1)
            GROUP BY t.id
        ');
        $stmt->execute([
            'desde' => $desde,
            'uid' => $usuario['id'],
            'es_wm' => $usuario['rol_nombre'] === 'WEBMASTER' ? 1 : 0
        ]);
        $ticketsActualizados = $stmt->fetchAll();
        foreach ($ticketsActualizados as $tk) {
            $notificaciones[] = [
                'tipo' => 'SOPORTE_MENSAJE',
                'titulo' => 'Actualización en Soporte',
                'mensaje' => "Nuevo mensaje en el folio #{$tk['ticket_id']}: {$tk['asunto']}",
                'data' => ['ticket_id' => $tk['ticket_id']]
            ];
        }

        // 4. Nueva Versión (Para todos)
        $configFile = __DIR__ . '/../../config/version.json';
        if (file_exists($configFile)) {
            $v = json_decode(file_get_contents($configFile), true);
            // Esto es un poco truco: si la app no ha verificado la versión recientemente
            // Pero el Worker ya lo hace. Sin embargo, lo incluimos si queremos una notificacion push-like.
        }

        echo json_encode([
            'notificaciones' => $notificaciones,
            'server_time' => date('Y-m-d H:i:s')
        ]);
    }
}
