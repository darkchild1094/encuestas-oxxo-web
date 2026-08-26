<?php

declare(strict_types=1);

require_once __DIR__ . '/XlsxWriter.php';
require_once __DIR__ . '/MiniZip.php';

use Reportes\XlsxWriter;

/**
 * Arma el .xlsx completo de resultados: resumen con KPIs, desglose por
 * region, por ATI (plaza y region), por PFS (individual y por region), y
 * el detalle crudo -- respetando el mismo alcance de permisos que ya usa
 * RespuestaController (ATI ve solo su plaza, salvo el ATI global id 128).
 */
class ReporteRespuestas
{
    // Mismo heuristico que usa la app Android (esPreguntaDePfs) para
    // identificar la pregunta que califica al PFS/ingeniero -- no hay
    // columna dedicada en `pregunta` todavia.
    private const FILTRO_PREGUNTA_PFS = "(preg.texto LIKE '%PFS%' OR preg.texto LIKE '%Prestador de Field Service%')";

    private PDO $pdo;
    private bool $esAtiGlobal;
    private ?int $plazaSesionId;
    private array $filtros;

    public function __construct(PDO $pdo, bool $esAtiGlobal, ?int $plazaSesionId, array $filtros)
    {
        $this->pdo = $pdo;
        $this->esAtiGlobal = $esAtiGlobal;
        $this->plazaSesionId = $plazaSesionId;
        $this->filtros = $filtros;
    }

    public function generar(array $filasDetalle): string
    {
        $w = new XlsxWriter();

        $this->hojaResumen($w);
        $this->hojaPorRegion($w);
        $this->hojaAtiPorPlaza($w);
        $this->hojaAtiPorRegion($w);
        $this->hojaResultadosPorPfs($w);
        $this->hojaPfsPorRegion($w);
        $this->hojaDetalle($w, $filasDetalle);

        return $w->generar();
    }

    // ---------------------------------------------------------------
    // Filtro base compartido por todas las consultas de este reporte
    // ---------------------------------------------------------------

    private function whereBase(): array
    {
        $sql = ' WHERE 1 = 1 ';
        $params = [];

        if (!$this->esAtiGlobal) {
            $sql .= ' AND t.plaza_id = :sesion_plaza_id ';
            $params['sesion_plaza_id'] = $this->plazaSesionId;
        }
        if (!empty($this->filtros['plaza_id'])) {
            $sql .= ' AND p.id = :filtro_plaza_id ';
            $params['filtro_plaza_id'] = $this->filtros['plaza_id'];
        }
        if (!empty($this->filtros['desde'])) {
            $sql .= ' AND e.fecha_creacion_local >= :desde ';
            $params['desde'] = $this->filtros['desde'] . ' 00:00:00';
        }
        if (!empty($this->filtros['hasta'])) {
            $sql .= ' AND e.fecha_creacion_local <= :hasta ';
            $params['hasta'] = $this->filtros['hasta'] . ' 23:59:59';
        }

        return [$sql, $params];
    }

    private function consultar(string $sql, array $params): array
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private function redondear($valor, int $decimales = 1): float
    {
        return $valor === null ? 0.0 : round((float) $valor, $decimales);
    }

    // ---------------------------------------------------------------
    // 1. Resumen: KPIs generales + grafica por region
    // ---------------------------------------------------------------

