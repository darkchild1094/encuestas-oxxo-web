-- ============================================================
-- LIMPIEZA de respuesta_detalle huérfana + blindaje con FK
-- ============================================================
-- Causa raíz (ya corregida en el código, ver SyncApiController.php):
-- INSERT IGNORE en `encuesta` podía fallar silenciosamente sin
-- lanzar excepción, y el código no revisaba si la fila realmente se
-- guardó antes de insertar sus respuestas -- dejando respuesta_detalle
-- con encuesta_id apuntando a una encuesta que nunca se creó.
-- Esto se repitió porque respuesta_detalle.encuesta_id NUNCA tuvo un
-- FOREIGN KEY real (a diferencia de encuesta->tienda/cuestionario/usuario,
-- que sí lo tienen), asi que MySQL nunca lo detuvo.
--
-- IMPORTANTE: corre primero el SELECT de abajo y revisa el resultado
-- ANTES de correr el DELETE. Estas filas son respuestas sin encuesta
-- padre -- no se pueden "recuperar" la encuesta, solo limpiar el
-- huerfano. Si prefieres investigar mas a fondo antes de borrar
-- (ej. exportarlas primero), avisame.

-- 1) Ver cuántas hay y confirmar que siguen siendo huérfanas antes de borrar
SELECT COUNT(*) AS total_huerfanas
FROM respuesta_detalle rd
LEFT JOIN encuesta e ON e.id = rd.encuesta_id
WHERE e.id IS NULL;

-- 2) (Opcional) Exportar antes de borrar, por si luego quieres auditar
--    quién las generó cruzando por pregunta_id/fecha aproximada:
-- CREATE TABLE respuesta_detalle_huerfana_backup AS
-- SELECT rd.* FROM respuesta_detalle rd
-- LEFT JOIN encuesta e ON e.id = rd.encuesta_id
-- WHERE e.id IS NULL;

-- 3) Borrar las huérfanas (descomenta para ejecutar)
-- DELETE rd FROM respuesta_detalle rd
-- LEFT JOIN encuesta e ON e.id = rd.encuesta_id
-- WHERE e.id IS NULL;

-- 4) Ya limpio, agregar el FOREIGN KEY que debió existir desde el inicio
--    (así, si el bug volviera a aparecer por otra razón, MySQL lo va a
--    rechazar con un error real en vez de dejarlo pasar silencioso):
-- ALTER TABLE `respuesta_detalle`
--   ADD CONSTRAINT `fk_respuesta_encuesta` FOREIGN KEY (`encuesta_id`) REFERENCES `encuesta` (`id`) ON DELETE CASCADE;
