<?php require __DIR__ . '/../layout_header.php'; ?>
<div class="page-heading"><div><p class="eyebrow">Administración</p><h1>Usuarios</h1></div></div>

<?php if (!empty($_SESSION['mensaje'])): ?>
  <p class="ok alert alert-success"><?= htmlspecialchars($_SESSION['mensaje']) ?></p>
  <?php unset($_SESSION['mensaje']); ?>
<?php endif; ?>

<div class="section-intro"><h2>Nuevo usuario</h2></div>
<form method="POST" action="<?= BASE_URL ?>/usuarios/crear" class="card border-0 shadow-sm p-3 mb-4" enctype="multipart/form-data">
 <div class="row g-3 align-items-end">
  <div class="col-12 col-md-6"><label class="form-label" for="nombre_completo">Nombre completo</label><input class="form-control" id="nombre_completo" type="text" name="nombre_completo" required></div>
  <div class="col-12 col-md-6"><label class="form-label" for="correo">Correo</label><input class="form-control" id="correo" type="email" name="correo" required></div>
  <div class="col-12 col-md-4"><label class="form-label" for="rol_id">Rol</label>
    <select class="form-select" id="rol_id" name="rol_id" required>
      <?php foreach ($roles as $r): ?>
        <option value="<?= $r['id'] ?>"><?= htmlspecialchars($r['nombre']) ?></option>
      <?php endforeach; ?>
    </select></div>
  <div class="col-12 col-md-4"><label class="form-label" for="plaza_id">Plaza</label>
    <select class="form-select" id="plaza_id" name="plaza_id">
      <option value="">Sin asignar</option>
      <?php foreach ($plazas as $p): ?>
        <option value="<?= $p['id'] ?>"><?= htmlspecialchars("{$p['negocio']} / {$p['region']} / {$p['nombre']}") ?></option>
      <?php endforeach; ?>
    </select></div>
  <div class="col-12 col-md-4"><label class="form-label" for="foto_perfil">Foto de perfil</label><input class="form-control" id="foto_perfil" type="file" name="foto_perfil" accept="image/png,image/jpeg,image/webp"></div>
  <div class="col-12"><button class="btn btn-primary" type="submit">Crear (genera password temporal)</button></div>
 </div>
</form>

<div class="section-intro"><h2>Listado</h2></div>
<div class="table-responsive card border-0 shadow-sm"><table class="table table-hover align-middle mb-0">
  <tr><th>Foto</th><th>Nombre</th><th>Correo</th><th>Rol</th><th>Plaza</th><th>Debe cambiar pass</th><th>Registro</th><th>Acciones</th></tr>
  <?php foreach ($usuarios as $u): ?>
  <tr>
    <td>
      <?php if (!empty($u['foto_perfil'])): ?>
        <img src="<?= BASE_URL ?>/<?= htmlspecialchars($u['foto_perfil']) ?>" alt="" width="40" height="40" style="border-radius:50%;object-fit:cover">
      <?php else: ?>
        &mdash;
      <?php endif; ?>
    </td>
    <td>
      <form method="POST" action="<?= BASE_URL ?>/usuarios/editar-datos" enctype="multipart/form-data" class="inline-form">
        <input type="hidden" name="id" value="<?= $u['id'] ?>">
        <input class="form-control form-control-sm mb-2" type="text" name="nombre_completo" value="<?= htmlspecialchars($u['nombre_completo'] ?? '') ?>">
        <input class="form-control form-control-sm mb-2" type="file" name="foto_perfil" accept="image/png,image/jpeg,image/webp">
        <button class="btn btn-sm btn-primary" type="submit">Guardar</button>
      </form>
    </td>
    <td><?= htmlspecialchars($u['correo']) ?></td>
    <td>
      <form method="POST" action="<?= BASE_URL ?>/usuarios/cambiar-rol">
        <input type="hidden" name="id" value="<?= $u['id'] ?>">
        <select class="form-select form-select-sm" name="rol_id" onchange="this.form.submit()">
          <?php foreach ($roles as $r): ?>
            <option value="<?= $r['id'] ?>" <?= $r['nombre'] === $u['rol'] ? 'selected' : '' ?>>
              <?= htmlspecialchars($r['nombre']) ?>
            </option>
          <?php endforeach; ?>
        </select>
      </form>
    </td>
    <td>
      <form method="POST" action="<?= BASE_URL ?>/usuarios/cambiar-plaza">
        <input type="hidden" name="id" value="<?= $u['id'] ?>">
        <select class="form-select form-select-sm" name="plaza_id" onchange="this.form.submit()">
          <option value="">Sin asignar</option>
          <?php foreach ($plazas as $p): ?>
            <option value="<?= $p['id'] ?>" <?= $p['id'] == $u['plaza_id'] ? 'selected' : '' ?>>
              <?= htmlspecialchars($p['nombre']) ?>
            </option>
          <?php endforeach; ?>
        </select>
      </form>
    </td>
    <td><span class="badge <?= $u['debe_cambiar_password'] ? 'text-bg-warning' : 'text-bg-success' ?>"><?= $u['debe_cambiar_password'] ? 'Si' : 'No' ?></span></td>
    <td><?= htmlspecialchars($u['fecha_registro']) ?></td>
    <td class="acciones">
      <form method="POST" action="<?= BASE_URL ?>/usuarios/restablecer-password">
        <input type="hidden" name="id" value="<?= $u['id'] ?>">
        <button class="btn btn-sm btn-outline-primary" type="submit">Restablecer password</button>
      </form>
      <form method="POST" action="<?= BASE_URL ?>/usuarios/eliminar" onsubmit="return confirm('¿Borrar este usuario?')">
        <input type="hidden" name="id" value="<?= $u['id'] ?>">
        <button type="submit" class="btn btn-sm btn-outline-danger">Eliminar</button>
      </form>
    </td>
  </tr>
  <?php endforeach; ?>
</table></div>
<?php require __DIR__ . '/../layout_footer.php'; ?>
