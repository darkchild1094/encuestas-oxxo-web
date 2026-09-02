<?php

declare(strict_types=1);

/**
 * Proteccion CSRF para el panel web. El panel se apoya 100% en formularios
 * <form method="POST"> con cookie de sesion, asi que sin token cualquier
 * sitio podia disparar acciones (crear/eliminar usuarios, cambiar roles,
 * publicar un APK...) a nombre de un ATI o webmaster con sesion abierta.
 *
 * Uso:
 *   - En la vista, dentro de cada <form method="POST">:  <?= Csrf::campo() ?>
 *   - La validacion es central en public/index.php para TODAS las rutas POST.
 *
 * La API movil (public/api/*) NO usa esto: va con "Authorization: Bearer" y
 * no con cookies, asi que no es vulnerable a CSRF y no debe pedir token.
 */
final class Csrf
{
    private const CLAVE_SESION = '_csrf';
    public const CAMPO = '_csrf';

    /** Devuelve el token de la sesion, generandolo la primera vez. */
    public static function token(): string
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            return '';
        }
        if (empty($_SESSION[self::CLAVE_SESION]) || !is_string($_SESSION[self::CLAVE_SESION])) {
            $_SESSION[self::CLAVE_SESION] = bin2hex(random_bytes(32));
        }
        return $_SESSION[self::CLAVE_SESION];
    }

    /** Campo <input hidden> listo para pegar dentro de un formulario. */
    public static function campo(): string
    {
        $token = htmlspecialchars(self::token(), ENT_QUOTES, 'UTF-8');
        return '<input type="hidden" name="' . self::CAMPO . '" value="' . $token . '">';
    }

    /**
     * Compara en tiempo constante el token recibido (POST o header
     * X-CSRF-Token) contra el de la sesion.
     */
    public static function esValido(?string $recibido): bool
    {
        $esperado = $_SESSION[self::CLAVE_SESION] ?? '';
        if (!is_string($esperado) || $esperado === '' || !is_string($recibido) || $recibido === '') {
            return false;
        }
        return hash_equals($esperado, $recibido);
    }

    /**
     * Aborta con 419 si la peticion POST actual no trae un token valido.
     * Se llama una sola vez, en el router, antes de ejecutar el controlador.
     */
    public static function exigir(): void
    {
        $recibido = $_POST[self::CAMPO] ?? ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? null);
        if (self::esValido(is_string($recibido) ? $recibido : null)) {
            return;
        }

        http_response_code(419);
        header('Content-Type: text/html; charset=utf-8');
        echo '<!doctype html><html lang="es"><meta charset="utf-8">'
            . '<title>Sesion expirada</title>'
            . '<body style="font-family:system-ui,sans-serif;max-width:32rem;margin:15vh auto;padding:0 1.25rem;color:#241213">'
            . '<h1 style="font-size:1.35rem">Tu sesion expiro</h1>'
            . '<p>Por seguridad el formulario ya no era valido. Vuelve a la pagina anterior, '
            . 'recargala y envia de nuevo.</p>'
            . '<p><a href="' . htmlspecialchars(defined('BASE_URL') ? BASE_URL : '/nps', ENT_QUOTES) . '/" '
            . 'style="color:#d70b16;font-weight:700">Volver al inicio</a></p>'
            . '</body></html>';
        exit;
    }
}
