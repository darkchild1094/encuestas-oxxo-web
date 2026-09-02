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

require_once __DIR__ . '/../src/Http.php';
require_once __DIR__ . '/../src/Csrf.php';
require_once __DIR__ . '/../src/Auth.php';

Http::cabecerasSeguridad();
Auth::iniciar();

require_once __DIR__ . '/../controllers/AuthController.php';
require_once __DIR__ . '/../controllers/UsuarioController.php';
require_once __DIR__ . '/../controllers/PreguntaController.php';
require_once __DIR__ . '/../controllers/RespuestaController.php';
require_once __DIR__ . '/../controllers/DashboardController.php';
require_once __DIR__ . '/../controllers/ResumenController.php';
require_once __DIR__ . '/../controllers/CuentaController.php';
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
$ruta = rtrim($ruta, '/') ?: '/';

define('BASE_URL', '/nps');
$metodo = $_SERVER['REQUEST_METHOD'];

$rutas = [
    'GET /login' => [AuthController::class, 'mostrarLogin'],
    'POST /login' => [AuthController::class, 'procesarLogin'],
    'GET /logout' => [AuthController::class, 'logout'],
    'POST /logout' => [AuthController::class, 'logout'],
    'GET /cambiar-password' => [AuthController::class, 'mostrarCambiarPassword'],
    'POST /cambiar-password' => [AuthController::class, 'procesarCambiarPassword'],
    'GET /' => [AuthController::class, 'inicio'],

    'GET /mi-cuenta' => [CuentaController::class, 'index'],
    'POST /mi-cuenta/password' => [CuentaController::class, 'cambiarPassword'],

    'GET /respuestas' => [RespuestaController::class, 'index'],
    'GET /respuestas/exportar' => [RespuestaController::class, 'exportarExcel'],
    'GET /respuestas/exportar-csv' => [RespuestaController::class, 'exportarCsv'],
    'GET /dashboard' => [DashboardController::class, 'index'],

    'GET /resumen' => [ResumenController::class, 'index'],

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
    // CSRF: toda accion que cambia estado va por POST y debe traer el
    // token del formulario. Se valida aqui, en un solo lugar, antes de
    // instanciar cualquier controlador.
    if ($metodo === 'POST') {
        Csrf::exigir();
    }
    [$clase, $accion] = $rutas[$clave];
    (new $clase())->$accion();
} else {
    http_response_code(404);
    header('Content-Type: text/html; charset=utf-8');
    $inicio = BASE_URL . '/';
    echo '<!doctype html><html lang="es"><meta charset="utf-8">'
        . '<meta name="viewport" content="width=device-width, initial-scale=1">'
        . '<title>Pagina no encontrada</title>'
        . '<body style="font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;'
        . 'min-height:100vh;margin:0;display:flex;align-items:center;justify-content:center;'
        . 'background:#fffdf9;color:#241213">'
        . '<div style="text-align:center;padding:2rem;max-width:30rem">'
        . '<p style="font-size:3.5rem;font-weight:800;margin:0;color:#d70b16">404</p>'
        . '<h1 style="font-size:1.25rem;margin:.5rem 0 1rem">No encontramos esta pagina</h1>'
        . '<p style="color:#6b6260;margin:0 0 1.5rem">La direccion no existe o cambio de lugar.</p>'
        . '<a href="' . htmlspecialchars($inicio, ENT_QUOTES) . '" '
        . 'style="display:inline-block;padding:.7rem 1.2rem;border-radius:.5rem;background:#d70b16;'
        . 'color:#fff;text-decoration:none;font-weight:700">Ir al inicio</a>'
        . '</div></body></html>';
}
