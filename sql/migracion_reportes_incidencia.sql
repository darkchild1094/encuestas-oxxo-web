-- Sistema de reportes de incidencias / comentarios, tipo ticket de
-- servicio. Cualquier usuario puede crear uno (reportar un problema);
-- el webmaster los ve todos, los comenta y los marca como resueltos.
-- El usuario que lo creo ve el hilo de comentarios y si ya se resolvio.

CREATE TABLE IF NOT EXISTS `reporte_incidencia` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `usuario_id` INT UNSIGNED NOT NULL,
    `comentario` TEXT NOT NULL,
    `estado` ENUM('abierto', 'en_proceso', 'resuelto') NOT NULL DEFAULT 'abierto',
    `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `fecha_resuelto` DATETIME DEFAULT NULL,
    INDEX `idx_usuario` (`usuario_id`),
    INDEX `idx_estado` (`estado`),
    FOREIGN KEY (`usuario_id`) REFERENCES `usuario`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Hilo de comentarios de cada reporte -- tanto el webmaster dando
-- seguimiento/resolucion, como (a futuro si se necesita) el mismo
-- usuario agregando mas contexto a su reporte.
CREATE TABLE IF NOT EXISTS `reporte_incidencia_comentario` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `reporte_id` INT UNSIGNED NOT NULL,
    `usuario_id` INT UNSIGNED NOT NULL,
    `comentario` TEXT NOT NULL,
    `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_reporte` (`reporte_id`),
    FOREIGN KEY (`reporte_id`) REFERENCES `reporte_incidencia`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`usuario_id`) REFERENCES `usuario`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
