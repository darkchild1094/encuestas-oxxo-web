USE encuestas_oxxo;

-- raul.huerta@getic.com.mx / WEBMASTER / password temporal: f4bef4a7
INSERT INTO usuario (rol_id, correo, password_hash, debe_cambiar_password)
VALUES ((SELECT id FROM rol WHERE nombre = 'WEBMASTER'), 'raul.huerta@getic.com.mx', '$2y$10$t/dGbdUJnCmtjMdbkDqHWeoKhK/MASvKNATR7P1s2LIYGfCwvZwrK', 1);

-- rosa.ramirez@oxxo.com / ATI / password temporal: 3f56a090
INSERT INTO usuario (rol_id, correo, password_hash, debe_cambiar_password)
VALUES ((SELECT id FROM rol WHERE nombre = 'ATI'), 'rosa.ramirez@oxxo.com', '$2y$10$VFOJp20SyinLUZGFUmQr0e1MPqlWHrxHWkany/goTDSLEwyhmLp/O', 1);

-- erick.cruz@getic.com.mx / USUARIO / password temporal: b31ff965
INSERT INTO usuario (rol_id, correo, password_hash, debe_cambiar_password)
VALUES ((SELECT id FROM rol WHERE nombre = 'USUARIO'), 'erick.cruz@getic.com.mx', '$2y$10$2MSi1f/uaci/Xhb8zSp0heExW9yNi8B6jyT7bkCcZKxJen/H584r.', 1);
