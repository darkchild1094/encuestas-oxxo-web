<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

class PreguntaApiController
{

    public function crear(): void
    {
        $u = ApiAuth::usuarioDesdeToken();
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
        $u = ApiAuth::usuarioDesdeToken();
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
        $u = ApiAuth::usuarioDesdeToken();
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
