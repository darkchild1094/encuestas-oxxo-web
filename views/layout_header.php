<?php
require_once __DIR__ . '/partials/_ui.php';

$rol = $_SESSION['rol'] ?? '';
$nombreCompleto = $_SESSION['nombre_completo'] ?? '';
$fotoPerfil = $_SESSION['foto_perfil'] ?? null;
$inicial = mb_strtoupper(mb_substr($nombreCompleto !== '' ? $nombreCompleto : '?', 0, 1));

$puedeVerResultados = ($rol === 'ATI') && !empty($_SESSION['ve_resultados_tiendas']);
$flashOk = $_SESSION['_flash_ok'] ?? null;   unset($_SESSION['_flash_ok']);
$flashError = $_SESSION['_flash_error'] ?? null; unset($_SESSION['_flash_error']);
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title><?= isset($tituloPagina) ? e($tituloPagina) . ' · ' : '' ?>Encuestas OXXO</title>
  <link rel="icon" type="image/svg+xml" href="<?= BASE_URL ?>/assets/favicon-pulso-ti.svg">
  <?php require __DIR__ . '/bootstrap.php'; ?>
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/style.css">
</head>
<body>
<a class="skip-link" href="#contenido">Saltar al contenido</a>
<nav class="topnav" aria-label="Navegacion principal">
  <div class="topnav-inner">
    <a class="brand" href="<?= BASE_URL ?>/" aria-label="Inicio - Pulso TI">
      <img class="logo-oxxo" src="<?= BASE_URL ?>/assets/logo.png" alt="OXXO" width="104" height="47">
      <span class="pulso-lockup">
        <img class="logo-pulso" src="<?= BASE_URL ?>/assets/logo_pulso_ti.png" alt="Pulso TI" width="38" height="38">
      </span>
    </a>

    <button class="nav-toggle" type="button" aria-expanded="false" aria-controls="nav-menu"
            aria-label="Abrir menu" onclick="var m=document.getElementById('nav-menu');var o=this.getAttribute('aria-expanded')==='true';this.setAttribute('aria-expanded',String(!o));m.classList.toggle('is-open',!o);">
      <span class="nav-toggle-bar"></span><span class="nav-toggle-bar"></span><span class="nav-toggle-bar"></span>
    </button>

    <div class="nav-menu" id="nav-menu">
      <div class="nav-links">
        <?php if ($puedeVerResultados): ?>
          <a class="nav-link<?= nav_activo('/dashboard') ?>" href="<?= BASE_URL ?>/dashboard"><i class="fa-solid fa-chart-column" aria-hidden="true"></i> Dashboard</a>
          <a class="nav-link<?= nav_activo('/respuestas') ?>" href="<?= BASE_URL ?>/respuestas"><i class="fa-solid fa-store" aria-hidden="true"></i> Respuestas</a>
        <?php endif; ?>
        <?php if (!empty($_SESSION['gestiona_preguntas'])): ?>
          <a class="nav-link<?= nav_activo('/preguntas') ?>" href="<?= BASE_URL ?>/preguntas"><i class="fa-solid fa-list-check" aria-hidden="true"></i> Preguntas</a>
        <?php endif; ?>
        <?php if (!empty($_SESSION['gestiona_usuarios'])): ?>
          <a class="nav-link<?= nav_activo('/usuarios') ?>" href="<?= BASE_URL ?>/usuarios"><i class="fa-solid fa-users" aria-hidden="true"></i> Usuarios</a>
        <?php endif; ?>
        <?php if ($rol === 'WEBMASTER'): ?>
          <a class="nav-link<?= nav_activo('/resumen') ?>" href="<?= BASE_URL ?>/resumen"><i class="fa-solid fa-gauge-high" aria-hidden="true"></i> Resumen</a>
          <a class="nav-link<?= nav_activo('/actualizar-app') ?>" href="<?= BASE_URL ?>/actualizar-app"><i class="fa-solid fa-mobile-screen-button" aria-hidden="true"></i> Actualizar App</a>
        <?php endif; ?>
      </div>

      <div class="nav-account">
        <a class="usuario-actual<?= nav_activo('/mi-cuenta') ?>" href="<?= BASE_URL ?>/mi-cuenta">
          <?php if ($fotoPerfil): ?>
            <img src="<?= BASE_URL ?>/<?= e($fotoPerfil) ?>" alt="" class="avatar-nav">
          <?php else: ?>
            <span class="avatar-nav avatar-placeholder"><?= e($inicial) ?></span>
          <?php endif; ?>
          <span class="usuario-nombre"><?= e($nombreCompleto !== '' ? $nombreCompleto : 'Mi cuenta') ?></span>
          <span class="rol-tag"><?= e($rol) ?></span>
        </a>
        <a class="logout-link" href="<?= BASE_URL ?>/logout"><i class="fa-solid fa-arrow-right-from-bracket" aria-hidden="true"></i> Salir</a>
      </div>
    </div>
  </div>
</nav>
<main class="page-shell" id="contenido">
<?php if ($flashOk): ?><div class="flash flash-ok" role="status"><?= e($flashOk) ?></div><?php endif; ?>
<?php if ($flashError): ?><div class="flash flash-error" role="alert"><?= e($flashError) ?></div><?php endif; ?>
