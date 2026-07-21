<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

// Catalogo negocio/region/plaza/tienda para el selector en cascada
// de la app. Cualquier usuario autenticado puede leerlo (no hace
// falta permiso especial, solo un token valido).
class CatalogoApiController
{
    private function noAutorizado(): void
    {
        http_response_code(401);
        echo json_encode(['error' => 'token invalido o vencido']);
    }

    public function negocios(): void
    {
        if (!ApiAuth::usuarioDesdeToken()) { $this->noAutorizado(); return; }
        $pdo = Database::conexion();
        $filas = $pdo->query('SELECT id, nombre, es_default FROM negocio ORDER BY nombre')->fetchAll();
        foreach ($filas as &$f) { $f['es_default'] = (bool) $f['es_default']; }
        echo json_encode($filas);
    }

    public function regiones(): void
    {
        if (!ApiAuth::usuarioDesdeToken()) { $this->noAutorizado(); return; }
        $pdo = Database::conexion();
        $stmt = $pdo->prepare('SELECT id, nombre, cr, es_default FROM region WHERE negocio_id = :n ORDER BY nombre');
        $stmt->execute(['n' => (int) ($_GET['negocio_id'] ?? 0)]);
        $filas = $stmt->fetchAll();
        foreach ($filas as &$f) { $f['es_default'] = (bool) $f['es_default']; }
        echo json_encode($filas);
    }

    public function plazas(): void
    {
        if (!ApiAuth::usuarioDesdeToken()) { $this->noAutorizado(); return; }
        $pdo = Database::conexion();
        $stmt = $pdo->prepare('SELECT id, nombre, cr, es_default FROM plaza WHERE region_id = :r ORDER BY nombre');
        $stmt->execute(['r' => (int) ($_GET['region_id'] ?? 0)]);
        $filas = $stmt->fetchAll();
        foreach ($filas as &$f) { $f['es_default'] = (bool) $f['es_default']; }
        echo json_encode($filas);
    }

    public function tiendas(): void
    {
        if (!ApiAuth::usuarioDesdeToken()) { $this->noAutorizado(); return; }
        $pdo = Database::conexion();
        $stmt = $pdo->prepare('SELECT id, nombre, codigo FROM tienda WHERE plaza_id = :p ORDER BY nombre');
        $stmt->execute(['p' => (int) ($_GET['plaza_id'] ?? 0)]);
        echo json_encode($stmt->fetchAll());
    }

    public function roles(): void
    {
        if (!ApiAuth::usuarioDesdeToken()) { $this->noAutorizado(); return; }
        $pdo = Database::conexion();
        $filas = $pdo->query('SELECT id, nombre FROM rol ORDER BY nombre')->fetchAll();
        echo json_encode($filas);
    }
}
