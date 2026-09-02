<?php $tituloPagina = 'Usuarios'; require __DIR__ . '/../layout_header.php'; ?>
<div class="page-heading">
  <div><p class="eyebrow">Administracion</p><h1>Usuarios</h1></div>
  <span class="count-pill"><?= count($usuarios) ?> registrados</span>
</div>

<?php if (!empty($_SESSION['mensaje'])): ?>
  <div class="flash flash-ok" role="status"><?= e($_SESSION['mensaje']) ?></div>
  <?php unset($_SESSION['mensaje']); ?>
<?php endif; ?>
<?php if (!empty($_SESSION['error_usuarios'])): ?>
  <div class="flash flash-error" role="alert"><?= e($_SESSION['error_usuarios']) ?></div>
  <?php unset($_SESSION['error_usuarios']); ?>
<?php endif; ?>

<details class="panel disclosure" open>
  <summary class="panel-title">Nuevo usuario</summary>
  <form method="POST" action="<?= BASE_URL ?>/usuarios/crear" class="form-grid" enctype="multipart/form-data">
    <?= Csrf::campo() ?>
    <label class="field"><span>Nombre completo</span><input class="form-control" type="text" name="nombre_completo" required></label>
    <label class="field"><span>Correo</span><input class="form-control" type="email" name="correo" required></label>
    <label class="field"><span>Genero</span>
      <select class="form-select" name="genero">
        <option value="">Sin especificar</option><option value="H">Hombre</option><option value="M">Mujer</option>
      </select></label>
    <label class="field"><span>Rol</span>
      <select class="form-select" name="rol_id" required>
        <?php foreach ($roles as $r): ?><option value="<?= (int) $r['id'] ?>"><?= e($r['nombre']) ?></option><?php endforeach; ?>
      </select></label>
    <label class="field"><span>Plaza</span>
      <select class="form-select" name="plaza_id">
        <option value="">Sin asignar</option>
        <?php foreach ($plazas as $p): ?><option value="<?= (int) $p['id'] ?>"><?= e("{$p['negocio']} / {$p['region']} / {$p['nombre']}") ?></option><?php endforeach; ?>
      </select></label>
    <label class="field"><span>Foto de perfil</span><input class="form-control" type="file" name="foto_perfil" accept="image/png,image/jpeg,image/webp"></label>
    <div class="field field--full"><button class="btn btn-primary" type="submit">Crear (genera password temporal)</button></div>
  </form>
</details>

<div class="section-intro"><h2>Listado</h2></div>
<div class="user-list">
  <?php foreach ($usuarios as $u): $uid = (int) $u['id']; ?>
  <article class="user-card panel">
    <header class="user-card-head">
      <?php if (!empty($u['foto_perfil'])): ?>
        <img class="user-avatar" src="<?= BASE_URL ?>/<?= e($u['foto_perfil']) ?>" alt="" width="48" height="48">
      <?php else: ?>
        <span class="user-avatar user-avatar--ph"><?= e(mb_strtoupper(mb_substr($u['nombre_completo'] ?: '?', 0, 1))) ?></span>
      <?php endif; ?>
      <div class="user-id">
        <strong><?= e($u['nombre_completo'] ?: 'Sin nombre') ?></strong>
        <span><?= e($u['correo']) ?></span>
      </div>
      <div class="user-flags">
        <span class="badge-tag"><?= e($u['rol']) ?></span>
        <span class="badge-tag <?= $u['debe_cambiar_password'] ? 'badge-warn' : 'badge-ok' ?>"><?= $u['debe_cambiar_password'] ? 'Password pendiente' : 'Password OK' ?></span>
      </div>
    </header>

    <div class="user-card-grid">
      <form method="POST" action="<?= BASE_URL ?>/usuarios/editar-datos" enctype="multipart/form-data" class="mini-form">
        <?= Csrf::campo() ?>
        <input type="hidden" name="id" value="<?= $uid ?>">
        <label class="field"><span>Nombre</span><input class="form-control form-control-sm" type="text" name="nombre_completo" value="<?= e($u['nombre_completo'] ?? '') ?>"></label>
        <label class="field"><span>Genero</span>
          <select class="form-select form-select-sm" name="genero">
            <option value="" <?= empty($u['genero']) ? 'selected' : '' ?>>Sin especificar</option>
            <option value="H" <?= $u['genero'] === 'H' ? 'selected' : '' ?>>Hombre</option>
            <option value="M" <?= $u['genero'] === 'M' ? 'selected' : '' ?>>Mujer</option>
          </select></label>
        <label class="field"><span>Foto nueva</span><input class="form-control form-control-sm" type="file" name="foto_perfil" accept="image/png,image/jpeg,image/webp"></label>
        <button class="btn btn-sm btn-primary" type="submit">Guardar datos</button>
      </form>

      <div class="mini-form">
        <form method="POST" action="<?= BASE_URL ?>/usuarios/cambiar-rol">
          <?= Csrf::campo() ?>
          <input type="hidden" name="id" value="<?= $uid ?>">
          <label class="field"><span>Rol</span>
            <select class="form-select form-select-sm" name="rol_id" onchange="this.form.submit()" <?= $uid === 128 ? 'disabled' : '' ?>>
              <?php foreach ($roles as $r): ?>
                <option value="<?= (int) $r['id'] ?>" <?= $r['nombre'] === $u['rol'] ? 'selected' : '' ?>><?= e($r['nombre']) ?></option>
              <?php endforeach; ?>
            </select></label>
        </form>
        <form method="POST" action="<?= BASE_URL ?>/usuarios/cambiar-plaza">
          <?= Csrf::campo() ?>
          <input type="hidden" name="id" value="<?= $uid ?>">
          <label class="field"><span>Plaza</span>
            <select class="form-select form-select-sm" name="plaza_id" onchange="this.form.submit()" <?= $uid === 128 ? 'disabled' : '' ?>>
              <option value="">Sin asignar</option>
              <?php foreach ($plazas as $p): ?>
                <option value="<?= (int) $p['id'] ?>" <?= $p['id'] == $u['plaza_id'] ? 'selected' : '' ?>><?= e($p['nombre']) ?></option>
              <?php endforeach; ?>
            </select></label>
        </form>
      </div>
    </div>

    <footer class="user-card-actions">
      <span class="user-meta">Alta: <?= e($u['fecha_registro']) ?></span>
      <form method="POST" action="<?= BASE_URL ?>/usuarios/restablecer-password">
        <?= Csrf::campo() ?>
        <input type="hidden" name="id" value="<?= $uid ?>">
        <button class="btn btn-sm btn-outline" type="submit">Restablecer password</button>
      </form>
      <?php if ($uid !== 128 && $uid !== (int) ($_SESSION['usuario_id'] ?? 0)): ?>
      <form method="POST" action="<?= BASE_URL ?>/usuarios/eliminar" onsubmit="return confirm('¿Borrar a <?= e($u['nombre_completo'] ?: $u['correo']) ?>?')">
        <?= Csrf::campo() ?>
        <input type="hidden" name="id" value="<?= $uid ?>">
        <button type="submit" class="btn btn-sm btn-danger">Eliminar</button>
      </form>
      <?php endif; ?>
    </footer>
  </article>
  <?php endforeach; ?>
</div>
<?php require __DIR__ . '/../layout_footer.php'; ?>
