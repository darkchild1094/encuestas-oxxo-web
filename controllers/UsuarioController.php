<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../src/Auth.php';

// Solo webmaster entra aqui (gestiona_usuarios).
class UsuarioController
{
    // El usuario 128 es el ATI global (ve todas las plazas, permisos
    // ampliados en el login). No se le cambia rol/plaza ni se borra desde
    // el CRUD para no dejar al sistema sin ese acceso.
    private const ID_PROTEGIDO = 128;

    private function esProtegido(int $id): bool
    {
        return $id === self::ID_PROTEGIDO;
    }

    private function esYoMismo(int $id): bool
    {
        return $id === (int) ($_SESSION['usuario_id'] ?? 0);
    }

    public function index(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $pdo = Database::conexion();

        $usuarios = $pdo->query('
            SELECT u.id, u.correo, u.nombre_completo, u.foto_perfil, u.plaza_id,
                   u.debe_cambiar_password, u.fecha_registro, u.genero, r.nombre AS rol,
                   p.nombre AS plaza
            FROM usuario u
            JOIN rol r ON r.id = u.rol_id
            LEFT JOIN plaza p ON p.id = u.plaza_id
            ORDER BY u.correo
        ')->fetchAll();

        $roles = $pdo->query('SELECT id, nombre FROM rol ORDER BY nombre')->fetchAll();
        $plazas = $pdo->query('
            SELECT pl.id, pl.nombre, r.nombre AS region, n.nombre AS negocio
            FROM plaza pl
            JOIN region r ON r.id = pl.region_id
            JOIN negocio n ON n.id = r.negocio_id
            ORDER BY n.nombre, r.nombre, pl.nombre
        ')->fetchAll();

        require __DIR__ . '/../views/usuarios/lista.php';
    }

    public function crear(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $correo = trim($_POST['correo'] ?? '');
        $nombreCompleto = trim($_POST['nombre_completo'] ?? '');
        $rolId = (int) ($_POST['rol_id'] ?? 0);
        $plazaId = (int) ($_POST['plaza_id'] ?? 0) ?: null;
        $genero = $this->generoValido($_POST['genero'] ?? null);

        if (!filter_var($correo, FILTER_VALIDATE_EMAIL) || $nombreCompleto === '' || $rolId <= 0) {
            $_SESSION['error_usuarios'] = 'Revisa los datos: correo valido, nombre y rol son obligatorios.';
            header('Location: ' . BASE_URL . '/usuarios');
            exit;
        }

        $rutaFoto = $this->guardarFotoSiViene();

        // Password temporal: se muestra UNA sola vez en el mensaje de
        // confirmacion. No se guarda en texto plano en ningun lado.
        $temporal = bin2hex(random_bytes(4));

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            INSERT INTO usuario (rol_id, plaza_id, correo, nombre_completo, genero, password_hash, foto_perfil, debe_cambiar_password)
            VALUES (:rol_id, :plaza_id, :correo, :nombre, :genero, :hash, :foto, 1)
        ');
        try {
            $stmt->execute([
                'rol_id' => $rolId,
                'plaza_id' => $plazaId,
                'correo' => $correo,
                'nombre' => $nombreCompleto,
                'genero' => $genero,
                'hash' => password_hash($temporal, PASSWORD_DEFAULT),
                'foto' => $rutaFoto,
            ]);
        } catch (PDOException $e) {
            // 23000 = violacion de restriccion (correo duplicado, rol_id
            // o plaza_id inexistente). Se informa sin volcar el error.
            $_SESSION['error_usuarios'] = ($e->getCode() === '23000')
                ? 'Ese correo ya esta registrado (o el rol/plaza no existe).'
                : 'No se pudo crear el usuario.';
            error_log('[usuarios/crear] ' . $e->getMessage());
            header('Location: ' . BASE_URL . '/usuarios');
            exit;
        }

        $_SESSION['mensaje'] = "Usuario creado. Password temporal: $temporal (copiala ahora, no se vuelve a mostrar).";
        header('Location: ' . BASE_URL . '/usuarios');
        exit;
    }

    // Editar nombre y/o foto de un usuario que ya existe. El correo y
    // el rol tienen su propio flujo (cambiarRol ya existe); esto es
    // solo para los datos de perfil.
    public function editarDatos(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $id = (int) ($_POST['id'] ?? 0);
        $nombreCompleto = trim($_POST['nombre_completo'] ?? '');
        $genero = $this->generoValido($_POST['genero'] ?? null);

        $rutaFoto = $this->guardarFotoSiViene();

        $pdo = Database::conexion();
        $sql = 'UPDATE usuario SET nombre_completo = :nombre';
        $params = ['nombre' => $nombreCompleto, 'id' => $id];

        if ($genero !== null) {
            $sql .= ', genero = :genero';
            $params['genero'] = $genero;
        }
        if ($rutaFoto) {
            $sql .= ', foto_perfil = :foto';
            $params['foto'] = $rutaFoto;
        }
        $sql .= ' WHERE id = :id';

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        header('Location: ' . BASE_URL . '/usuarios');
        exit;
    }

    private function generoValido(?string $valor): ?string
    {
        $valor = strtoupper(trim($valor ?? ''));
        return in_array($valor, ['H', 'M'], true) ? $valor : null;
    }

    // Valida y guarda la foto si vino en el request. Regresa la ruta
    // relativa a guardar en BD, o null si no se subio nada (para no
    // pisar la foto anterior en un editarDatos()).
    private function guardarFotoSiViene(): ?string
    {
        if (empty($_FILES['foto_perfil']) || $_FILES['foto_perfil']['error'] === UPLOAD_ERR_NO_FILE) {
            return null;
        }
        if ($_FILES['foto_perfil']['error'] !== UPLOAD_ERR_OK) {
            return null;
        }

        // Tope de tamano: una foto de perfil no necesita mas de 5 MB y
        // asi no se llena el disco con subidas enormes.
        if (($_FILES['foto_perfil']['size'] ?? 0) > 5 * 1024 * 1024) {
            return null;
        }

        $permitidos = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
        $tipo = function_exists('mime_content_type')
            ? mime_content_type($_FILES['foto_perfil']['tmp_name'])
            : null;
        if (!isset($permitidos[$tipo])) {
            return null; // tipo no soportado, se ignora silenciosamente
        }

        $carpeta = __DIR__ . '/../public/uploads/perfiles/';
        if (!is_dir($carpeta) && !@mkdir($carpeta, 0755, true) && !is_dir($carpeta)) {
            return null;
        }

        $nombreArchivo = bin2hex(random_bytes(16)) . '.' . $permitidos[$tipo];
        if (!move_uploaded_file($_FILES['foto_perfil']['tmp_name'], $carpeta . $nombreArchivo)) {
            return null;
        }

        return 'uploads/perfiles/' . $nombreArchivo;
    }

    public function cambiarRol(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $id = (int) ($_POST['id'] ?? 0);
        $rolId = (int) ($_POST['rol_id'] ?? 0);

        if ($id <= 0 || $rolId <= 0 || $this->esProtegido($id) || $this->esYoMismo($id)) {
            $_SESSION['error_usuarios'] = 'No puedes cambiar tu propio rol ni el del ATI global.';
            header('Location: ' . BASE_URL . '/usuarios');
            exit;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('UPDATE usuario SET rol_id = :rol_id WHERE id = :id');
        $stmt->execute(['rol_id' => $rolId, 'id' => $id]);

        header('Location: ' . BASE_URL . '/usuarios');
        exit;
    }

    public function cambiarPlaza(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $id = (int) ($_POST['id'] ?? 0);
        $plazaId = (int) ($_POST['plaza_id'] ?? 0) ?: null;

        if ($id <= 0 || $this->esProtegido($id)) {
            $_SESSION['error_usuarios'] = 'El ATI global no se asigna a una sola plaza.';
            header('Location: ' . BASE_URL . '/usuarios');
            exit;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('UPDATE usuario SET plaza_id = :plaza_id WHERE id = :id');
        $stmt->execute(['plaza_id' => $plazaId, 'id' => $id]);

        header('Location: ' . BASE_URL . '/usuarios');
        exit;
    }

    public function restablecerPassword(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $id = (int) ($_POST['id'] ?? 0);
        $temporal = bin2hex(random_bytes(4));

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            UPDATE usuario
            SET password_hash = :hash, debe_cambiar_password = 1
            WHERE id = :id
        ');
        $stmt->execute([
            'hash' => password_hash($temporal, PASSWORD_DEFAULT),
            'id' => $id,
        ]);

        $_SESSION['mensaje'] = "Password temporal generada: $temporal (copiala ahora, no se vuelve a mostrar).";
        header('Location: ' . BASE_URL . '/usuarios');
        exit;
    }

    public function eliminar(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $id = (int) ($_POST['id'] ?? 0);

        if ($id <= 0 || $this->esProtegido($id) || $this->esYoMismo($id)) {
            $_SESSION['error_usuarios'] = 'No puedes eliminarte a ti mismo ni al ATI global.';
            header('Location: ' . BASE_URL . '/usuarios');
            exit;
        }

        // encuesta.usuario_id es ON DELETE SET NULL, asi que borrar un
        // usuario no rompe el historial de encuestas ya contestadas.
        $pdo = Database::conexion();
        $stmt = $pdo->prepare('DELETE FROM usuario WHERE id = :id');
        $stmt->execute(['id' => $id]);

        header('Location: ' . BASE_URL . '/usuarios');
        exit;
    }
}
