<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../src/Auth.php';
require_once __DIR__ . '/../src/RateLimit.php';

class AuthController
{
    // Fuerza bruta: 8 intentos fallidos por IP en 15 min => enfriamiento.
    private const LOGIN_MAX_INTENTOS = 8;
    private const LOGIN_VENTANA_SEG = 900;

    public function mostrarLogin(): void
    {
        require __DIR__ . '/../views/login.php';
    }

    public function procesarLogin(): void
    {
        Auth::iniciar();
        $correo = trim($_POST['correo'] ?? '');
        $password = $_POST['password'] ?? '';

        $ip = $_SERVER['REMOTE_ADDR'] ?? 'desconocida';
        $claveLimite = 'login:' . $ip;
        if (!RateLimit::permitido($claveLimite, self::LOGIN_MAX_INTENTOS, self::LOGIN_VENTANA_SEG)) {
            $minutos = (int) ceil(RateLimit::esperaSegundos($claveLimite, self::LOGIN_VENTANA_SEG) / 60);
            $_SESSION['error_login'] = "Demasiados intentos fallidos. Espera unos {$minutos} min e intenta de nuevo.";
            header('Location: ' . BASE_URL . '/login');
            exit;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            SELECT u.id, u.password_hash, u.debe_cambiar_password,
                   u.nombre_completo, u.foto_perfil, u.plaza_id,
                   r.nombre AS rol_nombre, r.gestiona_preguntas,
                   (r.gestiona_usuarios OR u.id = 128) AS gestiona_usuarios,
                   r.ve_resultados_tiendas
            FROM usuario u
            JOIN rol r ON r.id = u.rol_id
            WHERE u.correo = :correo
            LIMIT 1
        ');
        $stmt->execute(['correo' => $correo]);
        $usuario = $stmt->fetch();

        if (!$usuario || !password_verify($password, $usuario['password_hash'])) {
            RateLimit::registrarFallo($claveLimite);
            $_SESSION['error_login'] = 'Correo o contrasena incorrectos.';
            header('Location: ' . BASE_URL . '/login');
            exit;
        }

        // El usuario normal no tiene nada que hacer en el panel web,
        // solo contesta encuestas desde la app.
        if ($usuario['rol_nombre'] === 'PFS') {
            $_SESSION['error_login'] = 'Este panel es solo para ATI y webmaster. Usa la app movil.';
            header('Location: ' . BASE_URL . '/login');
            exit;
        }

        RateLimit::limpiar($claveLimite);
        Auth::login($usuario);

        if ($usuario['debe_cambiar_password']) {
            header('Location: ' . BASE_URL . '/cambiar-password');
            exit;
        }

        header('Location: ' . BASE_URL . '/');
        exit;
    }

    // Pantalla de inicio segun permisos del rol -- ATI cae en
    // respuestas, webmaster cae en usuarios. Evita que alguien sin
    // permiso de ver respuestas se estrelle con un 403 justo al
    // entrar.
    public function inicio(): void
    {
        Auth::requiereLogin();

        if (!empty($_SESSION['ve_resultados_tiendas'])) {
            header('Location: ' . BASE_URL . '/dashboard');
        } elseif (!empty($_SESSION['gestiona_usuarios'])) {
            header('Location: ' . BASE_URL . '/usuarios');
        } elseif (!empty($_SESSION['gestiona_preguntas'])) {
            header('Location: ' . BASE_URL . '/preguntas');
        } else {
            header('Location: ' . BASE_URL . '/login');
        }
        exit;
    }

    public function logout(): void
    {
        Auth::logout();
        header('Location: ' . BASE_URL . '/login');
        exit;
    }

    public function mostrarCambiarPassword(): void
    {
        Auth::requiereLogin();
        require __DIR__ . '/../views/cambiar_password.php';
    }

    public function procesarCambiarPassword(): void
    {
        Auth::requiereLogin();
        $nueva = $_POST['password'] ?? '';
        $confirmar = $_POST['password_confirmar'] ?? '';

        if (strlen($nueva) < 8 || $nueva !== $confirmar) {
            $_SESSION['error_password'] = 'La contrasena debe tener minimo 8 caracteres y coincidir en ambos campos.';
            header('Location: ' . BASE_URL . '/cambiar-password');
            exit;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            UPDATE usuario
            SET password_hash = :hash, debe_cambiar_password = 0
            WHERE id = :id
        ');
        $stmt->execute([
            'hash' => password_hash($nueva, PASSWORD_DEFAULT),
            'id' => $_SESSION['usuario_id'],
        ]);
        $_SESSION['debe_cambiar_password'] = false;

        header('Location: ' . BASE_URL . '/');
        exit;
    }
}
