-- Agrega el folio capturado antes de seleccionar la tienda.
-- Se deja nullable para conservar compatibilidad con encuestas existentes
-- y versiones antiguas de la app que aun no lo envien.
ALTER TABLE `encuesta`
    ADD COLUMN `folio` VARCHAR(50) NULL AFTER `cuestionario_id`;