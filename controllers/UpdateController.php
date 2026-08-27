<?php

require_once __DIR__ . '/../src/Auth.php';

class UpdateController
{
    public function index(): void
    {
        Auth::requiereLogin();
        if ($_SESSION['rol'] !== 'WEBMASTER') {
            header('Location: ' . BASE_URL . '/');
            exit;
        }

        $configFile = __DIR__ . '/../config/version.json';
        $version = json_decode(file_get_contents($configFile), true);

        require __DIR__ . '/../views/actualizar_app.php';
    }

    public function procesar(): void
    {
        Auth::requiereLogin();
        if ($_SESSION['rol'] !== 'WEBMASTER') {
            header('Location: ' . BASE_URL . '/');
            exit;
        }

        $version_code = (int)($_POST['version_code'] ?? 0);
        $version_name = $_POST['version_name'] ?? '';
        $obligatoria = isset($_POST['obligatoria']);
        $novedades = $_POST['novedades'] ?? '';

        $apkUrl = "";

        // Manejar subida de APK
        if (!empty($_FILES['apk']['name']) && $_FILES['apk']['error'] === UPLOAD_ERR_OK) {
            $nombreArchivo = 'app-release.apk';
            $rutaDestino = __DIR__ . '/../public/updates/' . $nombreArchivo;

            if (!is_dir(dirname($rutaDestino))) {
                mkdir(dirname($rutaDestino), 0777, true);
            }

            if (move_uploaded_file($_FILES['apk']['tmp_name'], $rutaDestino)) {
                // Generar URL absoluta (ajustar segun dominio real si es necesario)
                // Usamos una URL relativa que el App pueda interpretar o una fija.
                $apkUrl = "https://fieldserviceplus.alwaysdata.net/nps/public/updates/" . $nombreArchivo;
            }
        } else {
            // Si no se subió archivo, mantener la URL anterior si existe
            $configFile = __DIR__ . '/../config/version.json';
            $oldData = json_decode(file_get_contents($configFile), true);
            $apkUrl = $oldData['url'] ?? "";
        }

        $newData = [
            'version_code' => $version_code,
            'version_name' => $version_name,
            'url' => $apkUrl,
            'obligatoria' => $obligatoria,
            'novedades' => $novedades
        ];

        file_put_contents(__DIR__ . '/../config/version.json', json_encode($newData, JSON_PRETTY_PRINT));

        $_SESSION['mensaje_exito'] = "Configuración de actualización guardada correctamente.";
        header('Location: ' . BASE_URL . '/actualizar-app');
        exit;
    }
}
