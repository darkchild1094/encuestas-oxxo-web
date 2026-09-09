-- Revierte sql/migracion_ati_es_encuestable.sql: el ATI NO contesta la
-- encuesta de tienda -- no tiene sentido, la pregunta fija de ese
-- cuestionario es "como calificarias el servicio del area de TI" y el
-- ATI seria quien se autocalifica. Sigue contestando la de OFICINA
-- (contesta_oficina, sin tocar).
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

UPDATE `rol` SET `es_encuestable` = 0 WHERE `nombre` = 'ATI';
