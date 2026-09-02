<?php require __DIR__ . '/layout_header.php'; ?>

<div class="page-heading">
  <div>
    <p class="eyebrow">Webmaster</p>
    <h1>Resumen del sistema</h1>
  </div>
</div>

<section class="kpi-row" aria-label="Conteos generales">
  <article class="kpi"><span class="kpi-label">Usuarios</span><span class="kpi-value"><?= number_format((int) $conteos['usuarios']) ?></span><span class="kpi-foot"><?= number_format((int) $conteos['pendientes_password']) ?> con password pendiente</span></article>
  <article class="kpi"><span class="kpi-label">Tiendas</span><span class="kpi-value"><?= number_format((int) $conteos['tiendas']) ?></span><span class="kpi-foot"><?= number_format((int) $conteos['plazas']) ?> plazas</span></article>
  <article class="kpi"><span class="kpi-label">Encuestas</span><span class="kpi-value"><?= number_format((int) $conteos['encuestas']) ?></span><span class="kpi-foot"><?= number_format((int) $conteos['encuestas_7d']) ?> en 7 dias</span></article>
  <article class="kpi"><span class="kpi-label">Sesiones app activas</span><span class="kpi-value"><?= $tokensActivos === null ? 'n/d' : number_format($tokensActivos) ?></span><span class="kpi-foot">Tokens sin expirar</span></article>
</section>

<div class="card-grid">
  <section class="panel">
    <h2 class="panel-title">Usuarios por rol</h2>
    <?= barras_html(array_map(static fn($r) => [$r['rol'], (float) $r['total']], $usuariosPorRol), (float) max(1, max(array_map(static fn($r) => (int) $r['total'], $usuariosPorRol)))) ?>
  </section>

  <section class="panel">
    <h2 class="panel-title">App publicada</h2>
    <dl class="data-list">
      <div><dt>Version</dt><dd><?= e($versionApp['version_name'] ?? 'n/d') ?> <small>(build <?= e((string) ($versionApp['version_code'] ?? '?')) ?>)</small></dd></div>
      <div><dt>Tipo</dt><dd><?= !empty($versionApp['obligatoria']) ? '<span class="badge-tag badge-danger">Obligatoria</span>' : '<span class="badge-tag">Opcional</span>' ?></dd></div>
      <div><dt>APK</dt><dd class="mono-wrap"><?= e($versionApp['url'] ?? 'No definida') ?></dd></div>
      <div><dt>Encuestas 30 dias</dt><dd><?= number_format((int) $conteos['encuestas_30d']) ?></dd></div>
    </dl>
    <a class="btn btn-outline" href="<?= BASE_URL ?>/actualizar-app"><i class="fa-solid fa-mobile-screen-button" aria-hidden="true"></i> Gestionar actualizacion</a>
  </section>
</div>

<section class="panel">
  <h2 class="panel-title">Ultimas encuestas recibidas</h2>
  <?php if ($ultimasEncuestas): ?>
  <div class="table-wrap">
    <table class="data-table">
      <thead><tr><th>Fecha</th><th>Tienda</th><th>Plaza</th></tr></thead>
      <tbody>
        <?php foreach ($ultimasEncuestas as $row): ?>
          <tr><td><?= e($row['fecha']) ?></td><td><?= e($row['tienda']) ?></td><td><?= e($row['plaza']) ?></td></tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php else: ?>
    <p class="chart-empty">Todavia no hay encuestas registradas.</p>
  <?php endif; ?>
</section>

<?php require __DIR__ . '/layout_footer.php'; ?>
