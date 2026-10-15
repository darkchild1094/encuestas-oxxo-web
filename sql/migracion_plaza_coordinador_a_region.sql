-- El CoordinadorTI es de alcance regional: cuando el es quien atendio (o
-- quien se califica a si mismo desde la app), la respuesta debe contar
-- para "Region Tamaulipas" en las estadisticas por centro de trabajo, sin
-- importar el centro de trabajo que haya elegido quien respondio. Esto ya
-- lo hace el codigo para encuestas nuevas (EncuestaPublicaController);
-- aqui se ajustan las que ya se habian guardado con una plaza especifica
-- antes de ese cambio.
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

UPDATE `encuesta` e
LEFT JOIN `usuario` ue ON ue.id = e.usuario_id
LEFT JOIN `usuario` ua ON ua.id = e.ati_atendio_id
LEFT JOIN `rol` re ON re.id = ue.rol_id
LEFT JOIN `rol` ra ON ra.id = ua.rol_id
SET e.plaza_id = NULL
WHERE e.administracion_id IS NOT NULL
  AND e.plaza_id IS NOT NULL
  AND (re.nombre = 'CoordinadorTI' OR ra.nombre = 'CoordinadorTI');
