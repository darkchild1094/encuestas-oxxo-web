<?php

declare(strict_types=1);

/**
 * Utilidades HTTP para el panel web: cabeceras de seguridad y redirecciones
 * seguras. Se mantiene minimo a proposito -- no hay framework y el resto del
 * codigo espera funciones simples.
 */
final class Http
{
    /**
     * Cabeceras de seguridad que aplican a TODA respuesta HTML del panel.
     * Se llama una vez, al arrancar el router. No incluye HSTS (eso se
     * configura a nivel de servidor/hosting) ni una CSP estricta, porque
     * el panel carga Bootstrap y las fuentes desde CDN y una CSP mal
     * calibrada rompe la UI sin avisar; se deja una CSP amplia pero util.
     */
    public static function cabecerasSeguridad(): void
    {
        if (headers_sent()) {
            return;
        }
        header('X-Content-Type-Options: nosniff');
        header('X-Frame-Options: DENY');
        header('Referrer-Policy: same-origin');
        header('Cross-Origin-Opener-Policy: same-origin');
        header('Permissions-Policy: geolocation=(), microphone=(), camera=(), payment=()');
        header_remove('X-Powered-By');

        header(
            "Content-Security-Policy: "
            . "default-src 'self'; "
            . "script-src 'self' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com 'unsafe-inline'; "
            . "style-src 'self' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com https://fonts.googleapis.com 'unsafe-inline'; "
            . "font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com data:; "
            . "img-src 'self' data:; "
            . "frame-ancestors 'none'; "
            . "base-uri 'self'; "
            . "form-action 'self'"
        );
    }

    /**
     * Redireccion interna segura. Solo acepta rutas que empiezan con "/"
     * (nunca "//" ni "http..."), para que ni un valor manipulado pueda
     * convertir un redirect en open-redirect o en inyeccion de cabecera.
     */
    public static function redirigir(string $ruta): void
    {
        if ($ruta === '' || $ruta[0] !== '/' || str_starts_with($ruta, '//')) {
            $ruta = (defined('BASE_URL') ? BASE_URL : '/nps') . '/';
        }
        $ruta = str_replace(["\r", "\n"], '', $ruta);
        header('Location: ' . $ruta, true, 302);
        exit;
    }
}
