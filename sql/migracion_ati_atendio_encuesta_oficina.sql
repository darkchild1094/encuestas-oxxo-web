-- La encuesta de oficina (publica, sin login, /encuesta-oficina) ahora
-- tambien pide que ATI atendio a la persona que contesta (con foto, segun
-- la plaza elegida). Se guarda en encuesta.ati_atendio_id -- separado de
-- usuario_id, que en esta encuesta siempre es NULL (envio anonimo) y en
-- la de la app es el ATI/WEBMASTER que la contesta sobre si mismo, no
-- necesariamente quien atendio a nadie.
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

ALTER TABLE `encuesta`
  ADD COLUMN `ati_atendio_id` INT(10) UNSIGNED NULL AFTER `plaza_id`,
  ADD KEY `idx_encuesta_ati_atendio` (`ati_atendio_id`),
  ADD CONSTRAINT `fk_encuesta_ati_atendio` FOREIGN KEY (`ati_atendio_id`) REFERENCES `usuario` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
