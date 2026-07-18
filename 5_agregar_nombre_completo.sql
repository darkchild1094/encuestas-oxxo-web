USE encuestas_oxxo;

ALTER TABLE usuario
  ADD COLUMN nombre_completo VARCHAR(150) NULL AFTER correo;