    private function hojaResumen(XlsxWriter $w): void
    {
        [$whereSql, $params] = $this->whereBase();

        $sqlKpis = "
            SELECT COUNT(DISTINCT e.id) AS total_encuestas,
                   COUNT(DISTINCT t.id) AS tiendas_participantes,
                   AVG(CASE WHEN preg.es_fija = 1 THEN rd.calificacion END) AS promedio_general
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            {$whereSql}
        ";
        $kpis = $this->consultar($sqlKpis, $params)[0] ?? ['total_encuestas' => 0, 'tiendas_participantes' => 0, 'promedio_general' => 0];

        $sqlPorRegion = "
            SELECT r.nombre AS region,
                   COUNT(DISTINCT e.id) AS total_encuestas,
                   AVG(CASE WHEN preg.es_fija = 1 THEN rd.calificacion END) AS promedio_general
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN region r ON r.id = p.region_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            {$whereSql}
            GROUP BY r.id
            ORDER BY r.nombre
        ";
        $porRegion = $this->consultar($sqlPorRegion, $params);

        $filasKpi = [
            ['Total de encuestas', (string) (int) $kpis['total_encuestas'], ''],
            ['Tiendas participantes', (string) (int) $kpis['tiendas_participantes'], ''],
            ['Promedio general (calificación de TI)', number_format($this->redondear($kpis['promedio_general']), 1), '/ 10'],
        ];
        $w->agregarHoja('Resumen', [
            ['titulo' => 'Indicador'],
            ['titulo' => 'Valor'],
            ['titulo' => ''],
        ], $filasKpi, false);

        $filasRegion = array_map(fn($r) => [
            $r['region'],
            (int) $r['total_encuestas'],
            $this->redondear($r['promedio_general']),
        ], $porRegion);

        $idx = $w->agregarHoja('Resumen por región', [
            ['titulo' => 'Región'],
            ['titulo' => 'Total encuestas', 'formato' => 'entero'],
            ['titulo' => 'Promedio general', 'formato' => 'numero'],
        ], $filasRegion);

        if ($filasRegion) {
            $w->agregarGraficaBarras($idx, 'Promedio general por región', 'Región', ['Promedio general']);
        }
    }

    // ---------------------------------------------------------------
    // 2. Por región (negocio, tiendas, promedio general y de todas las preguntas)
    // ---------------------------------------------------------------

    private function hojaPorRegion(XlsxWriter $w): void
    {
        [$whereSql, $params] = $this->whereBase();

        $sql = "
            SELECT r.nombre AS region, n.nombre AS negocio,
                   COUNT(DISTINCT t.id) AS tiendas_encuestadas,
                   COUNT(DISTINCT e.id) AS total_encuestas,
                   AVG(CASE WHEN preg.es_fija = 1 THEN rd.calificacion END) AS promedio_general,
                   AVG(rd.calificacion) AS promedio_todas_preguntas
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN region r ON r.id = p.region_id
            JOIN negocio n ON n.id = r.negocio_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            {$whereSql}
            GROUP BY r.id, n.id
            ORDER BY r.nombre
        ";
        $filas = $this->consultar($sql, $params);

        $datos = array_map(fn($r) => [
            $r['region'],
            $r['negocio'],
            (int) $r['tiendas_encuestadas'],
            (int) $r['total_encuestas'],
            $this->redondear($r['promedio_general']),
            $this->redondear($r['promedio_todas_preguntas']),
        ], $filas);

        $idx = $w->agregarHoja('Por Región', [
            ['titulo' => 'Región'],
            ['titulo' => 'Negocio'],
            ['titulo' => 'Tiendas encuestadas', 'formato' => 'entero'],
            ['titulo' => 'Total encuestas', 'formato' => 'entero'],
            ['titulo' => 'Promedio general', 'formato' => 'numero'],
            ['titulo' => 'Promedio todas las preguntas', 'formato' => 'numero'],
        ], $datos);

        if ($datos) {
            $w->agregarGraficaBarras($idx, 'Promedio por región', 'Región', ['Promedio general', 'Promedio todas las preguntas']);
        }
    }

    // ---------------------------------------------------------------
    // 3. ATI por plaza
    // ---------------------------------------------------------------

    private function filasAti(): array
    {
        [$whereSql, $params] = $this->whereBase();

        $sql = "
            SELECT ati.id AS ati_id, ati.nombre_completo AS ati_nombre,
                   p.id AS plaza_id, p.nombre AS plaza, r.nombre AS region,
                   COUNT(DISTINCT t.id) AS tiendas_encuestadas,
                   COUNT(DISTINCT e.id) AS total_encuestas,
                   AVG(CASE WHEN preg.es_fija = 1 THEN rd.calificacion END) AS promedio_general
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN region r ON r.id = p.region_id
            JOIN usuario ati ON ati.id = t.asesor_ti_usuario_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            {$whereSql}
            GROUP BY ati.id, p.id, r.id
            ORDER BY p.nombre, ati_nombre
        ";
        $filas = $this->consultar($sql, $params);

        // Tiendas asignadas en total (tenga o no encuestas en el periodo),
        // para que se note si un ATI trae pocas encuestadas de las que le tocan.
        $sqlAsignadas = "
            SELECT t.asesor_ti_usuario_id AS ati_id, COUNT(*) AS total
            FROM tienda t
            JOIN plaza p ON p.id = t.plaza_id
            WHERE t.asesor_ti_usuario_id IS NOT NULL
            " . (!$this->esAtiGlobal ? ' AND t.plaza_id = :sesion_plaza_id' : '') . (!empty($this->filtros['plaza_id']) ? ' AND p.id = :filtro_plaza_id' : '') . "
            GROUP BY t.asesor_ti_usuario_id
        ";
        $paramsAsignadas = [];
        if (!$this->esAtiGlobal) {
            $paramsAsignadas['sesion_plaza_id'] = $this->plazaSesionId;
        }
        if (!empty($this->filtros['plaza_id'])) {
            $paramsAsignadas['filtro_plaza_id'] = $this->filtros['plaza_id'];
        }
        $asignadasPorAti = [];
        foreach ($this->consultar($sqlAsignadas, $paramsAsignadas) as $fila) {
            $asignadasPorAti[(int) $fila['ati_id']] = (int) $fila['total'];
        }

        foreach ($filas as &$fila) {
            $fila['tiendas_asignadas'] = $asignadasPorAti[(int) $fila['ati_id']] ?? 0;
        }
        unset($fila);

        return $filas;
    }

