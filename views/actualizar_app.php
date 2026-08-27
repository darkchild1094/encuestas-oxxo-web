<?php require __DIR__ . '/layout_header.php'; ?>

<div class="container mt-4">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0"><i class="fas fa-upload me-2"></i>Publicar Actualización de la App</h4>
                </div>
                <div class="card-body">
                    <?php if (isset($_SESSION['mensaje_exito'])): ?>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <?= $_SESSION['mensaje_exito']; unset($_SESSION['mensaje_exito']); ?>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <?php endif; ?>

                    <form action="<?= BASE_URL ?>/actualizar-app/procesar" method="POST" enctype="multipart/form-data">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Version Code (Número)</label>
                                <input type="number" name="version_code" class="form-control" value="<?= $version['version_code'] ?>" required>
                                <div class="form-text">Ejemplo: 2 (Debe ser mayor al actual)</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Version Name (Texto)</label>
                                <input type="text" name="version_name" class="form-control" value="<?= $version['version_name'] ?>" placeholder="v1.1.0" required>
                                <div class="form-text">Ejemplo: 1.1.0</div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">Archivo APK</label>
                            <input type="file" name="apk" class="form-control" accept=".apk">
                            <div class="form-text">Sube el nuevo archivo .apk. Si lo dejas vacío, se mantendrá el archivo anterior.</div>
                        </div>

                        <div class="mb-3 form-check form-switch">
                            <input class="form-check-input" type="checkbox" name="obligatoria" id="obligatoria" <?= $version['obligatoria'] ? 'checked' : '' ?>>
                            <label class="form-check-label fw-bold" for="obligatoria">Actualización Obligatoria</label>
                            <div class="form-text">Si se marca, el usuario no podrá usar la app hasta que instale esta versión.</div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold">Novedades / Notas de versión</label>
                            <textarea name="novedades" class="form-control" rows="3"><?= htmlspecialchars($version['novedades']) ?></textarea>
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary btn-lg">
                                <i class="fas fa-cloud-upload-alt me-2"></i>Guardar y Publicar
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="mt-4 p-3 bg-light rounded border">
                <h5><i class="fas fa-info-circle me-2"></i>Estado Actual</h5>
                <ul class="list-unstyled mb-0">
                    <li><strong>Versión en servidor:</strong> <?= $version['version_name'] ?> (Build <?= $version['version_code'] ?>)</li>
                    <li><strong>URL del APK:</strong> <code class="small"><?= $version['url'] ?: 'No definida' ?></code></li>
                    <li><strong>Tipo:</strong> <?= $version['obligatoria'] ? '<span class="badge bg-danger">Crítica</span>' : '<span class="badge bg-info">Opcional</span>' ?></li>
                </ul>
            </div>
        </div>
    </div>
</div>

<?php require __DIR__ . '/layout_footer.php'; ?>
