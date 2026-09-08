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
        // LEFT JOIN al ATI asignado (asesor_ti_usuario_id puede ser NULL,
        // sobre todo en plazas distintas a Valles): el app usa
        // ati_usuario_id === null como señal para mostrar el selector.
        $stmt = $pdo->prepare('
                 SELECT t.id, t.nombre, t.codigo, t.plaza_id, t.direccion, t.latitud, t.longitud,
                     t.asesor_ti_usuario_id,
                       u.id AS ati_usuario_id, u.nombre_completo AS ati_nombre, u.foto_perfil AS ati_foto,
                       u.genero AS ati_genero
            FROM tienda t
            LEFT JOIN usuario u ON u.id = t.asesor_ti_usuario_id
            WHERE t.plaza_id = :p
            ORDER BY t.nombre
        ');
        $stmt->execute(['p' => (int) ($_GET['plaza_id'] ?? 0)]);
        $filas = $stmt->fetchAll();
        foreach ($filas as &$f) {
            $f['id'] = (int) $f['id'];
            $f['plaza_id'] = (int) $f['plaza_id'];
            $f['latitud'] = $f['latitud'] !== null ? (float) $f['latitud'] : null;
            $f['longitud'] = $f['longitud'] !== null ? (float) $f['longitud'] : null;
            $f['asesor_ti_usuario_id'] = $f['asesor_ti_usuario_id'] !== null ? (int) $f['asesor_ti_usuario_id'] : null;
            $f['ati_usuario_id'] = $f['ati_usuario_id'] !== null ? (int) $f['ati_usuario_id'] : null;

        }
        echo json_encode($filas);
    }

    // GET /api/tiendas/ati-disponibles?plaza_id=X
    // ATIs de una plaza para el selector cuando la tienda no tiene
    // asesor_ti_usuario_id asignado. Abierto a cualquier usuario
    // encuestable (el tecnico en tienda), no solo a quien gestiona
    // usuarios -- por eso NO reutiliza UsuarioApiController::listar().
    public function atisDisponibles(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare("
            SELECT u.id, u.nombre_completo, u.foto_perfil, u.genero
            FROM usuario u
            JOIN rol r ON r.id = u.rol_id
            WHERE r.nombre = 'ATI' AND u.plaza_id = :p
            ORDER BY u.nombre_completo
        ");
        $stmt->execute(['p' => (int) ($_GET['plaza_id'] ?? 0)]);
        $filas = $stmt->fetchAll();
        foreach ($filas as &$f) {
            $f['id'] = (int) $f['id'];
        }
        echo json_encode($filas);
    }

    // POST /api/tiendas/edit
    public function editar(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }

        $datos = json_decode(file_get_contents('php://input'), true) ?? [];
        $id = (int) ($datos['id'] ?? 0);

        if (!$id) {
            http_response_code(400);
            echo json_encode(['error' => 'id de tienda es requerido']);
            return;
        }

        $pdo = Database::conexion();
        $actual = $pdo->prepare('SELECT plaza_id, codigo, nombre, direccion, latitud, longitud, asesor_ti_usuario_id FROM tienda WHERE id = :id');
        $actual->execute(['id' => $id]);
        $tienda = $actual->fetch();

        if (!$tienda) {
            http_response_code(404);
            echo json_encode(['error' => 'tienda no encontrada']);
            return;
        }

        $plazaId = array_key_exists('plaza_id', $datos) ? (int) $datos['plaza_id'] : (int) $tienda['plaza_id'];
        $codigo = $tienda['codigo'];
        $nombre = $tienda['nombre'];
        $atiUsuarioId = array_key_exists('asesor_ti_usuario_id', $datos)
            ? ($datos['asesor_ti_usuario_id'] === null ? null : (int) $datos['asesor_ti_usuario_id'])
            : (array_key_exists('ati_usuario_id', $datos) ? ($datos['ati_usuario_id'] === null ? null : (int) $datos['ati_usuario_id']) : $tienda['asesor_ti_usuario_id']);

        if (!$plazaId || $codigo === '' || $nombre === '') {
            http_response_code(422);
            echo json_encode(['error' => 'plaza_id, codigo y nombre son requeridos']);
            return;
        }

        $stmt = $pdo->prepare('
            UPDATE tienda
            SET plaza_id = :plaza_id,
                codigo = :codigo,
                nombre = :nombre,
                direccion = :d,
                latitud = :lat,
                longitud = :lng,
                asesor_ti_usuario_id = :ati
            WHERE id = :id
        ');

        $stmt->execute([
            'plaza_id' => $plazaId,
            'codigo'   => $codigo,
            'nombre'   => $nombre,
            'd'        => array_key_exists('direccion', $datos) ? $datos['direccion'] : $tienda['direccion'],
            'lat'      => array_key_exists('latitud', $datos) ? $datos['latitud'] : $tienda['latitud'],
            'lng'      => array_key_exists('longitud', $datos) ? $datos['longitud'] : $tienda['longitud'],
            'ati'      => $atiUsuarioId,
            'id'       => $id
        ]);

        echo json_encode(['success' => true]);
    }

    // POST /api/tiendas/asignar-ati  Body: { tienda_id, usuario_id }
    // Guarda la eleccion de forma PERMANENTE en la tienda: la proxima
    // vez que alguien encueste ahi, ya no se le pregunta.
    public function asignarAti(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }

        $datos = json_decode(file_get_contents('php://input'), true) ?? [];
        $tiendaId = (int) ($datos['tienda_id'] ?? 0);
        $atiUsuarioId = (int) ($datos['usuario_id'] ?? 0);

        if (!$tiendaId || !$atiUsuarioId) {
            http_response_code(400);
            echo json_encode(['error' => 'tienda_id y usuario_id son requeridos']);
            return;
        }

        // Validar que el usuario_id realmente sea ATI antes de guardarlo,
        // para no dejar la tienda apuntando a cualquier rol por error del cliente.
        $pdo = Database::conexion();
        $stmt = $pdo->prepare("
            SELECT u.id FROM usuario u JOIN rol r ON r.id = u.rol_id
            WHERE u.id = :u AND r.nombre = 'ATI'
        ");
        $stmt->execute(['u' => $atiUsuarioId]);
        if (!$stmt->fetch()) {
            http_response_code(422);
            echo json_encode(['error' => 'el usuario indicado no tiene rol ATI']);
            return;
        }

        $stmt = $pdo->prepare('UPDATE tienda SET asesor_ti_usuario_id = :u WHERE id = :t');
        $stmt->execute(['u' => $atiUsuarioId, 't' => $tiendaId]);

        echo json_encode(['success' => true]);
    }

    public function roles(): void
    {
        if (!ApiAuth::usuarioDesdeToken()) { $this->noAutorizado(); return; }
        $pdo = Database::conexion();
        $filas = $pdo->query('SELECT id, nombre FROM rol ORDER BY nombre')->fetchAll();
        echo json_encode($filas);
    }

    // GET /api/administraciones
    // Catalogo plano y global de areas administrativas para la encuesta
    // de oficina (el equivalente a /api/tiendas en la encuesta de tienda,
    // pero sin cascada: no dependen de negocio/region/plaza).
    public function administraciones(): void
    {
        if (!ApiAuth::usuarioDesdeToken()) { $this->noAutorizado(); return; }
        $pdo = Database::conexion();
        $filas = $pdo->query('SELECT id, nombre FROM administracion WHERE activo = 1 ORDER BY nombre')->fetchAll();
        foreach ($filas as &$f) { $f['id'] = (int) $f['id']; }
        echo json_encode($filas);
    }

    // POST /api/administraciones  Body: { nombre }
    // El ATI (y el webmaster) puede dar de alta areas directo desde la
    // app -- mismo permiso "contesta_oficina" que habilita responder la
    // encuesta de oficina, no gestiona_usuarios (eso seguiria limitando
    // el CRUD completo del panel web a webmaster).
    public function crearAdministracion(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) { $this->noAutorizado(); return; }
        if (!$usuario['contesta_oficina']) {
            http_response_code(403);
            echo json_encode(['error' => 'tu rol no puede dar de alta areas administrativas']);
            return;
        }

        $datos = json_decode(file_get_contents('php://input'), true) ?? [];
        $nombre = trim((string) ($datos['nombre'] ?? ''));

        if ($nombre === '' || mb_strlen($nombre) > 120) {
            http_response_code(422);
            echo json_encode(['error' => 'nombre es requerido (maximo 120 caracteres)']);
            return;
        }

        $pdo = Database::conexion();
        try {
            $stmt = $pdo->prepare('INSERT INTO administracion (nombre) VALUES (:n)');
            $stmt->execute(['n' => $nombre]);
            $id = (int) $pdo->lastInsertId();
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                http_response_code(409);
                echo json_encode(['error' => 'ya existe un area con ese nombre']);
                return;
            }
            throw $e;
        }

        echo json_encode(['id' => $id, 'nombre' => $nombre]);
    }
}