    private function hojaAtiPorPlaza(XlsxWriter $w): void
    {
        $filas = $this->filasAti();

        $datos = array_map(fn($r) => [
            $r['ati_nombre'] ?? '(sin nombre)',
            $r['plaza'],
            (int) $r['tiendas_asignadas'],
            (int) $r['tiendas_encuestadas'],
            (int) $r['total_encuestas'],
            $this->redondear($r['promedio_general']),
        ], $filas);

        $idx = $w->agregarHoja('ATI por Plaza', [
            ['titulo' => 'ATI'],
            ['titulo' => 'Plaza'],
            ['titulo' => 'Tiendas asignadas', 'formato' => 'entero'],
            ['titulo' => 'Tiendas encuestadas', 'formato' => 'entero'],
            ['titulo' => 'Total encuestas', 'formato' => 'entero'],
            ['titulo' => 'Promedio general', 'formato' => 'numero'],
        ], $datos);

        if ($datos) {
            $w->agregarGraficaBarras($idx, 'Promedio general por ATI', 'ATI', ['Promedio general']);
        }
    }

    // ---------------------------------------------------------------
    // 4. ATI por región (mismo dato, agrupado/ordenado por región con subtotal)
    // ---------------------------------------------------------------

    private function hojaAtiPorRegion(XlsxWriter $w): void
    {
        $filas = $this->filasAti();

        usort($filas, fn($a, $b) => [$a['region'], $a['ati_nombre']] <=> [$b['region'], $b['ati_nombre']]);

        $datos = [];
        $regionActual = null;
        $acumTiendas = 0;
        $acumEncuestas = 0;
        $sumaPromedios = 0.0;
        $contadorAtis = 0;

        $cerrarSubtotal = function () use (&$datos, &$regionActual, &$acumTiendas, &$acumEncuestas, &$sumaPromedios, &$contadorAtis) {
            if ($regionActual !== null && $contadorAtis > 0) {
                $datos[] = [
                    'Subtotal ' . $regionActual, '', $acumTiendas, $acumEncuestas,
                    round($sumaPromedios / $contadorAtis, 1),
                ];
            }
        };

        foreach ($filas as $r) {
            if ($r['region'] !== $regionActual) {
                $cerrarSubtotal();
                $regionActual = $r['region'];
                $acumTiendas = 0;
                $acumEncuestas = 0;
                $sumaPromedios = 0.0;
                $contadorAtis = 0;
            }
            $promedio = $this->redondear($r['promedio_general']);
            $datos[] = [$r['region'], $r['ati_nombre'] ?? '(sin nombre)', (int) $r['tiendas_encuestadas'], (int) $r['total_encuestas'], $promedio];
            $acumTiendas += (int) $r['tiendas_encuestadas'];
            $acumEncuestas += (int) $r['total_encuestas'];
            $sumaPromedios += $promedio;
            $contadorAtis++;
        }
        $cerrarSubtotal();

        $w->agregarHoja('ATI por Región', [
            ['titulo' => 'Región'],
            ['titulo' => 'ATI'],
            ['titulo' => 'Tiendas encuestadas', 'formato' => 'entero'],
            ['titulo' => 'Total encuestas', 'formato' => 'entero'],
            ['titulo' => 'Promedio general', 'formato' => 'numero'],
        ], $datos);
    }

