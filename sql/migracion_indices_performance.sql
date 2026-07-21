-- Migracion de rendimiento: indices faltantes.
--
-- Diagnostico: token_acceso.token NO tenia indice (ni PRIMARY KEY,
-- ni UNIQUE). Esa columna se consulta con WHERE token = :token en
-- CADA request autenticado de la app (negocios, regiones, plazas,
-- tiendas, cuestionario, encuestas, respuestas, usuarios,
-- preguntas...), asi que sin indice, MySQL hacia un escaneo
-- completo de la tabla en cada llamada. Esto explica en buena
-- parte la lentitud percibida, sobre todo porque la tabla crece
-- con cada login y nunca se limpian los tokens vencidos.
--
-- usuario.correo tampoco tenia indice, y se usa en el WHERE del
-- login -- mismo problema, a menor escala (una vez por sesion en
-- vez de en cada request).
--
-- Ambos cambios son aditivos: no borran ni modifican datos
-- existentes, solo agregan indices. Seguro correrlo en producción.

ALTER TABLE `token_acceso`
    ADD UNIQUE KEY `uq_token_acceso_token` (`token`);

ALTER TABLE `usuario`
    ADD UNIQUE KEY `uq_usuario_correo` (`correo`);

-- Limpieza de una sola vez de tokens ya vencidos, para que el
-- primer request despues de esta migracion ya corra sobre una
-- tabla mas chica (los nuevos indices ya la hacen rapida de
-- cualquier forma, pero no cuesta nada limpiar lo que ya no sirve).
DELETE FROM `token_acceso` WHERE `fecha_expiracion` < NOW();
