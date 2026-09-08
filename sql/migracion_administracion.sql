-- Catalogo plano y global de areas administrativas de oficina
-- (RH, Mantenimiento, Asesores...). El webmaster las da de alta
-- desde el modulo /administracion. Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

CREATE TABLE IF NOT EXISTS `administracion` (
  `id`             INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre`         VARCHAR(120) NOT NULL,
  `activo`         TINYINT(1) NOT NULL DEFAULT 1,
  `fecha_registro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_administracion_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `administracion` (`nombre`) VALUES ('RH'), ('Mantenimiento'), ('Asesores');
