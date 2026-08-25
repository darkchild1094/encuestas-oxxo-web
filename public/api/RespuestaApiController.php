<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

// Lista de respuestas de todas las tiendas de la plaza del ATI autenticado.
class RespuestaApiController
{

    public function listar(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['error' => 'token invalido o vencido']);
            return;
        }
        if (!$usuario['ve_resultados_tiendas']) {
            http_response_code(403);
            echo json_encode(['error' => 'este rol no ve resultados de tiendas']);
            return;
        }
        if ($usuario['rol_nombre'] !== 'ATI') {
            http_response_code(403);
            echo json_encode(['error' => 'solo el rol ATI puede consultar este historial']);
            return;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            SELECT
                e.id AS encuesta_id, e.folio, e.fecha_creacion_local, e.comentario,
                t.nombre AS tienda, t.codigo AS tienda_codigo,
                ati.id AS ati_id, ati.nombre_completo AS ati_nombre,
                preg.texto AS pregunta, rd.calificacion
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            LEFT JOIN usuario ati ON ati.id = t.asesor_ti_usuario_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            WHERE (:es_ati_global = 1 OR t.plaza_id = :plaza_id)
            ORDER BY e.fecha_creacion_local DESC, preg.es_fija ASC, preg.orden
        ');
        $esAtiGlobal = (int) $usuario['id'] === 128;
        if (!$esAtiGlobal && $usuario['plaza_id'] === null) {
            echo json_encode([]);
            return;
        }
        $stmt->execute([
            'es_ati_global' => $esAtiGlobal ? 1 : 0,
            'plaza_id' => $usuario['plaza_id'],
        ]);
        echo json_encode($stmt->fetchAll());
    }
}
