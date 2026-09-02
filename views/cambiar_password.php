<?php require __DIR__ . '/layout_header.php'; ?>
<div class="password-card card border-0 shadow-sm mx-auto p-4">
<div class="page-heading"><div><p class="eyebrow">Seguridad</p><h1>Cambiar password</h1></div></div>
<p>Es tu primer acceso o te restablecieron la password. Pon una nueva antes de seguir.</p>
<?php if (!empty($_SESSION['error_password'])): ?>
  <p class="error alert alert-danger" role="alert"><?= htmlspecialchars($_SESSION['error_password']) ?></p>
  <?php unset($_SESSION['error_password']); ?>
<?php endif; ?>
<form method="POST" action="<?= BASE_URL ?>/cambiar-password" class="password-form">
  <?= Csrf::campo() ?>
  <label class="form-label" for="password">Nueva password</label><input class="form-control mb-3" id="password" type="password" name="password" minlength="8" required>
  <label class="form-label" for="password_confirmar">Confirmar</label><input class="form-control mb-4" id="password_confirmar" type="password" name="password_confirmar" minlength="8" required>
  <button class="btn btn-primary w-100" type="submit">Guardar</button>
</form>
</div>
<?php require __DIR__ . '/layout_footer.php'; ?>
