<?php

require_once __DIR__ . '/../controllers/AuthController.php';
require_once __DIR__ . '/../controllers/UsuarioController.php';
require_once __DIR__ . '/../controllers/PreguntaController.php';
require_once __DIR__ . '/../controllers/RespuestaController.php';
require_once __DIR__ . '/../src/Auth.php';

Auth::iniciar();

// Detecta el prefijo real de la URL (ej. /NPS/public si XAMPP sirve
// desde htdocs/NPS/public) para que el router funcione sin importar
// en que subcarpeta este el proyecto, sin necesidad de VirtualHost.
$prefijo = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/');
$ruta = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
if ($prefijo !== '' && str_starts_with($ruta, $prefijo)) {
    $ruta = substr($ruta, strlen($prefijo));
}
if ($ruta === '') {
    $ruta = '/';
}
// Disponible en TODOS los controllers/vistas de este request (define
// crea una constante global). Con esto los redirects y los links/forms
// funcionan sin importar si el proyecto vive en la raiz del dominio o
// en una subcarpeta como /nps/public.
define('BASE_URL', $prefijo);
$metodo = $_SERVER['REQUEST_METHOD'];

// Router bien simple, mismo estilo que Inventario123: un switch por
// "METODO /ruta". Si el proyecto crece mucho se puede meter algo como
// FastRoute, pero para el tamano de este panel no hace falta.
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
];

$clave = "$metodo $ruta";

if (isset($rutas[$clave])) {
    [$clase, $accion] = $rutas[$clave];
    (new $clase())->$accion();
} else {
    http_response_code(404);
    echo '404 - ruta no encontrada';
}
