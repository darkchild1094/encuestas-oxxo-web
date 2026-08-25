<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

class EstadisticasApiController
{
    private function noAutorizado(): void
    {
        http_response_code(401);
        echo json_encode(['error' => 'token invalido o vencido']);
    }

    private function requiereAti(): bool
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            $this->noAutorizado();
            return false;
        }
        if ($usuario['rol_nombre'] !== 'ATI') {
            http_response_code(403);
            echo json_encode(['error' => 'solo el rol ATI puede consultar estadisticas']);
            return false;
        }
        return true;
    }

    private function promediosDesdeSql($sql, $params): array
    {
        $pdo = Database::conexion();
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $filas = $stmt->fetchAll();

        $datos = [];
        foreach ($filas as $f) {
            $datos[] = [
                'pregunta_id' => (int) ($f['pregunta_id'] ?? 0),
                'pregunta_texto' => $f['pregunta_texto'] ?? '',
                'promedio' => round((float) ($f['promedio'] ?? 0), 1),
                'total_encuestas' => (int) ($f['total_encuestas'] ?? 0)
            ];
        }
        return $datos;
    }

    private function agregarRangoFecha(string &$sql, array &$params): void
    {
        foreach (['desde', 'hasta'] as $campo) {
            $valor = $_GET[$campo] ?? '';
            $fecha = DateTime::createFromFormat('!Y-m-d', $valor);
            if (!$fecha || $fecha->format('Y-m-d') !== $valor) {
                continue;
            }

            if ($campo === 'desde') {
                $sql .= ' AND e.fecha_creacion_local >= :desde';
            } else {
                $sql .= ' AND e.fecha_creacion_local < DATE_ADD(:hasta, INTERVAL 1 DAY)';
            }
            $params[$campo] = $valor;
        }
    }

    // GET /api/estadisticas/pfs?plaza_id=X
    // Promedio de cada pregunta en la plaza, filtrado por encuestas
    // respondidas sobre tiendas de esa plaza.
    public function estadisticasPfs(): void
    {
        if (!$this->requiereAti()) { return; }
        $plazaId = (int) ($_GET['plaza_id'] ?? 0);

        $sql = "
            SELECT
                p.id as pregunta_id,
                p.texto as pregunta_texto,
                AVG(rd.calificacion) as promedio,
                COUNT(DISTINCT e.id) as total_encuestas
            FROM pregunta p
            JOIN respuesta_detalle rd ON rd.pregunta_id = p.id
            JOIN encuesta e ON e.id = rd.encuesta_id
            JOIN tienda t ON t.id = e.tienda_id
            WHERE t.plaza_id = :p AND p.activo = 1
            GROUP BY p.id
            ORDER BY p.es_fija ASC, p.orden ASC
        ";

        $params = ['p' => $plazaId];
        $this->agregarRangoFecha($sql, $params);
        echo json_encode($this->promediosDesdeSql($sql, $params));
    }

    // GET /api/estadisticas/region/atis?plaza_id=X
    // Promedio total de cada ATI en toda la region a la que pertenece la plaza.
    public function estadisticasRegionAtis(): void
    {
        if (!$this->requiereAti()) { return; }
        $plazaId = (int) ($_GET['plaza_id'] ?? 0);

        $sql = "
            SELECT
                u.id as pregunta_id,
                u.nombre_completo as pregunta_texto,
                AVG(rd.calificacion) as promedio,
                COUNT(DISTINCT e.id) as total_encuestas
            FROM usuario u
            JOIN tienda t ON t.asesor_ti_usuario_id = u.id
            JOIN encuesta e ON e.tienda_id = t.id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            WHERE t.plaza_id IN (
                SELECT id FROM plaza WHERE region_id = (SELECT region_id FROM plaza WHERE id = :p)
            )
            GROUP BY u.id
            ORDER BY promedio DESC
        ";

        $params = ['p' => $plazaId];
        $this->agregarRangoFecha($sql, $params);
        echo json_encode($this->promediosDesdeSql($sql, $params));
    }

    // GET /api/estadisticas/region/plazas?plaza_id=X
    // Promedio total de cada Plaza en toda la region.
    public function estadisticasRegionPlazas(): void
    {
        if (!$this->requiereAti()) { return; }
        $plazaId = (int) ($_GET['plaza_id'] ?? 0);

        $sql = "
            SELECT
                pl.id as pregunta_id,
                pl.nombre as pregunta_texto,
                AVG(rd.calificacion) as promedio,
                COUNT(DISTINCT e.id) as total_encuestas
            FROM plaza pl
            JOIN tienda t ON t.plaza_id = pl.id
            JOIN encuesta e ON e.tienda_id = t.id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            WHERE pl.region_id = (SELECT region_id FROM plaza WHERE id = :p)
            GROUP BY pl.id
            ORDER BY promedio DESC
        ";

        $params = ['p' => $plazaId];
        $this->agregarRangoFecha($sql, $params);
        echo json_encode($this->promediosDesdeSql($sql, $params));
    }
}
