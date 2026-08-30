<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

class NotificacionApiController
{
    private function tableExists(PDO $pdo, string $table): bool
    {
        try {
            $result = $pdo->query("SELECT 1 FROM $table LIMIT 1");
            return $result !== false;
        } catch (Exception $e) {
            return false;
        }
    }

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
            if ($res && $res['total'] > 0) {
                $notificaciones[] = [
                    'tipo' => 'NUEVA_ENCUESTA',
                    'titulo' => 'Resultados Actualizados',
                    'mensaje' => $res['total'] == 1 ? "Se recibió 1 nueva encuesta en tus tiendas." : "Se recibieron {$res['total']} nuevas encuestas.",
                    'data' => ['total' => (string)$res['total']]
                ];
            }
        }

        // Solo procedemos con soporte si las tablas existen
        if ($this->tableExists($pdo, 'soporte_ticket') && $this->tableExists($pdo, 'soporte_mensaje')) {
            // 2. Soporte: Nuevos tickets (Solo para Webmaster)
            if ($usuario['rol_nombre'] === 'WEBMASTER') {
                $stmt = $pdo->prepare('SELECT COUNT(*) as total FROM soporte_ticket WHERE fecha_creacion > :desde AND estatus = "ABIERTO"');
                $stmt->execute(['desde' => $desde]);
                $res = $stmt->fetch();
                if ($res && $res['total'] > 0) {
                    $notificaciones[] = [
                        'tipo' => 'SOPORTE_NUEVO',
                        'titulo' => 'Nuevo Reporte de Soporte',
                        'mensaje' => "Hay {$res['total']} nuevo(s) reporte(s) de problemas pendientes.",
                        'data' => ['total' => (string)$res['total']]
                    ];
                }
            }

            // 3. Soporte: Actualizaciones en tickets propios
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
                    'data' => ['ticket_id' => (string)$tk['ticket_id']]
                ];
            }
        }

        echo json_encode([
            'notificaciones' => $notificaciones,
            'server_time' => date('Y-m-d H:i:s')
        ]);
    }
}
