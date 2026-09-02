-- Migracion de rendimiento: indices para el detalle de respuestas, el
-- dashboard y el reporte Excel.
--
-- El panel del ATI arma una consulta que une encuesta -> tienda -> plaza ->
-- region -> negocio -> respuesta_detalle -> pregunta, filtrando por plaza y
-- por rango de fecha y ordenando por `fecha_creacion_local DESC`. El
-- dashboard y el Excel repiten variantes de eso.
--
-- Casi todas las columnas de JOIN (tienda_id, plaza_id, region_id,
-- negocio_id, rol_id, usuario_id, pregunta_id) YA estan indexadas porque
-- tienen FOREIGN KEY y InnoDB crea el indice solo. Lo que falta es apoyar
-- el filtro + ORDER BY por fecha de `encuesta`, que hoy se resuelve con
-- escaneo y ordenamiento en memoria.
--
-- Cambios ADITIVOS (solo ADD INDEX). No tocan datos. Seguro en produccion;
-- en MySQL 8 / MariaDB 10.5+ corre en caliente. Si tu version no acepta
-- "IF NOT EXISTS" en ADD INDEX, quita esa clausula.

ALTER TABLE `encuesta`
    ADD INDEX IF NOT EXISTS `ix_encuesta_tienda_fecha` (`tienda_id`, `fecha_creacion_local`),
    ADD INDEX IF NOT EXISTS `ix_encuesta_fecha` (`fecha_creacion_local`);

-- Opcional: si el reporte por PFS se vuelve lento, este ayuda al LEFT JOIN
-- por e.usuario_id (no tiene FK con indice util para el patron de lectura).
-- ALTER TABLE `encuesta` ADD INDEX IF NOT EXISTS `ix_encuesta_usuario_fecha` (`usuario_id`, `fecha_creacion_local`);
