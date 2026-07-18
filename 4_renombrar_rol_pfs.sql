USE encuestas_oxxo;

-- Renombra el rol. No hace falta tocar la tabla usuario: erick.cruz
-- sigue apuntando al mismo rol_id, nomas cambia la etiqueta.
UPDATE rol SET nombre = 'PFS' WHERE nombre = 'USUARIO';
