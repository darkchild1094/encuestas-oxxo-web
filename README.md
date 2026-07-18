# Panel web + API - Encuestas OXXO

## Requisitos
- PHP 8.1+ con PDO MySQL
- MariaDB (correr primero `base_datos_encuestas_oxxo.sql` y luego `sql/migracion_tokens.sql`)
- Apache con mod_rewrite (usa los .htaccess incluidos) o cualquier server que rutee todo a index.php

## Variables de entorno (o edita config/database.php directo)
DB_HOST, DB_NAME, DB_USER, DB_PASS

## Estructura
- `public/` -> document root del panel web (login, respuestas, preguntas, usuarios)
- `api/` -> document root de la API REST para la app Android (otro vhost o subdominio, ej. api.tudominio.com)
- `controllers/`, `views/`, `src/`, `config/` -> compartidos por ambos

## Permisos por rol (tabla `rol`)
- ATI: gestiona_preguntas, ve_resultados_tiendas -> pantalla de inicio web = /respuestas
- WEBMASTER: gestiona_preguntas, gestiona_usuarios -> pantalla de inicio web = /usuarios o /preguntas (no tiene /respuestas)
- USUARIO: no puede entrar al panel web, solo existe para la app movil

## Primer usuario (webmaster)
No hay pantalla de "crear el primer webmaster" porque necesitas ser
webmaster para crear usuarios. Inserta el primero a mano:

```sql
INSERT INTO usuario (rol_id, correo, password_hash, debe_cambiar_password)
VALUES (
  (SELECT id FROM rol WHERE nombre = 'WEBMASTER'),
  'tu_correo@ejemplo.com',
  -- genera este hash con: php -r "echo password_hash('tu_password_temporal', PASSWORD_DEFAULT);"
  '$2y$10$PON_AQUI_EL_HASH_GENERADO',
  1
);
```

## API REST (consumo desde Kotlin/Retrofit)
- `POST /api/login` { correo, password } -> { token, usuario }
- `GET /api/cuestionario?plaza_id=1` (header `Authorization: Bearer <token>`) -> preguntas activas de esa plaza
- `POST /api/encuestas` (header `Authorization: Bearer <token>`) -> sube encuestas pendientes (uuid client-side), idempotente via INSERT IGNORE

## Pendiente / siguientes pasos sugeridos
- Exportar a Excel hoy es .xls basico (tabla HTML). Si luego quieres
  .xlsx real con formato, se agrega PhpSpreadsheet via composer.
- No hay rate limiting ni expiracion automatica de tokens viejos
  (los tokens caducan a los 30 dias pero no se borran solos -- se
  puede meter un cron simple: `DELETE FROM token_acceso WHERE fecha_expiracion < NOW()`).
