-- Unifica la colacion de TODAS las tablas y columnas a
-- utf8mb4_unicode_ci. Corrige el error 1267 "Illegal mix of
-- collations" que pasa cuando una tabla (o columna) quedo con
-- utf8mb4_general_ci mientras el resto usa utf8mb4_unicode_ci --
-- comun en hosting compartido donde el panel a veces fuerza su
-- propio default al importar.

-- Nota: no se toca ALTER DATABASE aqui -- en hosting compartido el
-- usuario normalmente no tiene permiso a nivel de esquema, solo a
-- nivel tabla. Esa linea solo afecta tablas NUEVAS de todos modos;
-- lo que realmente arregla tus datos existentes son los ALTER TABLE
-- de abajo.

ALTER TABLE rol                CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE negocio            CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE region              CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE plaza               CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE usuario             CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE tienda               CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE cuestionario         CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE pregunta             CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE encuesta             CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE respuesta_detalle    CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE token_acceso         CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
