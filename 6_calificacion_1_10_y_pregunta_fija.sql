USE encuestas_oxxo;

-- 1) La escala ya no es estrellas 1-5, es NPS 1-10.
ALTER TABLE respuesta_detalle DROP CONSTRAINT chk_estrellas;
ALTER TABLE respuesta_detalle CHANGE COLUMN estrellas calificacion TINYINT UNSIGNED NOT NULL;
ALTER TABLE respuesta_detalle ADD CONSTRAINT chk_calificacion CHECK (calificacion BETWEEN 1 AND 10);

-- 2) Bandera para la pregunta fija que SIEMPRE va penultima (antes
-- del comentario), en todos los cuestionarios, sin excepcion. No se
-- puede borrar desde el CRUD de preguntas.
ALTER TABLE pregunta ADD COLUMN es_fija BOOLEAN NOT NULL DEFAULT 0 AFTER activo;

-- 3) La inyecta en cada cuestionario que todavia no la tenga
-- (los que ya existen; los nuevos la reciben automatico desde
-- PreguntaController::index()).
INSERT INTO pregunta (cuestionario_id, creado_por_usuario_id, texto, orden, es_fija)
SELECT c.id, NULL, 'Como calificarias el servicio del area de TI', 9999, 1
FROM cuestionario c
WHERE NOT EXISTS (
  SELECT 1 FROM pregunta p WHERE p.cuestionario_id = c.id AND p.es_fija = 1
);
