-- Nuevo rol de alcance REGIONAL (sin plaza fija): CoordinadorTI. Por ahora
-- con todos los permisos de panel y encuestas salvo contestar/participar
-- en la encuesta de TIENDA (no hace visitas de tienda). Si se contesta la
-- encuesta de oficina (publica o desde la app), un usuario de este rol
-- con plaza_id NULL aparece como opcion de "ATI que atendio" en CUALQUIER
-- plaza (ver EncuestaPublicaController::mostrar() y form.php).
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

INSERT INTO `rol` (`nombre`, `gestiona_preguntas`, `gestiona_usuarios`, `es_encuestable`, `contesta_oficina`, `ve_resultados_tiendas`)
SELECT 'CoordinadorTI', 1, 1, 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM `rol` WHERE `nombre` = 'CoordinadorTI');

-- Ricardo Garcia Ramirez ya tenia una cuenta creada por error con rol
-- WEBMASTER (sin plaza, correcto para alcance regional) -- se reasigna
-- al nuevo rol en vez de crear una cuenta duplicada. Nombre y foto se
-- actualizan aparte, a mano, porque dependen de la foto ya subida.
UPDATE `usuario` u
JOIN `rol` nuevo ON nuevo.nombre = 'CoordinadorTI'
SET u.rol_id = nuevo.id
WHERE u.correo = 'ricardo.garcia@oxxo.com';
