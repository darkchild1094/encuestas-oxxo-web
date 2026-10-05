-- La encuesta de oficina (publica, sin login, /encuesta-oficina) ahora
-- pide al usuario que elija a que plaza pertenece. Antes no se capturaba
-- ese dato para esas respuestas (usuario_id siempre NULL ahi), asi que
-- quedaban fuera de "/api/estadisticas/oficina?por=plaza" (que depende
-- de usuario.plaza_id, inexistente para un envio anonimo).
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

ALTER TABLE `encuesta`
  ADD COLUMN `plaza_id` INT(10) UNSIGNED NULL AFTER `administracion_id`,
  ADD KEY `idx_encuesta_plaza` (`plaza_id`),
  ADD CONSTRAINT `fk_encuesta_plaza` FOREIGN KEY (`plaza_id`) REFERENCES `plaza` (`id`) ON UPDATE CASCADE;
