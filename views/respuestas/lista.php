<?php $tituloPagina = 'Respuestas'; require __DIR__ . '/../layout_header.php'; ?>
<?php
$tiendaId = $_GET['tienda_id'] ?? '';
$encuestas = [];
foreach ($filas as $fila) {
  $id = $fila['encuesta_id'];
  if (!isset($encuestas[$id])) {
    $encuestas[$id] = [
      'folio' => $fila['folio'] ?? '',
      'fecha' => $fila['fecha_creacion_local'],
      'tienda' => $fila['tienda'],
      'usuario' => $fila['usuario'] ?? '(usuario eliminado)',
      'comentario' => $fila['comentario'] ?? '',
      'respuestas' => [],
    ];
  }
  $encuestas[$id]['respuestas'][] = $fila;
}
?>
<div class="page-heading">
  <div>
    <p class="eyebrow">Plaza <?= htmlspecialchars($_SESSION['plaza_id'] ?? '') ?></p>
    <h1>Respuestas de tiendas</h1>
  </div>
  <?php if ($tiendaId): ?>
    <a class="boton-secundario btn btn-success" href="<?= BASE_URL ?>/respuestas?<?= http_build_query(array_merge($_GET, ['tienda_id' => null])) ?>">&larr; Ver tiendas</a>
  <?php endif; ?>
</div>

<?php if (!empty($atis)): ?>
<nav class="ati-tabs nav nav-tabs" aria-label="ATIs de la plaza">
  <?php foreach ($atis as $ati): ?>
    <a class="ati-tab nav-link <?= (($_GET['ati_id'] ?? '') == $ati['id']) ? 'active' : '' ?>"
       href="<?= BASE_URL ?>/respuestas?<?= http_build_query(array_merge($_GET, ['ati_id' => $ati['id'], 'tienda_id' => null])) ?>">
      <?= htmlspecialchars($ati['nombre_completo']) ?>
    </a>
  <?php endforeach; ?>
</nav>
<?php endif; ?>

<form method="GET" action="<?= BASE_URL ?>/respuestas" class="row g-3 align-items-end filter-bar">
  <?php if (!empty($_GET['ati_id'])): ?><input type="hidden" name="ati_id" value="<?= htmlspecialchars($_GET['ati_id']) ?>"><?php endif; ?>
  <div class="col-12 col-sm-6 col-lg-3"><label class="form-label" for="desde">Desde</label><input class="form-control" id="desde" type="date" name="desde" value="<?= htmlspecialchars($_GET['desde'] ?? '') ?>"></div>
  <div class="col-12 col-sm-6 col-lg-3"><label class="form-label" for="hasta">Hasta</label><input class="form-control" id="hasta" type="date" name="hasta" value="<?= htmlspecialchars($_GET['hasta'] ?? '') ?>"></div>
  <div class="col-12 col-lg-auto"><button class="btn btn-primary" type="submit">Filtrar respuestas</button></div>
  <div class="col-12 col-lg-auto"><a class="btn btn-outline" href="<?= BASE_URL ?>/dashboard?<?= http_build_query(array_intersect_key($_GET, array_flip(['desde', 'hasta', 'plaza_id']))) ?>"><i class="fa-solid fa-chart-column" aria-hidden="true"></i> Dashboard</a></div>
  <div class="col-12 col-lg-auto"><a class="boton-secundario btn btn-success" href="<?= BASE_URL ?>/respuestas/exportar?<?= http_build_query($_GET) ?>">Exportar Excel</a></div>
  <div class="col-12 col-lg-auto"><a class="btn btn-outline" href="<?= BASE_URL ?>/respuestas/exportar-csv?<?= http_build_query($_GET) ?>">CSV</a></div>
</form>

<?php if (!$tiendaId): ?>
  <div class="section-intro"><h2>Tiendas con respuestas</h2><span><?= count($tiendas) ?> tienda<?= count($tiendas) === 1 ? '' : 's' ?></span></div>
  <?php if ($tiendas): ?>
    <div class="store-grid">
      <?php foreach ($tiendas as $tienda): ?>
        <a class="store-card card border-0 shadow-sm" href="<?= BASE_URL ?>/respuestas?<?= http_build_query(array_merge($_GET, ['tienda_id' => $tienda['id']])) ?>">
          <img class="store-icon" src="<?= BASE_URL ?>/assets/ic_tienda_oxxo.svg" alt="Tienda OXXO">
          <span class="store-card-copy"><strong><?= htmlspecialchars($tienda['codigo']) ?></strong><span><?= htmlspecialchars($tienda['nombre']) ?></span></span>
          <span class="store-count"><?= $tienda['total_encuestas'] ?> encuesta<?= $tienda['total_encuestas'] === 1 ? '' : 's' ?><b>&rarr;</b></span>
        </a>
      <?php endforeach; ?>
    </div>
  <?php else: ?>
    <div class="empty-state alert alert-light"><strong>Sin respuestas todavía</strong><span>Esta selección no tiene encuestas realizadas.</span></div>
  <?php endif; ?>
<?php else: ?>
  <div class="section-intro"><h2><?= htmlspecialchars($encuestas ? reset($encuestas)['tienda'] : 'Detalle de tienda') ?></h2><span><?= count($encuestas) ?> encuesta<?= count($encuestas) === 1 ? '' : 's' ?></span></div>
  <?php if ($encuestas): ?>
    <div class="survey-list">
      <?php foreach ($encuestas as $encuesta): ?>
        <article class="survey-card card border-0 shadow-sm">
          <header class="survey-header"><div><strong>Folio <?= htmlspecialchars($encuesta['folio']) ?></strong><span><?= htmlspecialchars($encuesta['fecha']) ?> &middot; <?= htmlspecialchars($encuesta['usuario']) ?></span></div></header>
          <div class="answer-list">
            <?php foreach ($encuesta['respuestas'] as $respuesta): $cal = (int) $respuesta['calificacion']; $clase = $cal <= 6 ? 'cal-detractor' : ($cal <= 8 ? 'cal-pasivo' : 'cal-promotor'); ?>
              <div class="answer-row"><span><?= htmlspecialchars($respuesta['pregunta']) ?></span><span class="calificacion-tag <?= $clase ?>"><?= $cal ?>/10</span></div>
            <?php endforeach; ?>
          </div>
          <?php if ($encuesta['comentario'] !== ''): ?><p class="survey-comment">&ldquo;<?= htmlspecialchars($encuesta['comentario']) ?>&rdquo;</p><?php endif; ?>
        </article>
      <?php endforeach; ?>
    </div>
  <?php else: ?>
    <div class="empty-state alert alert-light"><strong>Sin respuestas para esta tienda</strong><span>Prueba otro rango de fechas.</span></div>
  <?php endif; ?>
<?php endif; ?>
<?php require __DIR__ . '/../layout_footer.php'; ?>