<?php

declare(strict_types=1);

/**
 * Version publicada de la app Android y reglas de actualizacion forzada.
 * Lee config/version.json (lo escribe el panel /actualizar-app) y centraliza
 * la logica de "esta app esta demasiado vieja para dejarla pasar".
 *
 * Contrato con la app:
 *   - La app manda su version en el header  X-App-Version: <versionCode>
 *     (o ?version_code=<n> en el GET de /api/check-update).
 *   - GET /api/check-update devuelve force_update / update_disponible ya
 *     calculados, ademas de los campos historicos.
 *   - Si la app manda su version y esta por debajo de min_version_code, el
 *     resto de la API responde 426 (Upgrade Required) y no la deja operar.
 *
 * Apps viejas que todavia NO mandan el header siguen guiandose por el flag
 * historico `obligatoria` + `version_code` (logica del lado del cliente).
 */
final class AppVersion
{
    private const ARCHIVO = __DIR__ . '/../config/version.json';

    private const DEFAULTS = [
        'version_code' => 1,
        'version_name' => '1.0.0',
        'url' => '',
        'obligatoria' => false,
        'min_version_code' => 0,
        'novedades' => '',
    ];

    /** @return array<string,mixed> config completa, con defaults si falta algo. */
    public static function config(): array
    {
        $data = is_file(self::ARCHIVO)
            ? json_decode((string) file_get_contents(self::ARCHIVO), true)
            : null;
        if (!is_array($data)) {
            $data = [];
        }
        return array_merge(self::DEFAULTS, $data);
    }

    /** versionCode que reporta la app en esta peticion, o null si no lo manda. */
    public static function versionCliente(): ?int
    {
        $crudo = $_SERVER['HTTP_X_APP_VERSION']
            ?? $_SERVER['HTTP_X_APP_VERSION_CODE']
            ?? ($_GET['version_code'] ?? null);
        if ($crudo === null || $crudo === '' || !is_numeric($crudo)) {
            return null;
        }
        return max(0, (int) $crudo);
    }

    /**
     * true si hay que obligar a este cliente a actualizar antes de operar.
     * Si no sabemos su version (null) devolvemos false: el gate 426 no aplica
     * y la app vieja se sigue guiando por `obligatoria`.
     */
    public static function debeForzar(array $cfg, ?int $cliente): bool
    {
        if ($cliente === null) {
            return false;
        }
        $min = (int) ($cfg['min_version_code'] ?? 0);
        if ($min > 0 && $cliente < $min) {
            return true;
        }
        if (!empty($cfg['obligatoria']) && $cliente < (int) $cfg['version_code']) {
            return true;
        }
        return false;
    }
}
