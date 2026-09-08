<?php

declare(strict_types=1);

require_once __DIR__ . '/XlsxWriter.php';
require_once __DIR__ . '/MiniZip.php';

use Reportes\XlsxWriter;

/**
 * Reporte .xlsx de la encuesta de OFICINA (areas administrativas). Es el
 * equivalente de ReporteRespuestas para el otro tipo de encuesta: no hay
 * tienda/plaza/region, el eje es `administracion`. Dos hojas: resumen por
 * area (con grafica) y el detalle crudo.
 */
class ReporteRespuestasOficina
{
    private PDO $pdo;
    private array $filtros;

    /** @param array{administracion_id?:mixed, desde?:mixed, hasta?:mixed} $filtros */
    public function __construct(PDO $pdo, array $filtros)
    {
        $this->pdo = $pdo;
        $this->filtros = $filtros;
    }

    public function generar(array $filasDetalle): string
    {
        $w = new XlsxWriter();
        $this->hojaResumen($w);
        $this->hojaDetalle($w, $filasDetalle);
        return $w->generar();
    }

    private function whereBase(): array
    {
        $sql = ' WHERE e.administracion_id IS NOT NULL ';
        $params = [];

        if (!empty($this->filtros['administracion_id'])) {
            $sql .= ' AND e.administracion_id = :adm ';
            $params['adm'] = $this->filtros['administracion_id'];
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

    private function redondear($valor, int $decimales = 1): float
    {
        return $valor === null ? 0.0 : round((float) $valor, $decimales);
    }

    private function hojaResumen(XlsxWriter $w): void
    {
        [$whereSql, $params] = $this->whereBase();

        $sql = "
            SELECT a.nombre AS area,
                   COUNT(DISTINCT e.id) AS total_encuestas,
                   AVG(rd.calificacion) AS promedio_general,
                   SUM(CASE WHEN rd.calificacion >= 9 THEN 1 ELSE 0 END) AS promotores,
                   SUM(CASE WHEN rd.calificacion BETWEEN 7 AND 8 THEN 1 ELSE 0 END) AS pasivos,
                   SUM(CASE WHEN rd.calificacion <= 6 THEN 1 ELSE 0 END) AS detractores,
                   COUNT(rd.id) AS total_respuestas
            FROM encuesta e
            JOIN administracion a ON a.id = e.administracion_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            {$whereSql}
            GROUP BY a.id
            ORDER BY a.nombre
        ";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $filas = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $datos = array_map(function ($r) {
            $tot = max(1, (int) $r['total_respuestas']);
            return [
                $r['area'],
                (int) $r['total_encuestas'],
                $this->redondear($r['promedio_general']),
                $this->redondear((int) $r['promotores'] * 100 / $tot),
                $this->redondear((int) $r['pasivos'] * 100 / $tot),
                $this->redondear((int) $r['detractores'] * 100 / $tot),
            ];
        }, $filas);

        $idx = $w->agregarHoja('Resumen por area', [
            ['titulo' => 'Area'],
            ['titulo' => 'Total encuestas', 'formato' => 'entero'],
            ['titulo' => 'Promedio general', 'formato' => 'numero'],
            ['titulo' => '% Promotores', 'formato' => 'numero'],
            ['titulo' => '% Pasivos', 'formato' => 'numero'],
            ['titulo' => '% Detractores', 'formato' => 'numero'],
        ], $datos);

        if ($datos) {
            $w->agregarGraficaBarras($idx, 'Promedio general por area', 'Area', ['Promedio general'], 'Total encuestas');
        }
    }

    private function hojaDetalle(XlsxWriter $w, array $filasDetalle): void
    {
        $datos = array_map(fn($f) => [
            $f['folio'] ?? '',
            $f['fecha_creacion_local'] ?? '',
            $f['administracion'] ?? '',
            $f['pregunta'] ?? '',
            (int) ($f['calificacion'] ?? 0),
            $f['comentario'] ?? '',
        ], $filasDetalle);

        $w->agregarHoja('Detalle', [
            ['titulo' => 'Folio'],
            ['titulo' => 'Fecha'],
            ['titulo' => 'Area'],
            ['titulo' => 'Pregunta'],
            ['titulo' => 'Calificacion', 'formato' => 'entero'],
            ['titulo' => 'Comentario'],
        ], $datos);
    }
}
