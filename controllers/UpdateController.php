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

        // Si el archivo excede post_max_size, PHP vacia $_POST y $_FILES
        // por completo sin generar ningun error de $_FILES -- hay que
        // detectarlo aparte revisando el Content-Length de la petición.
        if (empty($_POST) && empty($_FILES) && (int)($_SERVER['CONTENT_LENGTH'] ?? 0) > 0) {
            $_SESSION['error_actualizar_app'] = 'El archivo es demasiado grande para el límite del servidor (post_max_size). Contacta al administrador.';
            header('Location: ' . BASE_URL . '/actualizar-app');
            exit;
        }

        $version_code = (int)($_POST['version_code'] ?? 0);
        $version_name = $_POST['version_name'] ?? '';
        $obligatoria = isset($_POST['obligatoria']);
        $novedades = $_POST['novedades'] ?? '';

        $configFile = __DIR__ . '/../config/version.json';
        $oldData = file_exists($configFile) ? json_decode(file_get_contents($configFile), true) : [];
        $apkUrl = $oldData['url'] ?? '';

        $rutaDestino = __DIR__ . '/../public/updates/app-release.apk';
        $urlCorrecta = "https://fieldserviceplus.alwaysdata.net/nps/updates/app-release.apk";

        // Autocorregir la URL si ya existe un APK en disco pero la URL
        // guardada quedo mal armada (ej. con /public/ de mas, que no
        // corresponde al docroot real -- ver logo.png y demas assets
        // que se sirven como /nps/assets/... sin /public/).
        if (file_exists($rutaDestino) && $apkUrl !== $urlCorrecta) {
            $apkUrl = $urlCorrecta;
        }

        // Manejar subida de APK
        $archivoSubido = $_FILES['apk'] ?? null;
        $huboIntentoDeSubida = $archivoSubido && $archivoSubido['error'] !== UPLOAD_ERR_NO_FILE;

        if ($huboIntentoDeSubida) {
            if ($archivoSubido['error'] !== UPLOAD_ERR_OK) {
                $_SESSION['error_actualizar_app'] = self::mensajeErrorSubida($archivoSubido['error']);
                header('Location: ' . BASE_URL . '/actualizar-app');
                exit;
            }

            $extension = strtolower(pathinfo($archivoSubido['name'], PATHINFO_EXTENSION));
            if ($extension !== 'apk') {
                $_SESSION['error_actualizar_app'] = 'El archivo debe tener extensión .apk';
                header('Location: ' . BASE_URL . '/actualizar-app');
                exit;
            }

            if (!is_dir(dirname($rutaDestino))) {
                mkdir(dirname($rutaDestino), 0755, true);
            }

            if (!move_uploaded_file($archivoSubido['tmp_name'], $rutaDestino)) {
                $_SESSION['error_actualizar_app'] = 'No se pudo guardar el archivo en el servidor. Revisa permisos de escritura en public/updates.';
                header('Location: ' . BASE_URL . '/actualizar-app');
                exit;
            }

            $apkUrl = $urlCorrecta;
        }

        $newData = [
            'version_code' => $version_code,
            'version_name' => $version_name,
            'url' => $apkUrl,
            'obligatoria' => $obligatoria,
            'novedades' => $novedades
        ];

        if (file_put_contents($configFile, json_encode($newData, JSON_PRETTY_PRINT)) === false) {
            $_SESSION['error_actualizar_app'] = 'No se pudo guardar config/version.json. Revisa permisos de escritura.';
            header('Location: ' . BASE_URL . '/actualizar-app');
            exit;
        }

        $_SESSION['mensaje_exito'] = $huboIntentoDeSubida
            ? "APK subido y configuración guardada correctamente."
            : "Configuración guardada correctamente (sin cambiar el APK).";
        header('Location: ' . BASE_URL . '/actualizar-app');
        exit;
    }

    private static function mensajeErrorSubida(int $codigo): string
    {
        switch ($codigo) {
            case UPLOAD_ERR_INI_SIZE:
            case UPLOAD_ERR_FORM_SIZE:
                return 'El archivo excede el tamaño máximo permitido por el servidor. Contacta al administrador para aumentar el límite.';
            case UPLOAD_ERR_PARTIAL:
                return 'La subida se interrumpió a la mitad. Intenta de nuevo.';
            case UPLOAD_ERR_NO_TMP_DIR:
                return 'Falta carpeta temporal en el servidor.';
            case UPLOAD_ERR_CANT_WRITE:
                return 'No se pudo escribir el archivo en disco.';
            case UPLOAD_ERR_EXTENSION:
                return 'Una extensión de PHP detuvo la subida del archivo.';
            default:
                return 'Error desconocido al subir el archivo (código ' . $codigo . ').';
        }
    }
}
