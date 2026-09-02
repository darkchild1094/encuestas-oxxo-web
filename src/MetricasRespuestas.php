<?php

declare(strict_types=1);

/**
 * Provee los mismos indicadores que el reporte Excel (ReporteRespuestas)
 * pero como arreglos PHP, para poder pintarlos en el panel web (dashboard)
 * sin volver a bajar el detalle crudo ni depender del XlsxWriter.
 *
 * Respeta el alcance de permisos del ATI: el ATI de plaza solo ve su plaza;
 * el ATI global (id 128) ve todo. Mismos filtros opcionales de fecha/plaza
 * que usa RespuestaController.
 */
final class MetricasRespuestas
{
    private const FILTRO_PREGUNTA_PFS =
        "(preg.texto LIKE '%PFS%' OR preg.texto LIKE '%Prestador de Field Service%')";

    private PDO $pdo;
    private bool $esAtiGlobal;
    private ?int $plazaSesionId;
    private array $filtros;

    public function __construct(PDO $pdo, bool $esAtiGlobal, ?int $plazaSesionId, array $filtros = [])
    {
        $this->pdo = $pdo;
        $this->esAtiGlobal = $esAtiGlobal;
        $this->plazaSesionId = $plazaSesionId;
        $this->filtros = $filtros;
    }

