-- =====================================================================
-- Base de datos: encuestas_oxxo
-- Motor: InnoDB | Charset: utf8mb4_unicode_ci (MariaDB)
-- Nota: se evitan ENUM en columnas de estado -- ya tuviste el bug de
-- casing 'En bodega' vs 'en_bodega' en Inventario123. Aqui todo estado
-- se maneja con BOOLEAN (TINYINT 0/1) o catalogos con FK.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS encuestas_oxxo
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE encuestas_oxxo;

SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- ROL: catalogo de permisos. Nada de roles hardcodeados en el codigo,
-- todo se decide leyendo estas 4 banderas.
-- ---------------------------------------------------------------------
CREATE TABLE rol (
  id                     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre                 VARCHAR(30)  NOT NULL UNIQUE,
  gestiona_preguntas     BOOLEAN      NOT NULL DEFAULT 0,
  gestiona_usuarios      BOOLEAN      NOT NULL DEFAULT 0,
  es_encuestable         BOOLEAN      NOT NULL DEFAULT 0,
  ve_resultados_tiendas  BOOLEAN      NOT NULL DEFAULT 0
) ENGINE=InnoDB;

INSERT INTO rol (nombre, gestiona_preguntas, gestiona_usuarios, es_encuestable, ve_resultados_tiendas) VALUES
  ('ATI',        1, 0, 0, 1),
  ('WEBMASTER',  1, 1, 1, 0),
  ('USUARIO',    0, 0, 1, 0);

