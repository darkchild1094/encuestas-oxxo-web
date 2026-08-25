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
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/style.css">
</head>
<body>
<nav class="topnav">
  <a class="brand" href="<?= BASE_URL ?>/">
    <span class="brand-mark">OXXO</span>
    <span><strong>Encuestas</strong><small>Pulso TI</small></span>
  </a>
  <div class="nav-links">
  <?php if (($_SESSION['rol'] ?? '') === 'ATI' && !empty($_SESSION['ve_resultados_tiendas'])): ?>
    <a href="<?= BASE_URL ?>/respuestas">Respuestas de tiendas</a>
  <?php endif; ?>
  <?php if (!empty($_SESSION['gestiona_preguntas'])): ?>
    <a href="<?= BASE_URL ?>/preguntas">Preguntas</a>
  <?php endif; ?>
  <?php if (!empty($_SESSION['gestiona_usuarios'])): ?>
    <a href="<?= BASE_URL ?>/usuarios">Usuarios</a>
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