    // ---------------------------------------------------------------
    // 5. Resultados por PFS (segun la pregunta que evalua al PFS)
    // ---------------------------------------------------------------

    private function hojaResultadosPorPfs(XlsxWriter $w): void
    {
        [$whereSql, $params] = $this->whereBase();
        $filtroPfs = self::FILTRO_PREGUNTA_PFS;

        $sql = "
            SELECT u.id AS pfs_id, u.nombre_completo AS pfs_nombre,
                   p.nombre AS plaza, r.nombre AS region,
                   COUNT(rd.id) AS total_respuestas,
                   AVG(rd.calificacion) AS promedio_pfs
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN region r ON r.id = p.region_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id AND {$filtroPfs}
            LEFT JOIN usuario u ON u.id = e.usuario_id
            {$whereSql}
            GROUP BY u.id, p.id, r.id
            ORDER BY promedio_pfs DESC
        ";
        $filas = $this->consultar($sql, $params);

        $datos = array_map(fn($r) => [
            $r['pfs_nombre'] ?? '(usuario eliminado)',
            $r['plaza'],
            $r['region'],
            (int) $r['total_respuestas'],
            $this->redondear($r['promedio_pfs']),
        ], $filas);

        $idx = $w->agregarHoja('Resultados por PFS', [
            ['titulo' => 'PFS (técnico)'],
            ['titulo' => 'Plaza'],
            ['titulo' => 'Región'],
            ['titulo' => 'Total respuestas', 'formato' => 'entero'],
            ['titulo' => 'Promedio PFS', 'formato' => 'numero'],
        ], $datos);

        if ($datos) {
            $w->agregarGraficaBarras($idx, 'Promedio de satisfacción por PFS', 'PFS (técnico)', ['Promedio PFS']);
        }
    }

    // ---------------------------------------------------------------
    // 6. PFS por región (mismo indicador, rollup por región)
    // ---------------------------------------------------------------

    private function hojaPfsPorRegion(XlsxWriter $w): void
    {
        [$whereSql, $params] = $this->whereBase();
        $filtroPfs = self::FILTRO_PREGUNTA_PFS;

        $sql = "
            SELECT r.nombre AS region,
                   COUNT(rd.id) AS total_respuestas,
                   AVG(rd.calificacion) AS promedio_pfs
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN region r ON r.id = p.region_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id AND {$filtroPfs}
            {$whereSql}
            GROUP BY r.id
            ORDER BY r.nombre
        ";
        $filas = $this->consultar($sql, $params);

        $datos = array_map(fn($r) => [
            $r['region'],
            (int) $r['total_respuestas'],
            $this->redondear($r['promedio_pfs']),
        ], $filas);

        $idx = $w->agregarHoja('PFS por Región', [
            ['titulo' => 'Región'],
            ['titulo' => 'Total respuestas', 'formato' => 'entero'],
            ['titulo' => 'Promedio PFS', 'formato' => 'numero'],
        ], $datos);

        if ($datos) {
            $w->agregarGraficaBarras($idx, 'Promedio PFS por región', 'Región', ['Promedio PFS']);
        }
    }

    // ---------------------------------------------------------------
    // 7. Detalle crudo (una fila por respuesta, para auditoria)
    // ---------------------------------------------------------------

    private function hojaDetalle(XlsxWriter $w, array $filasDetalle): void
    {
        $datos = array_map(fn($f) => [
            $f['folio'] ?? '',
            $f['fecha_creacion_local'],
            $f['negocio'],
            $f['region'],
            $f['plaza'],
            $f['tienda'],
            $f['ati_nombre'] ?? 'Sin ATI asignado',
            $f['usuario'] ?? '(usuario eliminado)',
            $f['pregunta'],
            (int) $f['calificacion'],
            $f['comentario'] ?? '',
        ], $filasDetalle);

        $w->agregarHoja('Detalle', [
            ['titulo' => 'Folio'],
            ['titulo' => 'Fecha'],
            ['titulo' => 'Negocio'],
            ['titulo' => 'Región'],
            ['titulo' => 'Plaza'],
            ['titulo' => 'Tienda'],
            ['titulo' => 'ATI'],
            ['titulo' => 'PFS (usuario)'],
            ['titulo' => 'Pregunta'],
            ['titulo' => 'Calificación', 'formato' => 'entero'],
            ['titulo' => 'Comentario'],
        ], $datos);
    }
}
