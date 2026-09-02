<?php

require_once __DIR__ . '/../../src/AppVersion.php';

class UpdateApiController
{
    public function checkUpdate(): void
    {
        $cfg = AppVersion::config();
        $cliente = AppVersion::versionCliente();

        $forzar = AppVersion::debeForzar($cfg, $cliente);
        // Apps que ya reportan su version: sabemos si hay algo mas nuevo.
        // Apps viejas (cliente = null): que se guien por su propia logica
        // con `obligatoria`, como siempre.
        $hayUpdate = $cliente !== null
            ? $cliente < (int) $cfg['version_code']
            : (bool) $cfg['obligatoria'];

        header('Content-Type: application/json');
        echo json_encode([
            // --- Campos historicos (no cambiar: apps ya instaladas los leen) ---
            'version_code' => (int) $cfg['version_code'],
            'version_name' => $cfg['version_name'],
            'url' => $cfg['url'],
            'obligatoria' => (bool) $cfg['obligatoria'],
            'novedades' => $cfg['novedades'],
            // --- Nuevos ---
            'min_version_code' => (int) $cfg['min_version_code'],
            'force_update' => $forzar,
            'update_disponible' => $hayUpdate,
            'client_version_code' => $cliente,
        ]);
    }
}