-- ---------------------------------------------------------------------
-- Jerarquia negocio -> region -> plaza -> tienda
-- ---------------------------------------------------------------------
CREATE TABLE negocio (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  es_default  BOOLEAN      NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE region (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  negocio_id  INT UNSIGNED NOT NULL,
  nombre      VARCHAR(100) NOT NULL,
  es_default  BOOLEAN      NOT NULL DEFAULT 0,
  CONSTRAINT fk_region_negocio FOREIGN KEY (negocio_id)
    REFERENCES negocio(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE plaza (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  region_id   INT UNSIGNED NOT NULL,
  nombre      VARCHAR(100) NOT NULL,
  es_default  BOOLEAN      NOT NULL DEFAULT 0,
  CONSTRAINT fk_plaza_region FOREIGN KEY (region_id)
    REFERENCES region(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tienda (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  plaza_id    INT UNSIGNED NOT NULL,
  codigo      VARCHAR(20)  NOT NULL,
  nombre      VARCHAR(150) NOT NULL,
  direccion   VARCHAR(255) NULL,
  CONSTRAINT fk_tienda_plaza FOREIGN KEY (plaza_id)
    REFERENCES plaza(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY uk_tienda_codigo (codigo)
) ENGINE=InnoDB;

-- Solo un default por tabla: se refuerza a nivel app, pero un indice
-- filtrado ayuda a detectar inconsistencias rapido.
CREATE INDEX idx_negocio_default ON negocio (es_default);
CREATE INDEX idx_region_default  ON region  (es_default);
CREATE INDEX idx_plaza_default   ON plaza   (es_default);

-- ---------------------------------------------------------------------
-- USUARIO
-- ---------------------------------------------------------------------
CREATE TABLE usuario (
  id                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  rol_id                  INT UNSIGNED NOT NULL,
  correo                  VARCHAR(150) NOT NULL UNIQUE,
  password_hash           VARCHAR(255) NOT NULL,
  debe_cambiar_password   BOOLEAN      NOT NULL DEFAULT 0,
  foto_perfil             VARCHAR(255) NULL,
  fecha_registro          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_usuario_rol FOREIGN KEY (rol_id)
    REFERENCES rol(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- CUESTIONARIO / PREGUNTA
-- El cuestionario esta ligado a una plaza. `activo` en pregunta es
-- soft-delete: "borrar" una pregunta desde la app apaga esta bandera,
-- nunca hace DELETE fisico -- asi no se rompen respuestas historicas.
-- ---------------------------------------------------------------------
CREATE TABLE cuestionario (
  id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  plaza_id  INT UNSIGNED NOT NULL,
  nombre    VARCHAR(150) NOT NULL,
  activo    BOOLEAN      NOT NULL DEFAULT 1,
  CONSTRAINT fk_cuestionario_plaza FOREIGN KEY (plaza_id)
    REFERENCES plaza(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pregunta (
  id                       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cuestionario_id          INT UNSIGNED NOT NULL,
  creado_por_usuario_id    INT UNSIGNED NULL,
  texto                    VARCHAR(255) NOT NULL,
  orden                    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  activo                   BOOLEAN      NOT NULL DEFAULT 1,
  CONSTRAINT fk_pregunta_cuestionario FOREIGN KEY (cuestionario_id)
    REFERENCES cuestionario(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pregunta_usuario FOREIGN KEY (creado_por_usuario_id)
    REFERENCES usuario(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_pregunta_cuestionario_orden ON pregunta (cuestionario_id, orden);

-- ---------------------------------------------------------------------
-- ENCUESTA / RESPUESTA_DETALLE
-- PK en CHAR(36) (uuid) generado en el dispositivo Android -- necesario
-- para el modo offline-first: el registro nace con identidad propia
-- sin depender de un autoincrement del servidor.
-- usuario_id se deja NULLABLE + ON DELETE SET NULL: si el webmaster
-- borra un usuario, sus encuestas contestadas se conservan para
-- reportes, solo se pierde el vinculo al usuario borrado.
-- ---------------------------------------------------------------------
CREATE TABLE encuesta (
  id                     CHAR(36)     NOT NULL PRIMARY KEY,
  usuario_id             INT UNSIGNED NULL,
  tienda_id              INT UNSIGNED NOT NULL,
  cuestionario_id        INT UNSIGNED NOT NULL,
  comentario             TEXT         NULL,
  fecha_creacion_local   DATETIME     NOT NULL,
  sincronizado           BOOLEAN      NOT NULL DEFAULT 0,
  fecha_sincronizacion   DATETIME     NULL,
  CONSTRAINT fk_encuesta_usuario FOREIGN KEY (usuario_id)
    REFERENCES usuario(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_encuesta_tienda FOREIGN KEY (tienda_id)
    REFERENCES tienda(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_encuesta_cuestionario FOREIGN KEY (cuestionario_id)
    REFERENCES cuestionario(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_encuesta_tienda        ON encuesta (tienda_id);
CREATE INDEX idx_encuesta_sincronizado  ON encuesta (sincronizado);
CREATE INDEX idx_encuesta_fecha         ON encuesta (fecha_creacion_local);

CREATE TABLE respuesta_detalle (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  encuesta_id   CHAR(36)     NOT NULL,
  pregunta_id   INT UNSIGNED NOT NULL,
  estrellas     TINYINT UNSIGNED NOT NULL,
  CONSTRAINT fk_respuesta_encuesta FOREIGN KEY (encuesta_id)
    REFERENCES encuesta(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_respuesta_pregunta FOREIGN KEY (pregunta_id)
    REFERENCES pregunta(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_estrellas CHECK (estrellas BETWEEN 1 AND 5),
  UNIQUE KEY uk_respuesta_unica (encuesta_id, pregunta_id)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- Seeds de default: negocio=OXXO, region=Tamaulipas, plaza=Valles
-- ---------------------------------------------------------------------
INSERT INTO negocio (nombre, es_default) VALUES ('OXXO', 1);
INSERT INTO region  (negocio_id, nombre, es_default)
  VALUES (LAST_INSERT_ID(), 'Tamaulipas', 1);
INSERT INTO plaza   (region_id, nombre, es_default)
  VALUES (LAST_INSERT_ID(), 'Valles', 1);
