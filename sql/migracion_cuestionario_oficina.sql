-- La encuesta de oficina usa un unico cuestionario global (sin plaza).
-- Se agrega un discriminador 'tipo' y se permite plaza_id NULL.
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

ALTER TABLE `cuestionario`
  ADD COLUMN `tipo` ENUM('tienda','oficina') NOT NULL DEFAULT 'tienda' AFTER `plaza_id`,
  MODIFY COLUMN `plaza_id` INT(10) UNSIGNED NULL;

-- Idempotente: crea la unica encuesta de oficina si todavia no existe.
INSERT INTO `cuestionario` (`plaza_id`, `nombre`, `activo`, `tipo`)
SELECT NULL, 'Encuesta de oficina', 1, 'oficina'
WHERE NOT EXISTS (SELECT 1 FROM `cuestionario` WHERE `tipo` = 'oficina');
