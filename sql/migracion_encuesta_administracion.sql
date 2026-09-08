-- Una encuesta apunta a una tienda (encuesta de tienda) O a un area
-- administrativa (encuesta de oficina). El "exactamente uno de los dos"
-- se valida en la app (SyncApiController::subirEncuestas y
-- EncuestaPublicaController::enviar); NO se pone como CHECK porque
-- MariaDB 10.5+ rechaza (ERROR 1901) una restriccion CHECK sobre una
-- columna que participa en una FK con accion referencial (tienda_id ya
-- tiene fk_encuesta_tienda ON UPDATE CASCADE).
-- Correr a mano sobre encuestas_oxxo. Re-ejecutable.
USE encuestas_oxxo;

ALTER TABLE `encuesta`
  ADD COLUMN IF NOT EXISTS `administracion_id` INT(10) UNSIGNED NULL AFTER `tienda_id`,
  MODIFY COLUMN `tienda_id` INT(10) UNSIGNED NULL,
  ADD KEY IF NOT EXISTS `idx_encuesta_administracion` (`administracion_id`),
  ADD CONSTRAINT `fk_encuesta_administracion`
      FOREIGN KEY IF NOT EXISTS (`administracion_id`) REFERENCES `administracion` (`id`) ON UPDATE CASCADE;
