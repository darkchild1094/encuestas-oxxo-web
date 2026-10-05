-- WEBMASTER ahora tambien puede ver (y exportar/borrar una por una) las
-- respuestas de tiendas y de oficina, igual que ATI. El panel ya usaba
-- este flag para mostrar el menu/filtrar acceso (ve_resultados_tiendas);
-- solo faltaba prenderlo para este rol. El codigo (RespuestaController,
-- DashboardController) ya trata a WEBMASTER (sin plaza propia) como
-- alcance global, igual que el ATI especial id 128.
-- Correr a mano sobre encuestas_oxxo.
USE encuestas_oxxo;

UPDATE `rol` SET `ve_resultados_tiendas` = 1 WHERE `nombre` = 'WEBMASTER';
