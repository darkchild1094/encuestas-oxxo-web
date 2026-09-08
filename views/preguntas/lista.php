<?php $tituloPagina = 'Preguntas'; require __DIR__ . '/../layout_header.php'; ?>
<div class="page-heading">
  <div><p class="eyebrow">Configuración</p><h1>Preguntas</h1></div>
</div>

<nav class="nav nav-pills mb-4" aria-label="Tipo de encuesta">
  <a class="nav-link <?= $ambito === 'tiendas' ? 'active' : '' ?>" href="<?= BASE_URL ?>/preguntas?ambito=tiendas">Tiendas</a>
  <a class="nav-link <?= $ambito === 'oficina' ? 'active' : '' ?>" href="<?= BASE_URL ?>/preguntas?ambito=oficina">Oficina</a>
</nav>

<?php if ($ambito === 'oficina'): ?>
<div class="card border-0 shadow-sm p-3 mb-4">
  <p class="mb-2">Enlace del cuestionario web publico (sin login) para contestar la encuesta de oficina en remoto:</p>
  <?= enlace_copiable(url_absoluta('/encuesta-oficina')) ?>
</div>
<?php endif; ?>

<?php if ($ambito === 'tiendas'): ?>
<form method="GET" action="<?= BASE_URL ?>/preguntas" class="card border-0 shadow-sm p-3 mb-4">
  <input type="hidden" name="ambito" value="tiendas">
  <div class="row align-items-end g-3">
    <div class="col-12 col-md-8 col-lg-6">
      <label class="form-label" for="plaza_id">Plaza</label>
      <select class="form-select" id="plaza_id" name="plaza_id" onchange="this.form.submit()">
      <?php foreach ($plazas as $p): ?>
        <option value="<?= $p['id'] ?>" <?= $p['id'] == $plazaId ? 'selected' : '' ?>>
          <?= htmlspecialchars("{$p['negocio']} / {$p['region']} / {$p['nombre']}") ?>
        </option>
      <?php endforeach; ?>
      </select>
    </div>
  </div>
</form>
<?php endif; ?>

<?php if ($cuestionario): ?>
<?php $tituloListado = $ambito === 'oficina' ? 'Oficina' : htmlspecialchars($cuestionario['nombre']); ?>
<div class="section-intro"><h2>Nueva pregunta &mdash; <?= $tituloListado ?></h2></div>
<form method="POST" action="<?= BASE_URL ?>/preguntas/crear" class="card border-0 shadow-sm p-3 mb-4">
  <?= Csrf::campo() ?>
  <input type="hidden" name="cuestionario_id" value="<?= $cuestionario['id'] ?>">
  <input type="hidden" name="plaza_id" value="<?= $plazaId ?>">
  <input type="hidden" name="ambito" value="<?= e($ambito) ?>">
  <div class="row align-items-end g-3">
    <div class="col-12 col-md-7"><label class="form-label" for="texto">Texto</label><input class="form-control" id="texto" type="text" name="texto" required maxlength="255"></div>
    <div class="col-12 col-md-2"><label class="form-label" for="orden">Orden</label><input class="form-control" id="orden" type="number" name="orden" value="<?= count($preguntas) + 1 ?>"></div>
    <div class="col-12 col-md-auto"><button class="btn btn-primary" type="submit">Agregar</button></div>
  </div>
</form>

<div class="table-responsive card border-0 shadow-sm"><table class="table table-hover align-middle mb-0">
  <tr><th>Orden</th><th>Pregunta</th><th>Acciones</th></tr>
  <?php foreach ($preguntas as $p): ?>
  <tr>
    <td colspan="3">
      <form method="POST" action="<?= BASE_URL ?>/preguntas/editar" class="inline-form">
        <?= Csrf::campo() ?>
        <input type="hidden" name="id" value="<?= $p['id'] ?>">
        <input type="hidden" name="plaza_id" value="<?= $plazaId ?>">
        <input type="hidden" name="ambito" value="<?= e($ambito) ?>">
        <input class="form-control form-control-sm d-inline-block w-auto" type="number" name="orden" value="<?= $p['orden'] ?>" <?= $p['es_fija'] ? 'disabled' : '' ?>>
        <input class="form-control form-control-sm d-inline-block question-input" type="text" name="texto" value="<?= htmlspecialchars($p['texto']) ?>">
        <?php if ($p['es_fija']): ?>
          <span class="badge text-bg-warning">fija &mdash; siempre penultima</span>
        <?php endif; ?>
        <button class="btn btn-sm btn-primary" type="submit">Guardar</button>
      </form>
      <?php if (!$p['es_fija']): ?>
      <form method="POST" action="<?= BASE_URL ?>/preguntas/eliminar" class="inline-form" onsubmit="return confirm('¿Quitar esta pregunta?')">
        <?= Csrf::campo() ?>
        <input type="hidden" name="id" value="<?= $p['id'] ?>">
        <input type="hidden" name="plaza_id" value="<?= $plazaId ?>">
        <input type="hidden" name="ambito" value="<?= e($ambito) ?>">
        <button type="submit" class="btn btn-sm btn-outline-danger">Quitar</button>
      </form>
      <?php endif; ?>
    </td>
  </tr>
  <?php endforeach; ?>
  <?php if (!$preguntas): ?>
  <tr><td colspan="3">Todavia no hay preguntas para <?= $ambito === 'oficina' ? 'la encuesta de oficina' : 'esta plaza' ?>.</td></tr>
  <?php endif; ?>
</table></div>
<p class="ok alert alert-info mt-3">El comentario opcional siempre va al final, despues de todas las preguntas -- no es parte de este listado.</p>
<?php elseif ($ambito === 'oficina'): ?>
<p class="alert alert-warning">No se pudo preparar la encuesta de oficina. Corre la migración <code>migracion_cuestionario_oficina.sql</code>.</p>
<?php else: ?>
<p class="alert alert-warning">No hay plazas registradas.</p>
<?php endif; ?>
<?php require __DIR__ . '/../layout_footer.php'; ?>
