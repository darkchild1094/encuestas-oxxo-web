<?php

require_once __DIR__ . '/../config/database.php';

// Antes esta misma logica (leer el header Authorization + validar el
// token contra la BD) estaba copiada y pegada en 5 controladores
// distintos, cada quien con su propio SELECT ligeramente distinto.
// Un solo lugar: mas facil de mantener y, sobre todo, un solo punto
// donde optimizar la consulta que se ejecuta en CADA request
// autenticado de la app.
class ApiAuth
{
    // $_SERVER['HTTP_AUTHORIZATION'] muchas veces llega vacio con
    // Apache+PHP a menos que el servidor este configurado para
    // pasarlo explicitamente (CGIPassAuth). getallheaders() es el
    // fallback que si lo encuentra sin tocar config de Apache.
    private static function obtenerHeaderAuth(): string
    {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        if ($header === '' && function_exists('getallheaders')) {
            $headers = getallheaders();
            $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        }
        return $header;
    }

    // Valida el header "Authorization: Bearer <token>" contra
    // token_acceso y regresa el usuario dueno del token (con todos
    // los flags de permiso, para que cada controlador revise el que
    // le toca), o null si el token no vino, no existe o vencio.
    //
    // NOTA de rendimiento: esta consulta se ejecuta en TODOS los
    // requests autenticados de la app (negocios, regiones, plazas,
    // tiendas, cuestionario, encuestas, respuestas, usuarios,
    // preguntas...). token_acceso.token necesita un indice/UNIQUE
    // para que esto sea una busqueda directa y no un escaneo de
    // toda la tabla en cada llamada -- ver sql/migracion_indices.sql.
    public static function usuarioDesdeToken(): ?array
    {
        $header = self::obtenerHeaderAuth();
        if (!preg_match('/Bearer\s+(\S+)/', $header, $m)) {
            return null;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            SELECT u.id, r.gestiona_preguntas, r.gestiona_usuarios,
                   r.es_encuestable, r.ve_resultados_tiendas
            FROM token_acceso ta
            JOIN usuario u ON u.id = ta.usuario_id
            JOIN rol r ON r.id = u.rol_id
            WHERE ta.token = :token AND ta.fecha_expiracion > NOW()
            LIMIT 1
        ');
        $stmt->execute(['token' => $m[1]]);
        $fila = $stmt->fetch();
        if (!$fila) {
            return null;
        }

        $fila['id'] = (int) $fila['id'];
        $fila['gestiona_preguntas'] = (bool) $fila['gestiona_preguntas'];
        $fila['gestiona_usuarios'] = (bool) $fila['gestiona_usuarios'];
        $fila['es_encuestable'] = (bool) $fila['es_encuestable'];
        $fila['ve_resultados_tiendas'] = (bool) $fila['ve_resultados_tiendas'];
        return $fila;
    }
}
