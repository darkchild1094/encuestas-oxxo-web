<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Login - Encuestas OXXO</title>
  <link rel="icon" type="image/svg+xml" href="<?= BASE_URL ?>/assets/favicon-pulso-ti.svg">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/style.css">
</head>
<body class="login-page">
<main class="login-box card border-0 shadow-lg">
  <div class="login-brand">
    <span class="pulso-lockup">
      <img class="logo-pulso" src="<?= BASE_URL ?>/assets/logo_pulso_ti.png" alt="Pulso TI">
    </span>
  </div>
  <div class="login-heading text-center">
    <p class="eyebrow">Acceso operativo</p>
    <h1>Bienvenido de vuelta</h1>
  </div>
  <?php if (!empty($_SESSION['error_login'])): ?>
    <p class="error alert alert-danger" role="alert"><?= htmlspecialchars($_SESSION['error_login']) ?></p>
    <?php unset($_SESSION['error_login']); ?>
  <?php endif; ?>
  <form method="POST" action="<?= BASE_URL ?>/login" class="login-form">
    <div class="mb-3">
      <label class="form-label" for="correo">Correo</label>
      <input class="form-control" id="correo" type="email" name="correo" placeholder="nombre@oxxo.com" required autofocus>
    </div>
    <div class="mb-4">
      <label class="form-label" for="password">Contraseña</label>
      <input class="form-control" id="password" type="password" name="password" placeholder="Escribe tu contraseña" required>
    </div>
    <button class="btn btn-primary w-100" type="submit">Entrar al panel <span aria-hidden="true">&rarr;</span></button>
  </form>
</main>
</body>
</html>
