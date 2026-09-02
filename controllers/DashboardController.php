<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../src/Auth.php';
require_once __DIR__ . '/../src/MetricasRespuestas.php';

/**
 * Dashboard visual de resultados para el rol ATI. Mismos numeros que el
 * reporte Excel pero en pantalla, con graficas hechas solo con HTML/CSS/SVG
 * (sin librerias de JS). Respeta el alcance: ATI de plaza ve su plaza; el
 * ATI global (id 128) ve todo y puede filtrar por plaza.
 */
class DashboardController
{
    public function index(): void
    {
        if (($_SESSION['rol'] ?? '') !== 'ATI') {
            http_response_code(403);
            echo 'Solo el rol ATI puede ver el dashboard de resultados.';
            exit;
        }
        Auth::requierePermiso('ve_resultados_tiendas');

        $esAtiGlobal = (int) ($_SESSION['usuario_id'] ?? 0) === 128;

        $filtros = [
            'plaza_id' => $esAtiGlobal ? ($_GET['plaza_id'] ?? null) : null,
            'desde' => $this->fechaValida($_GET['desde'] ?? null),
            'hasta' => $this->fechaValida($_GET['hasta'] ?? null),
        ];

        $m = new MetricasRespuestas(
            Database::conexion(),
            $esAtiGlobal,
            $_SESSION['plaza_id'] ?? null,
            $filtros
        );

        $kpis = $m->kpis();
        $nps = $m->distribucionNps();
        $porRegion = $m->porRegion();
        $porAti = $m->porAti();
        $porPfs = $m->porPfs();
        $tendencia = $m->tendenciaDiaria(30);
        $plazas = $esAtiGlobal ? $m->plazasParaFiltro() : [];

        $tituloPagina = 'Dashboard';
        require __DIR__ . '/../views/dashboard.php';
    }

    private function fechaValida(?string $valor): ?string
    {
        $valor = trim((string) $valor);
        $d = DateTime::createFromFormat('!Y-m-d', $valor);
        return ($d && $d->format('Y-m-d') === $valor) ? $valor : null;
    }
}
