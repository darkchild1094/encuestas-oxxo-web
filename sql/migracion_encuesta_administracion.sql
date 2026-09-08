-- Una encuesta apunta a una tienda (encuesta de tienda) O a un area
-- administrativa (encuesta de oficina), nunca a las dos ni a ninguna.
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

ALTER TABLE `encuesta`
  ADD COLUMN `administracion_id` INT(10) UNSIGNED NULL AFTER `tienda_id`,
  MODIFY COLUMN `tienda_id` INT(10) UNSIGNED NULL,
  ADD KEY `idx_encuesta_administracion` (`administracion_id`),
  ADD CONSTRAINT `fk_encuesta_administracion`
      FOREIGN KEY (`administracion_id`) REFERENCES `administracion` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `chk_encuesta_destino` CHECK (
        (`tienda_id` IS NOT NULL AND `administracion_id` IS NULL)
     OR (`tienda_id` IS NULL AND `administracion_id` IS NOT NULL));
