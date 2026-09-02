<?php require __DIR__ . '/layout_header.php'; ?>
<?php
$qsExport = http_build_query(array_filter([
    'plaza_id' => $_GET['plaza_id'] ?? null,
    'desde' => $_GET['desde'] ?? null,
    'hasta' => $_GET['hasta'] ?? null,
]));
$npsTotal = max(1, (int) $nps['total']);
?>

<div class="page-heading">
  <div>
    <p class="eyebrow">Resultados</p>
    <h1>Dashboard</h1>
  </div>
  <div class="heading-actions">
    <a class="btn btn-outline" href="<?= BASE_URL ?>/respuestas<?= $qsExport ? '?' . e($qsExport) : '' ?>"><i class="fa-solid fa-table-list" aria-hidden="true"></i> Ver detalle</a>
    <a class="btn btn-secundario" href="<?= BASE_URL ?>/respuestas/exportar<?= $qsExport ? '?' . e($qsExport) : '' ?>"><i class="fa-solid fa-file-excel" aria-hidden="true"></i> Excel</a>
    <a class="btn btn-outline" href="<?= BASE_URL ?>/respuestas/exportar-csv<?= $qsExport ? '?' . e($qsExport) : '' ?>"><i class="fa-solid fa-file-csv" aria-hidden="true"></i> CSV</a>
  </div>
</div>

<form method="GET" action="<?= BASE_URL ?>/dashboard" class="filter-bar">
  <?php if (!empty($plazas)): ?>
  <label class="field">
    <span>Plaza</span>
    <select class="form-select" name="plaza_id" onchange="this.form.submit()">
      <option value="">Todas</option>
      <?php foreach ($plazas as $pl): ?>
        <option value="<?= (int) $pl['id'] ?>" <?= (($_GET['plaza_id'] ?? '') == $pl['id']) ? 'selected' : '' ?>><?= e($pl['nombre']) ?></option>
      <?php endforeach; ?>
    </select>
  </label>
  <?php endif; ?>
  <label class="field"><span>Desde</span><input class="form-control" type="date" name="desde" value="<?= e($_GET['desde'] ?? '') ?>"></label>
  <label class="field"><span>Hasta</span><input class="form-control" type="date" name="hasta" value="<?= e($_GET['hasta'] ?? '') ?>"></label>
  <div class="filter-actions">
    <button class="btn btn-primary" type="submit">Aplicar</button>
    <a class="btn btn-ghost" href="<?= BASE_URL ?>/dashboard">Limpiar</a>
  </div>
</form>

<section class="kpi-row" aria-label="Indicadores generales">
  <article class="kpi">
    <span class="kpi-label">Encuestas</span>
    <span class="kpi-value"><?= number_format($kpis['total_encuestas']) ?></span>
    <span class="kpi-foot"><?= number_format($kpis['tiendas_participantes']) ?> tiendas</span>
  </article>
  <article class="kpi">
    <span class="kpi-label">Promedio TI</span>
    <span class="kpi-value kpi-<?= clase_calificacion($kpis['promedio_general']) ?>"><?= number_format($kpis['promedio_general'], 1) ?><small>/10</small></span>
    <span class="kpi-foot">Calificacion de la pregunta fija</span>
  </article>
  <article class="kpi">
    <span class="kpi-label">NPS TI</span>
    <span class="kpi-value"><?= (int) $nps['nps'] ?></span>
    <span class="kpi-foot"><?= (int) $nps['promotores'] ?> prom. · <?= (int) $nps['detractores'] ?> detr.</span>
  </article>
  <article class="kpi">
    <span class="kpi-label">Comentarios</span>
    <span class="kpi-value"><?= number_format($kpis['total_comentarios']) ?></span>
    <span class="kpi-foot">Encuestas con texto libre</span>
  </article>
</section>

<section class="panel">
  <h2 class="panel-title">Reparto NPS (pregunta de TI)</h2>
  <div class="nps-stack" role="img" aria-label="Promotores <?= (int) $nps['promotores'] ?>, pasivos <?= (int) $nps['pasivos'] ?>, detractores <?= (int) $nps['detractores'] ?>">
    <span class="nps-seg nps-promotor" style="width:<?= round($nps['promotores'] / $npsTotal * 100, 1) ?>%"></span>
    <span class="nps-seg nps-pasivo" style="width:<?= round($nps['pasivos'] / $npsTotal * 100, 1) ?>%"></span>
    <span class="nps-seg nps-detractor" style="width:<?= round($nps['detractores'] / $npsTotal * 100, 1) ?>%"></span>
  </div>
  <ul class="nps-legend">
    <li><span class="dot dot-promotor"></span> Promotores (9-10): <strong><?= (int) $nps['promotores'] ?></strong></li>
    <li><span class="dot dot-pasivo"></span> Pasivos (7-8): <strong><?= (int) $nps['pasivos'] ?></strong></li>
    <li><span class="dot dot-detractor"></span> Detractores (0-6): <strong><?= (int) $nps['detractores'] ?></strong></li>
  </ul>
</section>

<section class="panel">
  <h2 class="panel-title">Tendencia del promedio diario <small>(ultimos 30 dias)</small></h2>
  <?= sparkline_svg(array_map(static fn($d) => (float) $d['promedio'], $tendencia)) ?>
</section>

<div class="card-grid">
  <section class="panel">
    <h2 class="panel-title">Promedio por region</h2>
    <?= barras_html(array_map(static fn($r) => [$r['region'], $r['promedio'], $r['total_encuestas']], $porRegion)) ?>
  </section>

  <section class="panel">
    <h2 class="panel-title">Promedio por ATI</h2>
    <?= barras_html(array_map(static fn($r) => [$r['ati'], $r['promedio'], $r['total_encuestas']], $porAti)) ?>
  </section>
</div>

<section class="panel">
  <h2 class="panel-title">Promedio por PFS (tecnico)</h2>
  <?= barras_html(array_map(static fn($r) => [$r['pfs'], $r['promedio'], $r['total_respuestas']], $porPfs)) ?>
</section>

<?php require __DIR__ . '/layout_footer.php'; ?>
