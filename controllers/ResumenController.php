<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../src/Auth.php';

/**
 * "Resumen del sistema" para el rol WEBMASTER: un vistazo al estado
 * general (usuarios por rol, catalogo, actividad reciente, version de la
 * app publicada). Todo de solo lectura.
 */
class ResumenController
{
    public function index(): void
    {
        Auth::requiereLogin();
        if (($_SESSION['rol'] ?? '') !== 'WEBMASTER') {
            header('Location: ' . BASE_URL . '/');
            exit;
        }

        $pdo = Database::conexion();

        $usuariosPorRol = $pdo->query('
            SELECT r.nombre AS rol, COUNT(u.id) AS total
            FROM rol r
            LEFT JOIN usuario u ON u.rol_id = r.id
            GROUP BY r.id
            ORDER BY total DESC, r.nombre
        ')->fetchAll();

        $conteos = $pdo->query("
            SELECT
              (SELECT COUNT(*) FROM usuario) AS usuarios,
              (SELECT COUNT(*) FROM tienda) AS tiendas,
              (SELECT COUNT(*) FROM plaza) AS plazas,
              (SELECT COUNT(*) FROM encuesta) AS encuestas,
              (SELECT COUNT(*) FROM encuesta WHERE fecha_creacion_local >= (CURRENT_DATE - INTERVAL 7 DAY)) AS encuestas_7d,
              (SELECT COUNT(*) FROM encuesta WHERE fecha_creacion_local >= (CURRENT_DATE - INTERVAL 30 DAY)) AS encuestas_30d,
              (SELECT COUNT(*) FROM usuario WHERE debe_cambiar_password = 1) AS pendientes_password
        ")->fetch();

        // token_acceso puede no existir en instalaciones viejas: se
        // consulta aparte y si truena se ignora.
        $tokensActivos = null;
        try {
            $tokensActivos = (int) $pdo->query(
                'SELECT COUNT(*) FROM token_acceso WHERE fecha_expiracion > NOW()'
            )->fetchColumn();
        } catch (Throwable $e) {
            // tabla ausente o sin permisos: se muestra "n/d"
        }

        $ultimasEncuestas = $pdo->query("
            SELECT e.fecha_creacion_local AS fecha, t.nombre AS tienda, p.nombre AS plaza
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            ORDER BY e.fecha_creacion_local DESC
            LIMIT 8
        ")->fetchAll();

        $versionApp = [];
        $vf = __DIR__ . '/../config/version.json';
        if (is_file($vf)) {
            $versionApp = json_decode((string) file_get_contents($vf), true) ?: [];
        }

        $tituloPagina = 'Resumen del sistema';
        require __DIR__ . '/../views/resumen.php';
    }
}
