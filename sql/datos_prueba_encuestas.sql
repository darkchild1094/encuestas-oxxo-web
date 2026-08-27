-- Datos de prueba: otras 100 encuestas por cada plaza.
-- MariaDB 10.11+ / MySQL 8+
-- Ejecutar en la base de datos del proyecto.

START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS tmp_encuestas_prueba;
DROP TEMPORARY TABLE IF EXISTS tmp_plazas_sin_cuestionario;
DROP TEMPORARY TABLE IF EXISTS tmp_numeros_prueba;

-- El dump actual solo trae cuestionario para una plaza. Crea el mismo
-- cuestionario en las plazas restantes para que todas puedan recibir datos.
CREATE TEMPORARY TABLE tmp_plazas_sin_cuestionario (
  plaza_id INT UNSIGNED NOT NULL PRIMARY KEY
) ENGINE=MEMORY;

INSERT INTO tmp_plazas_sin_cuestionario (plaza_id)
SELECT p.id
FROM plaza p
LEFT JOIN cuestionario c
  ON c.plaza_id = p.id
 AND c.activo = 1
WHERE c.id IS NULL;

INSERT INTO cuestionario (plaza_id, nombre, activo)
SELECT faltantes.plaza_id, base.nombre, 1
FROM tmp_plazas_sin_cuestionario faltantes
CROSS JOIN (
  SELECT nombre
  FROM cuestionario
  WHERE activo = 1
  ORDER BY id
  LIMIT 1
) base;

-- Copia las preguntas activas del cuestionario base a los cuestionarios nuevos.
INSERT INTO pregunta (cuestionario_id, creado_por_usuario_id, texto, orden, activo, es_fija)
SELECT nuevo.id, NULL, base_pregunta.texto, base_pregunta.orden, base_pregunta.activo, base_pregunta.es_fija
FROM cuestionario nuevo
JOIN tmp_plazas_sin_cuestionario faltantes ON faltantes.plaza_id = nuevo.plaza_id
CROSS JOIN (
  SELECT id
  FROM cuestionario
  WHERE activo = 1
  ORDER BY id
  LIMIT 1
) base
JOIN pregunta base_pregunta ON base_pregunta.cuestionario_id = base.id
WHERE nuevo.activo = 1;

CREATE TEMPORARY TABLE tmp_numeros_prueba (
  numero INT UNSIGNED NOT NULL PRIMARY KEY
) ENGINE=MEMORY;

INSERT INTO tmp_numeros_prueba (numero)
WITH RECURSIVE numeros AS (
  SELECT 1 AS numero
  UNION ALL
  SELECT numero + 1
  FROM numeros
  WHERE numero < 100
)
SELECT numero FROM numeros;

CREATE TEMPORARY TABLE tmp_encuestas_prueba (
  encuesta_id CHAR(36) NOT NULL PRIMARY KEY,
  plaza_id INT UNSIGNED NOT NULL,
  numero INT UNSIGNED NOT NULL,
  usuario_id INT UNSIGNED NOT NULL,
  tienda_id INT UNSIGNED NOT NULL,
  cuestionario_id INT UNSIGNED NOT NULL
) ENGINE=MEMORY;

-- Distribuye las otras 100 encuestas de cada plaza entre sus tiendas y todos
-- sus PFS en ciclo. Cada PFS recibe la misma cantidad o una diferencia maxima
-- de una encuesta cuando la division no es exacta.
INSERT INTO tmp_encuestas_prueba (encuesta_id, plaza_id, numero, usuario_id, tienda_id, cuestionario_id)
SELECT
  UUID(),
  tiendas.plaza_id,
  numeros.numero,
  COALESCE(pfs.usuario_id, cualquier_usuario.usuario_id),
  tiendas.tienda_id,
  cuestionarios.cuestionario_id
