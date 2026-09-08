-- Bandera de permiso: que roles pueden contestar la encuesta de oficina.
-- No se toca es_encuestable (eso habilitaria tambien encuestas de tienda).
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

ALTER TABLE `rol`
  ADD COLUMN `contesta_oficina` TINYINT(1) NOT NULL DEFAULT 0 AFTER `es_encuestable`;

UPDATE `rol` SET `contesta_oficina` = 1 WHERE `nombre` IN ('ATI', 'WEBMASTER');
