<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../src/Auth.php';

/**
 * "Mi cuenta": disponible para cualquier rol con sesion en el panel
 * (ATI y WEBMASTER). Permite ver los datos propios y cambiar la
 * contrasena en cualquier momento, no solo cuando el sistema lo obliga.
 */
class CuentaController
{
    public function index(): void
    {
        Auth::requiereLogin();
        $pdo = Database::conexion();

        $stmt = $pdo->prepare('
            SELECT u.correo, u.nombre_completo, u.foto_perfil, u.fecha_registro,
                   r.nombre AS rol, p.nombre AS plaza
            FROM usuario u
            JOIN rol r ON r.id = u.rol_id
            LEFT JOIN plaza p ON p.id = u.plaza_id
            WHERE u.id = :id
            LIMIT 1
        ');
        $stmt->execute(['id' => $_SESSION['usuario_id']]);
        $cuenta = $stmt->fetch();

        if (!$cuenta) {
            Auth::logout();
            header('Location: ' . BASE_URL . '/login');
            exit;
        }

        $tituloPagina = 'Mi cuenta';
        require __DIR__ . '/../views/cuenta.php';
    }

    public function cambiarPassword(): void
    {
        Auth::requiereLogin();

        $actual = $_POST['password_actual'] ?? '';
        $nueva = $_POST['password'] ?? '';
        $confirmar = $_POST['password_confirmar'] ?? '';

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('SELECT password_hash FROM usuario WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $_SESSION['usuario_id']]);
        $hash = $stmt->fetchColumn();

        if (!$hash || !password_verify($actual, (string) $hash)) {
            $_SESSION['_flash_error'] = 'La contrasena actual no es correcta.';
            header('Location: ' . BASE_URL . '/mi-cuenta');
            exit;
        }
        if (strlen($nueva) < 8 || $nueva !== $confirmar) {
            $_SESSION['_flash_error'] = 'La nueva contrasena debe tener minimo 8 caracteres y coincidir.';
            header('Location: ' . BASE_URL . '/mi-cuenta');
            exit;
        }
        if (password_verify($nueva, (string) $hash)) {
            $_SESSION['_flash_error'] = 'La nueva contrasena debe ser distinta a la actual.';
            header('Location: ' . BASE_URL . '/mi-cuenta');
            exit;
        }

        $upd = $pdo->prepare('UPDATE usuario SET password_hash = :h, debe_cambiar_password = 0 WHERE id = :id');
        $upd->execute(['h' => password_hash($nueva, PASSWORD_DEFAULT), 'id' => $_SESSION['usuario_id']]);
        $_SESSION['debe_cambiar_password'] = false;

        $_SESSION['_flash_ok'] = 'Contrasena actualizada.';
        header('Location: ' . BASE_URL . '/mi-cuenta');
        exit;
    }
}
