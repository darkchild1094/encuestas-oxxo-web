<?php
$rol = $_SESSION['rol'] ?? '';
$nombreCompleto = $_SESSION['nombre_completo'] ?? '';
$fotoPerfil = $_SESSION['foto_perfil'] ?? null;
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Encuestas OXXO - Panel</title>
  <link rel="icon" type="image/svg+xml" href="<?= BASE_URL ?>/assets/favicon-pulso-ti.svg">
  <?php require __DIR__ . '/bootstrap.php'; ?>
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/style.css">
</head>
<body>
<nav class="topnav navbar navbar-expand-lg">
  <a class="brand" href="<?= BASE_URL ?>/">
    <img class="logo-oxxo" src="<?= BASE_URL ?>/assets/logo.png" alt="OXXO">
    <span class="pulso-lockup">
      <img class="logo-pulso" src="<?= BASE_URL ?>/assets/logo_pulso_ti.png" alt="Pulso TI">
    </span>
  </a>
  <div class="nav-links navbar-nav">
  <?php if (($_SESSION['rol'] ?? '') === 'ATI' && !empty($_SESSION['ve_resultados_tiendas'])): ?>
    <a class="nav-link" href="<?= BASE_URL ?>/respuestas">Respuestas de tiendas</a>
  <?php endif; ?>
  <?php if (!empty($_SESSION['gestiona_preguntas'])): ?>
    <a class="nav-link" href="<?= BASE_URL ?>/preguntas">Preguntas</a>
  <?php endif; ?>
  <?php if (!empty($_SESSION['gestiona_usuarios'])): ?>
    <a class="nav-link" href="<?= BASE_URL ?>/usuarios">Usuarios</a>
  <?php endif; ?>
  <?php if (($_SESSION['rol'] ?? '') === 'WEBMASTER'): ?>
    <a class="nav-link" href="<?= BASE_URL ?>/actualizar-app">Actualizar App</a>
  <?php endif; ?>
  </div>
  <span class="usuario-actual">
    <?php if ($fotoPerfil): ?>
      <img src="<?= BASE_URL ?>/<?= htmlspecialchars($fotoPerfil) ?>" alt="" class="avatar-nav">
    <?php else: ?>
      <span class="avatar-nav avatar-placeholder"><?= htmlspecialchars(mb_strtoupper(mb_substr($nombreCompleto ?: '?', 0, 1))) ?></span>
    <?php endif; ?>
    <?= htmlspecialchars($nombreCompleto ?: 'Sin nombre') ?>
  </span>
  <span class="rol-tag"><?= htmlspecialchars($rol) ?></span>
  <a class="logout-link" href="<?= BASE_URL ?>/logout">Salir</a>
</nav>
<main class="page-shell">
