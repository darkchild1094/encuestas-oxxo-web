<?php

declare(strict_types=1);

/**
 * Helpers de presentacion compartidos por las vistas del panel. Se incluye
 * una sola vez desde layout_header.php.
 */

if (!function_exists('e')) {
    /** Escape HTML corto para usar en las plantillas. */
    function e($valor): string
    {
        return htmlspecialchars((string) ($valor ?? ''), ENT_QUOTES, 'UTF-8');
    }
}

if (!function_exists('nav_activo')) {
    /** Devuelve ' active' + aria si $ruta es la pagina actual. */
    function nav_activo(string $ruta): string
    {
        $actual = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?? '/';
        $actual = preg_replace('#^/nps#', '', $actual);
        $actual = rtrim($actual, '/') ?: '/';
        return $actual === $ruta ? ' active" aria-current="page' : '';
    }
}

if (!function_exists('clase_calificacion')) {
    /** promotor / pasivo / detractor segun la escala NPS 0-10. */
    function clase_calificacion(float $valor): string
    {
        if ($valor >= 9) {
            return 'promotor';
        }
        if ($valor >= 7) {
            return 'pasivo';
        }
        return 'detractor';
    }
}

if (!function_exists('barras_html')) {
    /**
     * Grafica de barras horizontales solo con HTML+CSS (sin JS ni libs).
     * Accesible: cada barra es una fila con su valor visible.
     *
     * @param list<array{0:string,1:float,2?:int}> $filas  [etiqueta, valor, (opcional) n]
     * @param float $max  valor que representa el 100% del ancho
     */
    function barras_html(array $filas, float $max = 10.0, string $sufijo = ''): string
    {
        if (!$filas) {
            return '<p class="chart-empty">Sin datos para este filtro.</p>';
        }
        $out = '<ul class="bar-chart" role="list">';
        foreach ($filas as $fila) {
            $etiqueta = (string) ($fila[0] ?? '');
            $valor = (float) ($fila[1] ?? 0);
            $n = isset($fila[2]) ? (int) $fila[2] : null;
            $pct = $max > 0 ? max(0, min(100, ($valor / $max) * 100)) : 0;
            $clase = clase_calificacion($valor);
            $out .= '<li class="bar-row">'
                . '<span class="bar-label" title="' . e($etiqueta) . '">' . e($etiqueta) . '</span>'
                . '<span class="bar-track"><span class="bar-fill bar-' . $clase . '" style="width:' . round($pct, 1) . '%"></span></span>'
                . '<span class="bar-value">' . e(number_format($valor, 1)) . e($sufijo)
                . ($n !== null ? ' <small>(' . e((string) $n) . ')</small>' : '')
                . '</span>'
                . '</li>';
        }
        $out .= '</ul>';
        return $out;
    }
}

if (!function_exists('sparkline_svg')) {
    /**
     * Mini grafica de linea en SVG inline para una serie temporal corta.
     * @param list<float> $valores
     */
    function sparkline_svg(array $valores, int $ancho = 640, int $alto = 120, float $max = 10.0): string
    {
        $n = count($valores);
        if ($n < 2) {
            return '<p class="chart-empty">Aun no hay suficientes dias con encuestas.</p>';
        }
        $pasoX = $ancho / ($n - 1);
        $puntos = [];
        foreach (array_values($valores) as $i => $v) {
            $x = round($i * $pasoX, 1);
            $y = round($alto - (max(0, min($max, $v)) / $max) * $alto, 1);
            $puntos[] = "$x,$y";
        }
        $linea = implode(' ', $puntos);
        $area = "0,$alto " . $linea . "," . $ancho . ",$alto";
        return '<svg class="sparkline" viewBox="0 0 ' . $ancho . ' ' . $alto . '" '
            . 'preserveAspectRatio="none" role="img" aria-label="Tendencia del promedio diario">'
            . '<polygon points="' . $area . '" class="spark-area"/>'
            . '<polyline points="' . $linea . '" class="spark-line"/>'
            . '</svg>';
    }
}