    /** @return array{sql:string, params:array<string,mixed>} */
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
            $params['filtro_plaza_id'] = (int) $this->filtros['plaza_id'];
        }
        if (!empty($this->filtros['desde'])) {
            $sql .= ' AND e.fecha_creacion_local >= :desde ';
            $params['desde'] = $this->filtros['desde'] . ' 00:00:00';
        }
        if (!empty($this->filtros['hasta'])) {
            $sql .= ' AND e.fecha_creacion_local <= :hasta ';
            $params['hasta'] = $this->filtros['hasta'] . ' 23:59:59';
        }
        return ['sql' => $sql, 'params' => $params];
    }

    private function consultar(string $sql, array $params): array
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private static function num($v, int $dec = 1): float
    {
        return $v === null ? 0.0 : round((float) $v, $dec);
    }

    /** @return array{total_encuestas:int, tiendas_participantes:int, promedio_general:float, total_comentarios:int} */
    public function kpis(): array
    {
        ['sql' => $w, 'params' => $p] = $this->whereBase();
        $fila = $this->consultar("
            SELECT COUNT(DISTINCT e.id) AS total_encuestas,
                   COUNT(DISTINCT t.id) AS tiendas_participantes,
                   AVG(CASE WHEN preg.es_fija = 1 THEN rd.calificacion END) AS promedio_general,
                   COUNT(DISTINCT CASE WHEN e.comentario IS NOT NULL AND e.comentario <> '' THEN e.id END) AS total_comentarios
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            {$w}
        ", $p)[0] ?? [];

        return [
            'total_encuestas' => (int) ($fila['total_encuestas'] ?? 0),
            'tiendas_participantes' => (int) ($fila['tiendas_participantes'] ?? 0),
            'promedio_general' => self::num($fila['promedio_general'] ?? 0),
            'total_comentarios' => (int) ($fila['total_comentarios'] ?? 0),
        ];
    }

    /** Reparto de la calificacion fija de TI en promotores/pasivos/detractores (estilo NPS). */
    public function distribucionNps(): array
    {
        ['sql' => $w, 'params' => $p] = $this->whereBase();
        $fila = $this->consultar("
            SELECT
              SUM(CASE WHEN rd.calificacion >= 9 THEN 1 ELSE 0 END) AS promotores,
              SUM(CASE WHEN rd.calificacion BETWEEN 7 AND 8 THEN 1 ELSE 0 END) AS pasivos,
              SUM(CASE WHEN rd.calificacion <= 6 THEN 1 ELSE 0 END) AS detractores,
              COUNT(*) AS total
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id AND preg.es_fija = 1
            {$w}
        ", $p)[0] ?? [];

        $promotores = (int) ($fila['promotores'] ?? 0);
        $pasivos = (int) ($fila['pasivos'] ?? 0);
        $detractores = (int) ($fila['detractores'] ?? 0);
        $total = (int) ($fila['total'] ?? 0);
        $nps = $total > 0 ? round((($promotores - $detractores) / $total) * 100) : 0;

        return compact('promotores', 'pasivos', 'detractores', 'total') + ['nps' => (int) $nps];
    }

    /** @return list<array{region:string, total_encuestas:int, promedio:float}> */
    public function porRegion(): array
    {
        ['sql' => $w, 'params' => $p] = $this->whereBase();
        $filas = $this->consultar("
            SELECT r.nombre AS region,
                   COUNT(DISTINCT e.id) AS total_encuestas,
                   AVG(CASE WHEN preg.es_fija = 1 THEN rd.calificacion END) AS promedio
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN region r ON r.id = p.region_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            {$w}
            GROUP BY r.id
            ORDER BY promedio DESC, r.nombre
        ", $p);

        return array_map(static fn($f) => [
            'region' => (string) $f['region'],
            'total_encuestas' => (int) $f['total_encuestas'],
            'promedio' => self::num($f['promedio']),
        ], $filas);
    }

    /**
     * Una fila por ATI (ya consolidado entre plazas con promedio ponderado
     * por numero de encuestas, igual que la grafica del Excel).
     * @return list<array{ati:string, total_encuestas:int, promedio:float}>
     */
    public function porAti(): array
    {
        ['sql' => $w, 'params' => $p] = $this->whereBase();
        $filas = $this->consultar("
            SELECT COALESCE(ati.nombre_completo, '(sin nombre)') AS ati,
                   COUNT(DISTINCT e.id) AS total_encuestas,
                   AVG(CASE WHEN preg.es_fija = 1 THEN rd.calificacion END) AS promedio
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN usuario ati ON ati.id = t.asesor_ti_usuario_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            {$w}
            GROUP BY ati.id
            ORDER BY promedio DESC, ati
        ", $p);

        return array_map(static fn($f) => [
            'ati' => (string) $f['ati'],
            'total_encuestas' => (int) $f['total_encuestas'],
            'promedio' => self::num($f['promedio']),
        ], $filas);
    }

    /**
     * Una fila por PFS (tecnico), consolidado entre plazas.
     * @return list<array{pfs:string, total_respuestas:int, promedio:float}>
     */
    public function porPfs(): array
    {
        ['sql' => $w, 'params' => $p] = $this->whereBase();
        $filtroPfs = self::FILTRO_PREGUNTA_PFS;
        $filas = $this->consultar("
            SELECT COALESCE(u.nombre_completo, '(usuario eliminado)') AS pfs,
                   COUNT(rd.id) AS total_respuestas,
                   AVG(rd.calificacion) AS promedio
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id AND {$filtroPfs}
            LEFT JOIN usuario u ON u.id = e.usuario_id
            {$w}
            GROUP BY u.id
            ORDER BY promedio DESC, pfs
        ", $p);

        return array_map(static fn($f) => [
            'pfs' => (string) $f['pfs'],
            'total_respuestas' => (int) $f['total_respuestas'],
            'promedio' => self::num($f['promedio']),
        ], $filas);
    }

    /**
     * Serie temporal por dia (para una mini grafica de tendencia).
     * @return list<array{dia:string, total:int, promedio:float}>
     */
    public function tendenciaDiaria(int $dias = 30): array
    {
        ['sql' => $w, 'params' => $p] = $this->whereBase();
        $p['dias'] = $dias;
        $filas = $this->consultar("
            SELECT DATE(e.fecha_creacion_local) AS dia,
                   COUNT(DISTINCT e.id) AS total,
                   AVG(CASE WHEN preg.es_fija = 1 THEN rd.calificacion END) AS promedio
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            {$w}
            AND e.fecha_creacion_local >= (CURRENT_DATE - INTERVAL :dias DAY)
            GROUP BY DATE(e.fecha_creacion_local)
            ORDER BY dia
        ", $p);

        return array_map(static fn($f) => [
            'dia' => (string) $f['dia'],
            'total' => (int) $f['total'],
            'promedio' => self::num($f['promedio']),
        ], $filas);
    }

    /** Plazas disponibles para el filtro (todas si es global, solo la suya si no). */
    public function plazasParaFiltro(): array
    {
        if (!$this->esAtiGlobal) {
            $filas = $this->consultar(
                'SELECT id, nombre FROM plaza WHERE id = :id',
                ['id' => $this->plazaSesionId]
            );
        } else {
            $filas = $this->consultar(
                'SELECT p.id, p.nombre FROM plaza p ORDER BY p.nombre',
                []
            );
        }
        return $filas;
    }
}
