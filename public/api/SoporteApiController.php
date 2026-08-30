<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

class SoporteApiController
{
    private function noAutorizado(): void
    {
        http_response_code(401);
        echo json_encode(['error' => 'token invalido o vencido']);
    }

    // POST /api/soporte/crear
    public function crear(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }

        $asunto = $_POST['asunto'] ?? '';
        $descripcion = $_POST['descripcion'] ?? '';

        if (empty($asunto) || empty($descripcion)) {
            http_response_code(400);
            echo json_encode(['error' => 'asunto y descripcion requeridos']);
            return;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare("INSERT INTO soporte_ticket (usuario_id, asunto, descripcion) VALUES (?, ?, ?)");
        $stmt->execute([$usuario['id'], $asunto, $descripcion]);
        $ticketId = $pdo->lastInsertId();

        // Si hay evidencia inicial
        if (!empty($_FILES['evidencia']['name']) && $_FILES['evidencia']['error'] === UPLOAD_ERR_OK) {
            $this->guardarMensaje($ticketId, $usuario['id'], 'Reporte inicial con evidencia', $_FILES['evidencia']);
        }

        echo json_encode(['success' => true, 'ticket_id' => $ticketId]);
    }

    // GET /api/soporte/mis-tickets
    public function misTickets(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare("SELECT * FROM soporte_ticket WHERE usuario_id = ? ORDER BY fecha_creacion DESC");
        $stmt->execute([$usuario['id']]);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    // GET /api/soporte/admin/lista (Solo Webmaster)
    public function adminLista(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario || $usuario['rol_nombre'] !== 'WEBMASTER') {
            http_response_code(403);
            echo json_encode(['error' => 'solo webmaster puede ver todos los tickets']);
            return;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->query("SELECT t.*, u.nombre_completo as usuario_nombre FROM soporte_ticket t JOIN usuario u ON u.id = t.usuario_id ORDER BY t.fecha_creacion DESC");
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    // GET /api/soporte/detalle?id=X
    public function detalle(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }

        $ticketId = (int)($_GET['id'] ?? 0);
        $pdo = Database::conexion();

        // Validar propiedad del ticket
        $stmt = $pdo->prepare("SELECT * FROM soporte_ticket WHERE id = ?");
        $stmt->execute([$ticketId]);
        $ticket = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$ticket || ($usuario['rol_nombre'] !== 'WEBMASTER' && $ticket['usuario_id'] != $usuario['id'])) {
            http_response_code(403);
            echo json_encode(['error' => 'no tienes permiso para ver este ticket']);
            return;
        }

        $stmtMsgs = $pdo->prepare("SELECT m.*, u.nombre_completo as usuario_nombre, u.rol_id FROM soporte_mensaje m JOIN usuario u ON u.id = m.usuario_id WHERE m.ticket_id = ? ORDER BY m.fecha ASC");
        $stmtMsgs->execute([$ticketId]);
        $mensajes = $stmtMsgs->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'ticket' => $ticket,
            'mensajes' => $mensajes
        ]);
    }

    // POST /api/soporte/comentar
    public function comentar(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }

        $ticketId = (int)($_POST['ticket_id'] ?? 0);
        $mensaje = $_POST['mensaje'] ?? '';

        $pdo = Database::conexion();
        $stmt = $pdo->prepare("SELECT id, usuario_id FROM soporte_ticket WHERE id = ?");
        $stmt->execute([$ticketId]);
        $ticket = $stmt->fetch();

        if (!$ticket || ($usuario['rol_nombre'] !== 'WEBMASTER' && $ticket['usuario_id'] != $usuario['id'])) {
            http_response_code(403);
            return;
        }

        $this->guardarMensaje($ticketId, $usuario['id'], $mensaje, $_FILES['evidencia'] ?? null);
        echo json_encode(['success' => true]);
    }

    // POST /api/soporte/resolver (Solo Webmaster)
    public function resolver(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario || $usuario['rol_nombre'] !== 'WEBMASTER') {
            http_response_code(403);
            return;
        }

        $ticketId = (int)($_POST['ticket_id'] ?? 0);
        $notas = $_POST['notas_cierre'] ?? '';

        $pdo = Database::conexion();
        $stmt = $pdo->prepare("UPDATE soporte_ticket SET estatus = 'RESUELTO', notas_cierre = ? WHERE id = ?");
        $stmt->execute([$notas, $ticketId]);

        echo json_encode(['success' => true]);
    }

    private function guardarMensaje($ticketId, $usuarioId, $mensaje, $file = null): void
    {
        $rutaEvidencia = null;
        if ($file && $file['error'] === UPLOAD_ERR_OK) {
            $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
            $nombre = "ticket_{$ticketId}_" . time() . "_" . rand(100, 999) . "." . $ext;
            $dir = __DIR__ . '/../uploads/soporte/';
            if (!is_dir($dir)) mkdir($dir, 0777, true);
            if (move_uploaded_file($file['tmp_name'], $dir . $nombre)) {
                $rutaEvidencia = 'uploads/soporte/' . $nombre;
            }
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare("INSERT INTO soporte_mensaje (ticket_id, usuario_id, mensaje, evidencia_ruta) VALUES (?, ?, ?, ?)");
        $stmt->execute([$ticketId, $usuarioId, $mensaje, $rutaEvidencia]);

        // Actualizar fecha del ticket
        $pdo->prepare("UPDATE soporte_ticket SET fecha_actualizacion = NOW() WHERE id = ?")->execute([$ticketId]);
    }
}
