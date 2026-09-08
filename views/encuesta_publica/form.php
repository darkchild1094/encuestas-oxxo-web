<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Encuesta de oficina - Pulso TI</title>
  <link rel="icon" type="image/svg+xml" href="<?= BASE_URL ?>/assets/favicon-pulso-ti.svg">
  <?php require __DIR__ . '/../bootstrap.php'; ?>
  <link rel="stylesheet" href="<?= BASE_URL ?>/css/style.css">
  <style>
    .encuesta-publica{max-width:52rem;margin:2.5rem auto;padding:0 1.25rem}
    .encuesta-publica .pregunta{border:1px solid #e6e0da;border-radius:.65rem;padding:1rem 1.15rem;margin-bottom:1rem;background:#fff}
    .encuesta-publica .escala{display:flex;flex-wrap:wrap;gap:.4rem;margin-top:.6rem}
    .encuesta-publica .escala label{display:inline-flex;align-items:center;justify-content:center;min-width:2.4rem;padding:.4rem 0;border:1px solid #d0c8c0;border-radius:.4rem;cursor:pointer;font-weight:600}
    .encuesta-publica .escala input{position:absolute;opacity:0;pointer-events:none}
    .encuesta-publica .escala input:checked+span{}
    .encuesta-publica .escala label:has(input:checked){background:#d70b16;color:#fff;border-color:#d70b16}
    .encuesta-publica .escala label:focus-within{outline:2px solid #241213}
    .hp-field{position:absolute;left:-9999px;width:1px;height:1px;overflow:hidden}
  </style>
</head>
<body class="login-page">
<main class="encuesta-publica card border-0 shadow-lg p-4">
  <div class="login-brand text-center mb-3">
    <img class="logo-pulso" src="<?= BASE_URL ?>/assets/logo_pulso_ti.png" alt="Pulso TI" width="48" height="48">
  </div>

  <?php if (!empty($enviada)): ?>
    <div class="text-center">
      <h1 style="font-size:1.4rem">¡Gracias!</h1>
      <p>Tu respuesta quedó registrada. Ya puedes cerrar esta página.</p>
      <p><a href="<?= BASE_URL ?>/encuesta-oficina">Enviar otra respuesta</a></p>
    </div>
  <?php elseif (empty($disponible)): ?>
    <div class="text-center">
      <h1 style="font-size:1.4rem">Encuesta no disponible</h1>
      <p>Todavía no hay preguntas o áreas configuradas para la encuesta de oficina.
      Inténtalo más tarde.</p>
    </div>
  <?php else: ?>
    <div class="login-heading text-center mb-3">
      <p class="eyebrow">Encuesta de oficina</p>
      <h1><?= htmlspecialchars($cuestionario['nombre']) ?></h1>
      <p class="text-muted">Califica de 1 a 10, donde 1 es muy malo y 10 es excelente.</p>
    </div>

    <?php if (!empty($error)): ?>
      <p class="error alert alert-danger" role="alert"><?= htmlspecialchars($error) ?></p>
    <?php endif; ?>

    <form method="POST" action="<?= BASE_URL ?>/encuesta-oficina/enviar">
      <?= Csrf::campo() ?>

      <div class="hp-field" aria-hidden="true">
        <label>No llenar<input type="text" name="website" tabindex="-1" autocomplete="off"></label>
      </div>

      <div class="mb-3">
        <label class="form-label" for="administracion_id"><strong>Área administrativa</strong></label>
        <select class="form-select" id="administracion_id" name="administracion_id" required>
          <option value="">Selecciona un área…</option>
          <?php foreach ($areas as $a): ?>
            <option value="<?= (int) $a['id'] ?>"><?= htmlspecialchars($a['nombre']) ?></option>
          <?php endforeach; ?>
        </select>
      </div>

      <?php foreach ($preguntas as $p): ?>
        <fieldset class="pregunta">
          <legend style="font-size:1rem;font-weight:600"><?= htmlspecialchars($p['texto']) ?></legend>
          <div class="escala" role="radiogroup" aria-label="<?= htmlspecialchars($p['texto']) ?>">
            <?php for ($i = 1; $i <= 10; $i++): ?>
              <label>
                <input type="radio" name="calificacion[<?= (int) $p['id'] ?>]" value="<?= $i ?>" required>
                <span><?= $i ?></span>
              </label>
            <?php endfor; ?>
          </div>
        </fieldset>
      <?php endforeach; ?>

      <div class="mb-3">
        <label class="form-label" for="comentario">Comentario (opcional)</label>
        <textarea class="form-control" id="comentario" name="comentario" rows="3" maxlength="2000"></textarea>
      </div>

      <button class="btn btn-primary w-100" type="submit">Enviar respuesta</button>
    </form>
  <?php endif; ?>
</main>
</body>
</html>
