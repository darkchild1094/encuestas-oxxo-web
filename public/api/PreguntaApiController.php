<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

// Gestion de preguntas (tienda y oficina) desde la app: solo Rosa Ramirez
// (usuario 128) las administra, igual que en el panel web
// (PreguntaController::soloRosa()). gestiona_preguntas sigue siendo
// requisito, pero ya no es suficiente por si solo.
class PreguntaApiController
{
    private function autorizado(?array $u): bool
    {
        return $u !== null && $u['gestiona_preguntas'] && (int) $u['id'] === 128;
    }

    public function crear(): void
    {
        $u = ApiAuth::usuarioDesdeToken();
        if (!$this->autorizado($u)) {
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
        $u = ApiAuth::usuarioDesdeToken();
        if (!$this->autorizado($u)) {
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
        $u = ApiAuth::usuarioDesdeToken();
        $id = (int) ($_GET['id'] ?? 0);

        if (!$this->autorizado($u)) {
            http_response_code(401);
            echo json_encode(['error' => 'no autorizado']);
            return;
        }

        $pdo = Database::conexion();
        $pdo->prepare('DELETE FROM pregunta WHERE id = ?')->execute([$id]);

        echo json_encode(['success' => true]);
    }
}
