<?php

require_once __DIR__ . '/../../config/database.php';

class PreguntaApiController
{
    private function obtenerHeaderAuth(): string
    {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        if ($header === '' && function_exists('getallheaders')) {
            $headers = getallheaders();
            $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        }
        return $header;
    }

    private function usuarioDesdeToken(): ?array
    {
        $header = $this->obtenerHeaderAuth();
        if (!preg_match('/Bearer\s+(\S+)/', $header, $m)) {
            return null;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            SELECT u.id, r.gestiona_preguntas
            FROM token_acceso ta
            JOIN usuario u ON u.id = ta.usuario_id
            JOIN rol r ON r.id = u.rol_id
            WHERE ta.token = :token AND ta.fecha_expiracion > NOW()
            LIMIT 1
        ');
        $stmt->execute(['token' => $m[1]]);
        return $stmt->fetch() ?: null;
    }

    public function crear(): void
    {
        $u = $this->usuarioDesdeToken();
        if (!$u || !$u['gestiona_preguntas']) {
            http_response_code(401);
            echo json_encode(['error' => 'no autorizado']);
            return;
        }

        $datos = json_decode(file_get_contents('php://input'), true);
        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            INSERT INTO pregunta (cuestionario_id, creado_por_usuario_id, texto, orden)
            VALUES (?, ?, ?, ?)
        ');
        $stmt->execute([
            $datos['cuestionario_id'],
            $u['id'],
            $datos['texto'],
            (int)$datos['orden']
        ]);

        echo json_encode(['success' => true]);
    }

    public function editar(): void
    {
        $u = $this->usuarioDesdeToken();
        if (!$u || !$u['gestiona_preguntas']) {
            http_response_code(401);
            echo json_encode(['error' => 'no autorizado']);
            return;
        }

        $datos = json_decode(file_get_contents('php://input'), true);
        $pdo = Database::conexion();
        $stmt = $pdo->prepare('UPDATE pregunta SET texto = ?, orden = ? WHERE id = ?');
        $stmt->execute([
            $datos['texto'],
            (int)$datos['orden'],
            (int)$datos['id']
        ]);

        echo json_encode(['success' => true]);
    }

    public function eliminar(): void
    {
        $u = $this->usuarioDesdeToken();
        $id = (int) ($_GET['id'] ?? 0);

        if (!$u || !$u['gestiona_preguntas']) {
            http_response_code(401);
            echo json_encode(['error' => 'no autorizado']);
            return;
        }

        $pdo = Database::conexion();
        $pdo->prepare('DELETE FROM pregunta WHERE id = ?')->execute([$id]);

        echo json_encode(['success' => true]);
    }
}