FROM (
  SELECT
    t.id AS tienda_id,
    t.plaza_id,
    ROW_NUMBER() OVER (PARTITION BY t.plaza_id ORDER BY t.id) AS orden_tienda,
    COUNT(*) OVER (PARTITION BY t.plaza_id) AS total_tiendas
  FROM tienda t
) tiendas
JOIN (
  SELECT
    c.plaza_id,
    MIN(c.id) AS cuestionario_id
  FROM cuestionario c
  WHERE c.activo = 1
  GROUP BY c.plaza_id
) cuestionarios ON cuestionarios.plaza_id = tiendas.plaza_id
LEFT JOIN (
  SELECT
    u.plaza_id,
    u.id AS usuario_id,
    ROW_NUMBER() OVER (PARTITION BY u.plaza_id ORDER BY u.id) AS orden_pfs,
    COUNT(*) OVER (PARTITION BY u.plaza_id) AS total_pfs
  FROM usuario u
  JOIN rol r ON r.id = u.rol_id
  WHERE r.nombre = 'PFS' AND u.plaza_id IS NOT NULL
) pfs ON pfs.plaza_id = tiendas.plaza_id
LEFT JOIN (
  SELECT plaza_id, MIN(id) AS usuario_id
  FROM usuario
  WHERE plaza_id IS NOT NULL
  GROUP BY plaza_id
) cualquier_usuario ON cualquier_usuario.plaza_id = tiendas.plaza_id
CROSS JOIN tmp_numeros_prueba numeros
WHERE tiendas.orden_tienda = MOD(numeros.numero - 1, tiendas.total_tiendas) + 1
  AND (pfs.orden_pfs IS NULL OR pfs.orden_pfs = MOD(numeros.numero - 1, pfs.total_pfs) + 1)
  AND COALESCE(pfs.usuario_id, cualquier_usuario.usuario_id) IS NOT NULL;

-- Crea las encuestas y conserva la marca de sincronizacion para que el panel
-- las incluya inmediatamente en los resultados.
INSERT INTO encuesta (
  id,
  usuario_id,
  tienda_id,
  cuestionario_id,
  comentario,
  fecha_creacion_local,
  sincronizado,
  fecha_sincronizacion
)
SELECT
  encuesta_id,
  usuario_id,
  tienda_id,
  cuestionario_id,
  'Encuesta de prueba generada para validacion',
  NOW(),
  1,
  NOW()
FROM tmp_encuestas_prueba;

-- Recorre toda la escala 0..10 para que las calificaciones sean variadas
-- entre encuestas, tiendas, preguntas y PFS.
INSERT INTO respuesta_detalle (
  id,
  encuesta_id,
  pregunta_id,
  calificacion
)
SELECT
  UUID(),
  e.encuesta_id,
  p.id,
  MOD(e.numero + e.usuario_id + e.tienda_id + p.id, 11)
FROM tmp_encuestas_prueba e
JOIN pregunta p
  ON p.cuestionario_id = e.cuestionario_id
 AND p.activo = 1;

COMMIT;

-- Resumen de lo generado.
SELECT
  COUNT(*) AS encuestas_generadas,
  COUNT(DISTINCT plaza_id) AS plazas_con_datos,
  COUNT(DISTINCT usuario_id) AS usuarios_con_datos,
  COUNT(DISTINCT tienda_id) AS tiendas_utilizadas
FROM tmp_encuestas_prueba;

SELECT
  p.id AS plaza_id,
  p.nombre AS plaza,
  COUNT(e.encuesta_id) AS encuestas_generadas
FROM plaza p
LEFT JOIN tmp_encuestas_prueba e ON e.plaza_id = p.id
GROUP BY p.id, p.nombre
ORDER BY p.id;

SELECT
  plaza_id,
  usuario_id AS pfs_usuario_id,
  COUNT(*) AS encuestas_generadas
FROM tmp_encuestas_prueba
GROUP BY plaza_id, usuario_id
ORDER BY plaza_id, usuario_id;

DROP TEMPORARY TABLE IF EXISTS tmp_encuestas_prueba;
DROP TEMPORARY TABLE IF EXISTS tmp_plazas_sin_cuestionario;
DROP TEMPORARY TABLE IF EXISTS tmp_numeros_prueba;
