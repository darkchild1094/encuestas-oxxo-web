<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Login - Encuestas OXXO</title>
  <link rel="icon" type="image/svg+xml" href="<?= BASE_URL ?>/assets/favicon-pulso-ti.svg">
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/style.css">
</head>
<body class="login-page">
<main class="login-box">
  <div class="login-brand">
    <img class="logo-oxxo" src="<?= BASE_URL ?>/assets/logo.png" alt="OXXO">
    <span class="pulso-lockup">
      <img class="logo-pulso" src="<?= BASE_URL ?>/assets/logo_pulso_ti.png" alt="">
    </span>
  </div>
  <p class="eyebrow">Acceso operativo</p>
  <h1>Bienvenido de vuelta</h1>
  <p class="login-copy">Administra la operación y consulta las respuestas de tus tiendas.</p>
  <?php if (!empty($_SESSION['error_login'])): ?>
    <p class="error"><?= htmlspecialchars($_SESSION['error_login']) ?></p>
    <?php unset($_SESSION['error_login']); ?>
  <?php endif; ?>
  <form method="POST" action="<?= BASE_URL ?>/login">
    <label>Correo <input type="email" name="correo" placeholder="nombre@oxxo.com" required autofocus></label>
    <label>Contraseña <input type="password" name="password" placeholder="Escribe tu contraseña" required></label>
    <button type="submit">Entrar al panel <span aria-hidden="true">&rarr;</span></button>
  </form>
</main>
</body>
</html>
