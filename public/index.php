<?php
// Router minimalista para alwaysdata sin .htaccess
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

$sessionDir = sys_get_temp_dir() . '/nps_sessions';
if (!is_dir($sessionDir)) {
    @mkdir($sessionDir, 0755, true);
}
if (is_writable($sessionDir)) {
    ini_set('session.save_path', $sessionDir);
}

require_once __DIR__ . '/../src/Auth.php';
Auth::iniciar();

require_once __DIR__ . '/../controllers/AuthController.php';
require_once __DIR__ . '/../controllers/UsuarioController.php';
require_once __DIR__ . '/../controllers/PreguntaController.php';
require_once __DIR__ . '/../controllers/RespuestaController.php';
require_once __DIR__ . '/../controllers/UpdateController.php';

// En Alwaysdata sin .htaccess, REQUEST_URI incluye la ruta completa
$ruta = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Quitar /nps del inicio si existe
if (str_starts_with($ruta, '/nps')) {
    $ruta = substr($ruta, 4);
}
// Quitar /public del inicio si existe
if (str_starts_with($ruta, '/public')) {
    $ruta = substr($ruta, 7);
}

if ($ruta === '' || $ruta === '/') {
    $ruta = '/';
}

define('BASE_URL', '/nps');
$metodo = $_SERVER['REQUEST_METHOD'];

$rutas = [
    'GET /login' => [AuthController::class, 'mostrarLogin'],
    'POST /login' => [AuthController::class, 'procesarLogin'],
    'GET /logout' => [AuthController::class, 'logout'],
    'GET /cambiar-password' => [AuthController::class, 'mostrarCambiarPassword'],
    'POST /cambiar-password' => [AuthController::class, 'procesarCambiarPassword'],
    'GET /' => [AuthController::class, 'inicio'],
    'GET /respuestas' => [RespuestaController::class, 'index'],
    'GET /respuestas/exportar' => [RespuestaController::class, 'exportarExcel'],
    'GET /usuarios' => [UsuarioController::class, 'index'],
    'POST /usuarios/crear' => [UsuarioController::class, 'crear'],
    'POST /usuarios/editar-datos' => [UsuarioController::class, 'editarDatos'],
    'POST /usuarios/cambiar-rol' => [UsuarioController::class, 'cambiarRol'],
    'POST /usuarios/cambiar-plaza' => [UsuarioController::class, 'cambiarPlaza'],
    'POST /usuarios/restablecer-password' => [UsuarioController::class, 'restablecerPassword'],
    'POST /usuarios/eliminar' => [UsuarioController::class, 'eliminar'],
    'GET /preguntas' => [PreguntaController::class, 'index'],
    'POST /preguntas/crear' => [PreguntaController::class, 'crear'],
    'POST /preguntas/editar' => [PreguntaController::class, 'editar'],
    'POST /preguntas/eliminar' => [PreguntaController::class, 'eliminar'],

    // Actualización de App
    'GET /actualizar-app' => [UpdateController::class, 'index'],
    'POST /actualizar-app/procesar' => [UpdateController::class, 'procesar'],
];

$clave = "$metodo $ruta";

if (isset($rutas[$clave])) {
    [$clase, $accion] = $rutas[$clave];
    (new $clase())->$accion();
} else {
    http_response_code(404);
    echo '404 - ruta no encontrada';
}
?>
