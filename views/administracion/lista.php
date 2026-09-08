<?php $tituloPagina = 'Areas administrativas'; require __DIR__ . '/../layout_header.php'; ?>
<div class="page-heading">
  <div><p class="eyebrow">Administracion</p><h1>Areas administrativas</h1></div>
  <span class="count-pill"><?= count($areas) ?> registradas</span>
</div>

<?php if (!empty($_SESSION['mensaje'])): ?>
  <div class="flash flash-ok" role="status"><?= e($_SESSION['mensaje']) ?></div>
  <?php unset($_SESSION['mensaje']); ?>
<?php endif; ?>
<?php if (!empty($_SESSION['error_admin'])): ?>
  <div class="flash flash-error" role="alert"><?= e($_SESSION['error_admin']) ?></div>
  <?php unset($_SESSION['error_admin']); ?>
<?php endif; ?>

<div class="card border-0 shadow-sm p-3 mb-4">
  <p class="mb-2">Enlace del cuestionario web publico (sin login) para contestarla en remoto:</p>
  <?= enlace_copiable(url_absoluta('/encuesta-oficina')) ?>
</div>

<details class="panel disclosure" open>
  <summary class="panel-title">Nueva area</summary>
  <form method="POST" action="<?= BASE_URL ?>/administracion/crear" class="form-grid">
    <?= Csrf::campo() ?>
    <label class="field"><span>Nombre</span><input class="form-control" type="text" name="nombre" required maxlength="120" placeholder="Ej. Recursos Humanos"></label>
    <div class="field field--full"><button class="btn btn-primary" type="submit">Crear area</button></div>
  </form>
</details>

<div class="section-intro"><h2>Listado</h2></div>
<div class="table-responsive card border-0 shadow-sm"><table class="table table-hover align-middle mb-0">
  <thead><tr><th>Area</th><th>Encuestas</th><th>Estado</th><th>Acciones</th></tr></thead>
  <tbody>
  <?php foreach ($areas as $a): $aid = (int) $a['id']; $n = $conteos[$aid] ?? 0; ?>
  <tr>
    <td>
      <form method="POST" action="<?= BASE_URL ?>/administracion/editar" class="inline-form">
        <?= Csrf::campo() ?>
        <input type="hidden" name="id" value="<?= $aid ?>">
        <input class="form-control form-control-sm d-inline-block w-auto" type="text" name="nombre" value="<?= e($a['nombre']) ?>" maxlength="120" required>
        <button class="btn btn-sm btn-primary" type="submit">Guardar</button>
      </form>
    </td>
    <td><?= $n ?></td>
    <td>
      <?php if ($a['activo']): ?><span class="badge text-bg-success">Activa</span>
      <?php else: ?><span class="badge text-bg-secondary">Inactiva</span><?php endif; ?>
    </td>
    <td>
      <?php if ($a['activo']): ?>
      <form method="POST" action="<?= BASE_URL ?>/administracion/desactivar" class="inline-form">
        <?= Csrf::campo() ?>
        <input type="hidden" name="id" value="<?= $aid ?>">
        <button class="btn btn-sm btn-outline-secondary" type="submit">Desactivar</button>
      </form>
      <?php else: ?>
      <form method="POST" action="<?= BASE_URL ?>/administracion/activar" class="inline-form">
        <?= Csrf::campo() ?>
        <input type="hidden" name="id" value="<?= $aid ?>">
        <button class="btn btn-sm btn-outline-success" type="submit">Activar</button>
      </form>
      <?php endif; ?>
      <form method="POST" action="<?= BASE_URL ?>/administracion/eliminar" class="inline-form"
            onsubmit="return confirm('<?= $n > 0 ? 'Esta area tiene encuestas: se desactivara en vez de borrarse. Continuar?' : 'Borrar esta area?' ?>')">
        <?= Csrf::campo() ?>
        <input type="hidden" name="id" value="<?= $aid ?>">
        <button class="btn btn-sm btn-danger" type="submit">Eliminar</button>
      </form>
    </td>
  </tr>
  <?php endforeach; ?>
  <?php if (!$areas): ?>
  <tr><td colspan="4">Todavia no hay areas. Crea la primera arriba.</td></tr>
  <?php endif; ?>
  </tbody>
</table></div>
<?php require __DIR__ . '/../layout_footer.php'; ?>
