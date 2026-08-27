<?php

class UpdateApiController
{
    public function checkUpdate(): void
    {
        $configFile = __DIR__ . '/../../config/version.json';

        if (file_exists($configFile)) {
            $data = json_decode(file_get_contents($configFile), true);
        } else {
            // Fallback si no existe el archivo
            $data = [
                'version_code' => 1,
                'version_name' => '1.0.0',
                'url' => '',
                'obligatoria' => false,
                'novedades' => ''
            ];
        }

        header('Content-Type: application/json');
        echo json_encode($data);
    }
}
