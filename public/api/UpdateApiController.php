<?php

class UpdateApiController
{
    /**
     * Devuelve la información de la última versión disponible.
     * En un entorno real, esto vendría de una tabla de configuración o un archivo.
     */
    public function checkUpdate(): void
    {
        // Configuración de la última versión
        $latestUpdate = [
            'version_code' => 2,
            'version_name' => '1.1.0',
            'url' => 'https://fieldserviceplus.alwaysdata.net/nps/public/updates/app-release.apk',
            'obligatoria' => true,
            'novedades' => 'Sistema de auto-actualización y caché offline mejorado.'
        ];

        header('Content-Type: application/json');
        echo json_encode($latestUpdate);
    }
}
