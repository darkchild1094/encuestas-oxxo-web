<?php

declare(strict_types=1);

/**
 * Limitador de intentos muy simple, basado en archivos en el directorio
 * temporal (no hay Redis ni tabla dedicada). Se usa para frenar fuerza
 * bruta en el login sin depender de la BD.
 *
 * Filosofia: "fail open". Si el sistema de archivos falla, NO se bloquea
 * a nadie -- preferimos no romper el login por un problema de disco.
 */
final class RateLimit
{
    /**
     * @return bool true si la accion identificada por $clave puede seguir;
     *              false si ya rebaso $maxIntentos dentro de $ventanaSeg.
     */
    public static function permitido(string $clave, int $maxIntentos, int $ventanaSeg): bool
    {
        $marcas = self::leer($clave);
        $corte = time() - $ventanaSeg;
        $marcas = array_values(array_filter($marcas, static fn($t) => $t >= $corte));
        return count($marcas) < $maxIntentos;
    }

    /** Registra un intento fallido para $clave. */
    public static function registrarFallo(string $clave): void
    {
        $marcas = self::leer($clave);
        $marcas[] = time();
        // Guardamos como mucho las ultimas 50 marcas para que el archivo
        // no crezca sin control.
        if (count($marcas) > 50) {
            $marcas = array_slice($marcas, -50);
        }
        @file_put_contents(self::ruta($clave), implode(',', $marcas), LOCK_EX);
    }

    /** Limpia el contador tras un intento exitoso. */
    public static function limpiar(string $clave): void
    {
        @unlink(self::ruta($clave));
    }

    /** Segundos aproximados hasta que se libere el bloqueo. */
    public static function esperaSegundos(string $clave, int $ventanaSeg): int
    {
        $marcas = self::leer($clave);
        if (!$marcas) {
            return 0;
        }
        $restante = ($ventanaSeg - (time() - min($marcas)));
        return max(0, $restante);
    }

    private static function ruta(string $clave): string
    {
        $dir = sys_get_temp_dir() . '/nps_rate';
        if (!is_dir($dir)) {
            @mkdir($dir, 0700, true);
        }
        return $dir . '/' . hash('sha256', $clave) . '.txt';
    }

    /** @return int[] */
    private static function leer(string $clave): array
    {
        $archivo = self::ruta($clave);
        if (!is_file($archivo)) {
            return [];
        }
        $crudo = @file_get_contents($archivo);
        if ($crudo === false || $crudo === '') {
            return [];
        }
        return array_map('intval', array_filter(explode(',', $crudo), 'is_numeric'));
    }
}
