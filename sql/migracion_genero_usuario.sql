-- Agrega la columna genero a usuario. Usada para mostrar "Asesor"/"Asesora"
-- en el saludo del ATI dentro de la encuesta, en vez del heuristico anterior
-- por nombre (que ademas nunca tenia forma de dar "H" ya que ningun nombre
-- terminaba distinto).
--
-- Si ya la agregaste a mano en produccion (ver agregar_genero_usuario.sql
-- que se paso por separado con los UPDATE de los usuarios existentes), esta
-- migracion es solo para que quede documentada en el repo -- no hace falta
-- correrla de nuevo.

ALTER TABLE `usuario` ADD COLUMN `genero` ENUM('H','M') DEFAULT NULL AFTER `nombre_completo`;
