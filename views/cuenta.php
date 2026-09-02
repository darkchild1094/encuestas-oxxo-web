<?php require __DIR__ . '/layout_header.php'; ?>

<div class="page-heading">
  <div>
    <p class="eyebrow">Mi perfil</p>
    <h1>Mi cuenta</h1>
  </div>
</div>

<div class="card-grid">
  <section class="panel">
    <h2 class="panel-title">Datos</h2>
    <dl class="data-list">
      <div><dt>Nombre</dt><dd><?= e($cuenta['nombre_completo'] ?: 'Sin nombre') ?></dd></div>
      <div><dt>Correo</dt><dd><?= e($cuenta['correo']) ?></dd></div>
      <div><dt>Rol</dt><dd><span class="rol-tag rol-tag--solid"><?= e($cuenta['rol']) ?></span></dd></div>
      <div><dt>Plaza</dt><dd><?= e($cuenta['plaza'] ?: 'Sin asignar (acceso global)') ?></dd></div>
      <div><dt>Alta</dt><dd><?= e($cuenta['fecha_registro']) ?></dd></div>
    </dl>
  </section>

  <section class="panel">
    <h2 class="panel-title">Cambiar contrasena</h2>
    <form method="POST" action="<?= BASE_URL ?>/mi-cuenta/password" class="stacked-form" autocomplete="off">
      <?= Csrf::campo() ?>
      <label class="field">
        <span>Contrasena actual</span>
        <input class="form-control" type="password" name="password_actual" required autocomplete="current-password">
      </label>
      <label class="field">
        <span>Nueva contrasena</span>
        <input class="form-control" type="password" name="password" minlength="8" required autocomplete="new-password">
      </label>
      <label class="field">
        <span>Confirmar nueva</span>
        <input class="form-control" type="password" name="password_confirmar" minlength="8" required autocomplete="new-password">
      </label>
      <p class="field-hint">Minimo 8 caracteres. Usa algo distinto a contrasenas que ya hayas usado.</p>
      <button class="btn btn-primary" type="submit">Guardar contrasena</button>
    </form>
  </section>
</div>

<?php require __DIR__ . '/layout_footer.php'; ?>
