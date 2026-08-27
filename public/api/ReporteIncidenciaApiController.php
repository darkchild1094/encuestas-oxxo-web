<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

/**
 * Reportes de incidencias / comentarios, tipo ticket de servicio.
 * Cualquier usuario autenticado puede crear uno y ver los suyos con su
 * hilo de comentarios; solo quien gestiona_usuarios (WEBMASTER) puede
 * ver todos, comentar y marcar como resuelto.
 */
class ReporteIncidenciaApiController
{
    // POST /api/reportes  Body: { comentario }
    public function crear(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }

        $body = json_decode(file_get_contents('php://input'), true) ?? [];
        $comentario = trim($body['comentario'] ?? '');
        if ($comentario === '') {
            http_response_code(400);
            echo json_encode(['error' => 'comentario requerido']);
            return;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            INSERT INTO reporte_incidencia (usuario_id, comentario, estado)
            VALUES (:usuario_id, :comentario, \'abierto\')
        ');
        $stmt->execute(['usuario_id' => $usuario['id'], 'comentario' => $comentario]);

        echo json_encode(['success' => true, 'id' => (int) $pdo->lastInsertId()]);
    }

    // GET /api/reportes/mios -- los reportes del usuario en sesion, con su hilo de comentarios
    public function mios(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            SELECT id, comentario, estado, fecha_creacion, fecha_resuelto
            FROM reporte_incidencia
            WHERE usuario_id = :usuario_id
            ORDER BY fecha_creacion DESC
        ');
        $stmt->execute(['usuario_id' => $usuario['id']]);
        $reportes = $stmt->fetchAll();

        echo json_encode($this->conComentarios($pdo, $reportes));
    }

    // GET /api/reportes -- TODOS los reportes (solo WEBMASTER), con quien lo reporto
    public function listar(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }
        if (!$usuario['gestiona_usuarios']) { $this->prohibido(); return; }

        $pdo = Database::conexion();
        $stmt = $pdo->query('
            SELECT r.id, r.comentario, r.estado, r.fecha_creacion, r.fecha_resuelto,
                   u.id AS usuario_id, u.nombre_completo AS usuario_nombre, u.foto_perfil AS usuario_foto
            FROM reporte_incidencia r
            JOIN usuario u ON u.id = r.usuario_id
            ORDER BY (r.estado = \'resuelto\') ASC, r.fecha_creacion DESC
        ');
        $reportes = $stmt->fetchAll();

        echo json_encode($this->conComentarios($pdo, $reportes));
    }

    // POST /api/reportes/comentar  Body: { reporte_id, comentario }
    // Agrega un comentario de seguimiento sin cerrar el ticket (lo pasa
    // a 'en_proceso' si todavia estaba 'abierto').
    public function comentar(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }
        if (!$usuario['gestiona_usuarios']) { $this->prohibido(); return; }

        $body = json_decode(file_get_contents('php://input'), true) ?? [];
        $reporteId = (int) ($body['reporte_id'] ?? 0);
        $comentario = trim($body['comentario'] ?? '');

        if (!$reporteId || $comentario === '') {
            http_response_code(400);
            echo json_encode(['error' => 'reporte_id y comentario son requeridos']);
            return;
        }

        $pdo = Database::conexion();
        $pdo->prepare('
            INSERT INTO reporte_incidencia_comentario (reporte_id, usuario_id, comentario)
            VALUES (:reporte_id, :usuario_id, :comentario)
        ')->execute(['reporte_id' => $reporteId, 'usuario_id' => $usuario['id'], 'comentario' => $comentario]);

        $pdo->prepare("
            UPDATE reporte_incidencia SET estado = 'en_proceso'
            WHERE id = :id AND estado = 'abierto'
        ")->execute(['id' => $reporteId]);

        echo json_encode(['success' => true]);
    }

    // POST /api/reportes/resolver  Body: { reporte_id, comentario }
    // El comentario aqui es obligatorio: es el "como se solucionó" que
    // va a ver el usuario que reporto.
    public function resolver(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }
        if (!$usuario['gestiona_usuarios']) { $this->prohibido(); return; }

        $body = json_decode(file_get_contents('php://input'), true) ?? [];
        $reporteId = (int) ($body['reporte_id'] ?? 0);
        $comentario = trim($body['comentario'] ?? '');

        if (!$reporteId || $comentario === '') {
            http_response_code(400);
            echo json_encode(['error' => 'reporte_id y comentario (como se resolvio) son requeridos']);
            return;
        }

        $pdo = Database::conexion();
        $pdo->prepare('
            INSERT INTO reporte_incidencia_comentario (reporte_id, usuario_id, comentario)
            VALUES (:reporte_id, :usuario_id, :comentario)
        ')->execute(['reporte_id' => $reporteId, 'usuario_id' => $usuario['id'], 'comentario' => $comentario]);

        $pdo->prepare("
            UPDATE reporte_incidencia SET estado = 'resuelto', fecha_resuelto = NOW()
            WHERE id = :id
        ")->execute(['id' => $reporteId]);

        echo json_encode(['success' => true]);
    }

    // ---------------------------------------------------------------

    private function conComentarios(PDO $pdo, array $reportes): array
    {
        if (!$reportes) {
            return [];
        }

        $ids = array_column($reportes, 'id');
        $marcadores = implode(',', array_fill(0, count($ids), '?'));
        $stmt = $pdo->prepare("
            SELECT c.reporte_id, c.comentario, c.fecha_creacion,
                   u.nombre_completo AS usuario_nombre, u.rol_id
            FROM reporte_incidencia_comentario c
            JOIN usuario u ON u.id = c.usuario_id
            WHERE c.reporte_id IN ($marcadores)
            ORDER BY c.fecha_creacion ASC
        ");
        $stmt->execute($ids);
        $comentariosPorReporte = [];
        foreach ($stmt->fetchAll() as $c) {
            $comentariosPorReporte[(int) $c['reporte_id']][] = [
                'comentario' => $c['comentario'],
                'fecha_creacion' => $c['fecha_creacion'],
                'usuario_nombre' => $c['usuario_nombre'],
            ];
        }

        foreach ($reportes as &$r) {
            $r['id'] = (int) $r['id'];
            if (isset($r['usuario_id'])) {
                $r['usuario_id'] = (int) $r['usuario_id'];
            }
            $r['comentarios'] = $comentariosPorReporte[$r['id']] ?? [];
        }
        unset($r);

        return $reportes;
    }

    private function noAutorizado(): void
    {
        http_response_code(401);
        echo json_encode(['error' => 'token inválido o vencido']);
    }

    private function prohibido(): void
    {
        http_response_code(403);
        echo json_encode(['error' => 'solo el rol que gestiona usuarios puede acceder a esto']);
    }
}
