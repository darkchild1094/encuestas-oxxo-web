<?php

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/AuthApiController.php';
require_once __DIR__ . '/SyncApiController.php';
require_once __DIR__ . '/CatalogoApiController.php';
require_once __DIR__ . '/RespuestaApiController.php';
require_once __DIR__ . '/UsuarioApiController.php';
require_once __DIR__ . '/PreguntaApiController.php';

// Deteccion robusta de la ruta para la API
$uri = $_SERVER['REQUEST_URI'];
$ruta = strtok($uri, '?'); // Quitar query string

// Si la URL contiene /api/, nos quedamos con lo que sigue a partir de ahí
if (preg_match('#(/api/.*)$#', $ruta, $m)) {
    $ruta = $m[1];
}

$metodo = $_SERVER['REQUEST_METHOD'];

// Router simple con soporte para IDs en la URL
$rutas = [
    'POST /api/login' => [AuthApiController::class, 'login'],
    'GET /api/cuestionario' => [SyncApiController::class, 'obtenerCuestionario'],
    'POST /api/encuestas' => [SyncApiController::class, 'subirEncuestas'],
    'GET /api/negocios' => [CatalogoApiController::class, 'negocios'],
    'GET /api/regiones' => [CatalogoApiController::class, 'regiones'],
    'GET /api/plazas' => [CatalogoApiController::class, 'plazas'],
    'GET /api/tiendas' => [CatalogoApiController::class, 'tiendas'],
    'GET /api/roles' => [CatalogoApiController::class, 'roles'],
    'GET /api/respuestas' => [RespuestaApiController::class, 'listar'],

    // Usuarios
    'GET /api/usuarios' => [UsuarioApiController::class, 'listar'],
    'POST /api/usuarios' => [UsuarioApiController::class, 'crear'],
    'POST /api/usuarios/edit' => [UsuarioApiController::class, 'editar'],
    'DELETE /api/usuarios' => [UsuarioApiController::class, 'eliminar'],

    // Perfil
    'POST /api/perfil/password' => [UsuarioApiController::class, 'cambiarPassword'],
    'POST /api/perfil/update' => [UsuarioApiController::class, 'actualizarPerfil'],

    // Preguntas
    'POST /api/preguntas' => [PreguntaApiController::class, 'crear'],
    'POST /api/preguntas/edit' => [PreguntaApiController::class, 'editar'],
    'DELETE /api/preguntas' => [PreguntaApiController::class, 'eliminar'],
];

$clave = "$metodo $ruta";

// Captura de IDs dinamicos: /api/xxx/12 -> clave: DELETE /api/xxx, $_GET['id']=12
if ($metodo === 'DELETE' && preg_match('#^/api/(usuarios|preguntas)/(\d+)$#', $ruta, $m)) {
    $_GET['id'] = $m[2];
    $clave = "DELETE /api/" . $m[1];
}

if (isset($rutas[$clave])) {
    [$clase, $accion] = $rutas[$clave];
    (new $clase())->$accion();
} else {
    http_response_code(404);
    echo json_encode([
        'error' => 'ruta no encontrada',
        'metodo' => $metodo,
        'ruta' => $ruta,
        'uri_original' => $uri
    ]);
}
