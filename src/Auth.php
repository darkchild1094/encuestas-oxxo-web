<?php

class Auth
{
    /** Sesion inactiva mas de esto => se cierra sola. */
    private const IDLE_MAX = 8 * 3600;        // 8 horas sin actividad
    /** Vida maxima absoluta de una sesion aunque haya actividad. */
    private const ABSOLUTA_MAX = 30 * 86400;  // 30 dias

    public static function iniciar(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_name('NPS_SESSID');
            $params = session_get_cookie_params();
            session_set_cookie_params([
                'lifetime' => $params['lifetime'],
                'path' => '/nps',
                'domain' => $params['domain'],
                // secure solo cuando de verdad vamos por HTTPS: en prod
                // (alwaysdata) siempre lo es; en local por HTTP no, y con
                // secure=true fijo la cookie de sesion no se guardaba.
                'secure' => self::esHttps(),
                'httponly' => true,
                'samesite' => 'Lax',
            ]);
            session_start();
        }
        self::vigilarCaducidad();
    }

    private static function esHttps(): bool
    {
        if (!empty($_SERVER['HTTPS']) && strtolower((string) $_SERVER['HTTPS']) !== 'off') {
            return true;
        }
        if (($_SERVER['SERVER_PORT'] ?? null) == 443) {
            return true;
        }
        // Detras del proxy de alwaysdata el TLS termina antes de llegar a PHP.
        return strtolower((string) ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '')) === 'https';
    }

    // Cierra la sesion si lleva demasiado tiempo inactiva o si ya rebaso
    // su vida maxima. Se ejecuta en cada request.
    private static function vigilarCaducidad(): void
    {
        if (empty($_SESSION['usuario_id'])) {
            return;
        }
        $ahora = time();
        $ultima = (int) ($_SESSION['_ultima_actividad'] ?? $ahora);
        $inicio = (int) ($_SESSION['_inicio_sesion'] ?? $ahora);

        if (($ahora - $ultima) > self::IDLE_MAX || ($ahora - $inicio) > self::ABSOLUTA_MAX) {
            // Vaciar aqui mismo (sin llamar a logout(), que reentra en
            // iniciar()). Basta con dejar la sesion sin datos: el resto
            // del codigo la trata como "no logueado".
            $_SESSION = [];
            session_regenerate_id(true);
            return;
        }
        $_SESSION['_ultima_actividad'] = $ahora;
    }

    // Guarda en sesion lo minimo necesario para pintar el menu y
    // checar permisos sin volver a pegarle a la BD en cada request.
    public static function login(array $usuario): void
    {
        self::iniciar();
        session_regenerate_id(true);
        $_SESSION['usuario_id'] = $usuario['id'];
        $_SESSION['rol'] = $usuario['rol_nombre'];
        $_SESSION['nombre_completo'] = $usuario['nombre_completo'] ?? '';
        $_SESSION['foto_perfil'] = $usuario['foto_perfil'] ?? null;
        $_SESSION['plaza_id'] = $usuario['plaza_id'] ?? null;
        $_SESSION['gestiona_preguntas'] = (bool) $usuario['gestiona_preguntas'];
        $_SESSION['gestiona_usuarios'] = (bool) $usuario['gestiona_usuarios'];
        $_SESSION['ve_resultados_tiendas'] = (bool) $usuario['ve_resultados_tiendas'];
        $_SESSION['debe_cambiar_password'] = (bool) $usuario['debe_cambiar_password'];
        $_SESSION['_inicio_sesion'] = time();
        $_SESSION['_ultima_actividad'] = time();
    }

    public static function requiereLogin(): void
    {
        self::iniciar();
        if (empty($_SESSION['usuario_id'])) {
            $base = defined('BASE_URL') ? BASE_URL : '/nps';
            header('Location: ' . $base . '/login');
            exit;
        }
    }

    // $permiso: 'gestiona_preguntas' | 'gestiona_usuarios' | 've_resultados_tiendas'
    public static function requierePermiso(string $permiso): void
    {
        self::requiereLogin();
        if (empty($_SESSION[$permiso])) {
            http_response_code(403);
            echo 'No tienes permiso para ver esta seccion.';
            exit;
        }
    }

    public static function logout(): void
    {
        self::iniciar();
        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $p = session_get_cookie_params();
            setcookie(session_name(), '', [
                'expires' => time() - 42000,
                'path' => $p['path'] ?: '/nps',
                'domain' => $p['domain'],
                'secure' => self::esHttps(),
                'httponly' => true,
                'samesite' => 'Lax',
            ]);
        }
        session_destroy();
    }
}
