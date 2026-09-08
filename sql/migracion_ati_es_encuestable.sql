-- El ATI tambien puede contestar la encuesta de TIENDA desde la app
-- (igual que el PFS), ademas de la de oficina (contesta_oficina, ya
-- habilitada). EncuestaViewModel/EncuestaScreen en la app YA tratan a
-- ATI igual que a WEBMASTER (misma rama esAdminOAti: usa su plaza fija
-- y busca la tienda) -- solo faltaba este permiso en BD.
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

UPDATE `rol` SET `es_encuestable` = 1 WHERE `nombre` = 'ATI';
