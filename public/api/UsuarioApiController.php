<?php

require_once __DIR__ . '/../../config/database.php';

class UsuarioApiController
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
            SELECT u.id, r.gestiona_usuarios, r.gestiona_preguntas
            FROM token_acceso ta
            JOIN usuario u ON u.id = ta.usuario_id
            JOIN rol r ON r.id = u.rol_id
            WHERE ta.token = :token AND ta.fecha_expiracion > NOW()
            LIMIT 1
        ');
        $stmt->execute(['token' => $m[1]]);
        return $stmt->fetch() ?: null;
    }

    public function listar(): void
    {
        $u = $this->usuarioDesdeToken();
        if (!$u || !$u['gestiona_usuarios']) {
            http_response_code(401);
            echo json_encode(['error' => 'no autorizado']);
            return;
        }

        $pdo = Database::conexion();
        $usuarios = $pdo->query('
            SELECT u.id, u.correo, u.nombre_completo, u.foto_perfil, u.plaza_id,
                   u.debe_cambiar_password, u.fecha_registro, r.nombre AS rol,
                   p.nombre AS plaza_nombre
            FROM usuario u
            JOIN rol r ON r.id = u.rol_id
            LEFT JOIN plaza p ON p.id = u.plaza_id
            ORDER BY u.correo
        ')->fetchAll();

        foreach ($usuarios as &$usr) {
            $usr['id'] = (int) $usr['id'];
            $usr['plaza_id'] = $usr['plaza_id'] !== null ? (int) $usr['plaza_id'] : null;
            $usr['debe_cambiar_password'] = (bool) $usr['debe_cambiar_password'];
            // Otros campos de UsuarioDto que el app espera aunque no vengan de BD aqui
            $usr['gestiona_preguntas'] = false; // El app no los necesita para la lista admin
            $usr['gestiona_usuarios'] = false;
            $usr['es_encuestable'] = false;
            $usr['ve_resultados_tiendas'] = false;
        }

        echo json_encode($usuarios);
    }

    public function cambiarPassword(): void
    {
        $u = $this->usuarioDesdeToken();
        if (!$u) {
            http_response_code(401);
            echo json_encode(['success' => false, 'error' => 'token invalido']);
            return;
        }

        $datos = json_decode(file_get_contents('php://input'), true) ?? [];
        $nueva = $datos['password'] ?? '';

        if (strlen($nueva) < 6) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'La contrasena debe tener al menos 6 caracteres']);
            return;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('UPDATE usuario SET password_hash = :hash, debe_cambiar_password = 0 WHERE id = :id');
        $stmt->execute(['hash' => password_hash($nueva, PASSWORD_DEFAULT), 'id' => $u['id']]);

        echo json_encode(['success' => true]);
    }

    public function crear(): void
    {
        $u = $this->usuarioDesdeToken();
        if (!$u || !$u['gestiona_usuarios']) {
            http_response_code(401);
            echo json_encode(['error' => 'no autorizado']);
            return;
        }

        $correo = trim($_POST['correo'] ?? '');
        $nombre = trim($_POST['nombre'] ?? '');
        $rolId = (int) ($_POST['rol_id'] ?? 0);
        $plazaId = (int) ($_POST['plaza_id'] ?? 0) ?: null;
        $password = $_POST['password'] ?? '';

        $rutaFoto = $this->guardarFotoSiViene();

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            INSERT INTO usuario (rol_id, plaza_id, correo, nombre_completo, password_hash, foto_perfil, debe_cambiar_password)
            VALUES (:rol_id, :plaza_id, :correo, :nombre, :hash, :foto, 1)
        ');
        $stmt->execute([
            'rol_id' => $rolId,
            'plaza_id' => $plazaId,
            'correo' => $correo,
            'nombre' => $nombre,
            'hash' => password_hash($password, PASSWORD_DEFAULT),
            'foto' => $rutaFoto,
        ]);

        echo json_encode(['success' => true]);
    }

    public function editar(): void
    {
        $u = $this->usuarioDesdeToken();
        if (!$u || !$u['gestiona_usuarios']) {
            http_response_code(401);
            echo json_encode(['error' => 'no autorizado']);
            return;
        }

        $id = (int) ($_POST['id'] ?? 0);
        $nombre = trim($_POST['nombre'] ?? '');
        $rolId = (int) ($_POST['rol_id'] ?? 0);
        $plazaId = (int) ($_POST['plaza_id'] ?? 0) ?: null;
        $password = $_POST['password'] ?? null;

        $rutaFoto = $this->guardarFotoSiViene();

        $pdo = Database::conexion();
        $sql = "UPDATE usuario SET nombre_completo = :nom, rol_id = :rid, plaza_id = :pid";
        $params = ['nom' => $nombre, 'rid' => $rolId, 'pid' => $plazaId, 'id' => $id];

        if ($rutaFoto) {
            $sql .= ", foto_perfil = :foto";
            $params['foto'] = $rutaFoto;
        }
        if ($password) {
            $sql .= ", password_hash = :hash, debe_cambiar_password = 1";
            $params['hash'] = password_hash($password, PASSWORD_DEFAULT);
        }
        $sql .= " WHERE id = :id";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        echo json_encode(['success' => true]);
    }

    public function eliminar(): void
    {
        $u = $this->usuarioDesdeToken();
        $id = (int) ($_GET['id'] ?? 0); // O sacarlo de la ruta si el index.php lo permite

        if (!$u || !$u['gestiona_usuarios']) {
            http_response_code(401);
            echo json_encode(['error' => 'no autorizado']);
            return;
        }

        $pdo = Database::conexion();
        $pdo->prepare('DELETE FROM usuario WHERE id = :id')->execute(['id' => $id]);
        echo json_encode(['success' => true]);
    }

    public function actualizarPerfil(): void
    {
        $u = $this->usuarioDesdeToken();
        if (!$u) {
            http_response_code(401);
            echo json_encode(['success' => false, 'error' => 'token invalido']);
            return;
        }

        $nombre = trim($_POST['nombre'] ?? '');
        $rutaFoto = $this->guardarFotoSiViene();

        $pdo = Database::conexion();
        if ($rutaFoto) {
            $stmt = $pdo->prepare('UPDATE usuario SET nombre_completo = :nom, foto_perfil = :foto WHERE id = :id');
            $stmt->execute(['nom' => $nombre, 'foto' => $rutaFoto, 'id' => $u['id']]);
        } else {
            $stmt = $pdo->prepare('UPDATE usuario SET nombre_completo = :nom WHERE id = :id');
            $stmt->execute(['nom' => $nombre, 'id' => $u['id']]);
        }

        echo json_encode(['success' => true]);
    }

    private function guardarFotoSiViene(): ?string
    {
        if (empty($_FILES['foto_perfil']) || $_FILES['foto_perfil']['error'] !== UPLOAD_ERR_OK) {
            return null;
        }
        $permitidos = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
        $tipo = mime_content_type($_FILES['foto_perfil']['tmp_name']);
        if (!isset($permitidos[$tipo])) return null;

        $nombre = bin2hex(random_bytes(16)) . '.' . $permitidos[$tipo];
        $ruta = __DIR__ . '/../uploads/perfiles/' . $nombre;
        if (!is_dir(dirname($ruta))) mkdir(dirname($ruta), 0777, true);
        move_uploaded_file($_FILES['foto_perfil']['tmp_name'], $ruta);
        return 'uploads/perfiles/' . $nombre;
    }
}
