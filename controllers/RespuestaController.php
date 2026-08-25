<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../src/Auth.php';

// Solo ATI entra aqui (ve_resultados_tiendas). Ni webmaster ni
// usuario normal ven esta pantalla.
class RespuestaController
{
    private function query(array $filtros): array
    {
        $sql = '
            SELECT
                e.id AS encuesta_id, e.tienda_id, e.folio, e.fecha_creacion_local, e.comentario,
                t.nombre AS tienda, p.nombre AS plaza, r.nombre AS region, n.nombre AS negocio,
                ati.id AS ati_id, ati.nombre_completo AS ati_nombre,
                u.correo AS usuario,
                preg.texto AS pregunta, rd.calificacion
            FROM encuesta e
            JOIN tienda t ON t.id = e.tienda_id
            JOIN plaza p ON p.id = t.plaza_id
            JOIN region r ON r.id = p.region_id
            JOIN negocio n ON n.id = r.negocio_id
            LEFT JOIN usuario u ON u.id = e.usuario_id
            LEFT JOIN usuario ati ON ati.id = t.asesor_ti_usuario_id
            JOIN respuesta_detalle rd ON rd.encuesta_id = e.id
            JOIN pregunta preg ON preg.id = rd.pregunta_id
            WHERE t.plaza_id = :plaza_id
        ';
        // El ATI SOLO ve resultados de las tiendas donde el mismo es
        // el asesor TI asignado (tienda.asesor_ti_usuario_id) -- ya
        // no ve todas las tiendas del sistema.
        $params = ['plaza_id' => $_SESSION['plaza_id']];

        if (!empty($filtros['ati_id'])) {
            $sql .= ' AND t.asesor_ti_usuario_id = :ati_id';
            $params['ati_id'] = $filtros['ati_id'];
        }

        if (!empty($filtros['plaza_id'])) {
            $sql .= ' AND p.id = :plaza_id';
            $params['plaza_id'] = $filtros['plaza_id'];
        }
        if (!empty($filtros['tienda_id'])) {
            $sql .= ' AND t.id = :tienda_id';
            $params['tienda_id'] = $filtros['tienda_id'];
        }
        if (!empty($filtros['desde'])) {
            $sql .= ' AND e.fecha_creacion_local >= :desde';
            $params['desde'] = $filtros['desde'] . ' 00:00:00';
        }
        if (!empty($filtros['hasta'])) {
            $sql .= ' AND e.fecha_creacion_local <= :hasta';
            $params['hasta'] = $filtros['hasta'] . ' 23:59:59';
        }

        $sql .= ' ORDER BY e.fecha_creacion_local DESC, preg.es_fija ASC, preg.orden';

        $pdo = Database::conexion();
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    private function filtrosDesdeGet(): array
    {
        return [
            'plaza_id' => $_GET['plaza_id'] ?? null,
            'tienda_id' => $_GET['tienda_id'] ?? null,
            'ati_id' => $_GET['ati_id'] ?? null,
            'desde' => $_GET['desde'] ?? null,
            'hasta' => $_GET['hasta'] ?? null,
        ];
    }

    public function index(): void
    {
        if (($_SESSION['rol'] ?? '') !== 'ATI') {
            http_response_code(403);
            echo 'Solo el rol ATI puede consultar las respuestas de tiendas.';
            exit;
        }
        Auth::requierePermiso('ve_resultados_tiendas');
        $pdo = Database::conexion();

        $stmt = $pdo->prepare('
            SELECT id, nombre FROM tienda
            WHERE plaza_id = :plaza_id
            ORDER BY nombre
        ');
        $stmt->execute(['plaza_id' => $_SESSION['plaza_id']]);
        $tiendas = $stmt->fetchAll();

        $stmt = $pdo->prepare("\n            SELECT u.id, u.nombre_completo\n            FROM usuario u\n            JOIN rol r ON r.id = u.rol_id\n            WHERE r.nombre = 'ATI' AND u.plaza_id = :plaza_id\n            ORDER BY u.nombre_completo\n        ");
        $stmt->execute(['plaza_id' => $_SESSION['plaza_id']]);
        $atis = $stmt->fetchAll();

        $filas = $this->query($this->filtrosDesdeGet());
        $tiendasConRespuestas = [];
        foreach ($filas as $fila) {
            $id = (int) $fila['tienda_id'];
            if (!isset($tiendasConRespuestas[$id])) {
                $tiendasConRespuestas[$id] = [
                    'id' => $id,
                    'codigo' => $fila['tienda_codigo'] ?? '',
                    'nombre' => $fila['tienda'],
                    'encuestas' => [],
                ];
            }
            $tiendasConRespuestas[$id]['encuestas'][$fila['encuesta_id']] = true;
        }
        foreach ($tiendasConRespuestas as &$tienda) {
            $tienda['total_encuestas'] = count($tienda['encuestas']);
            unset($tienda['encuestas']);
        }
        unset($tienda);
        $tiendas = array_values($tiendasConRespuestas);
        usort($tiendas, static fn(array $a, array $b): int => strcasecmp($a['nombre'], $b['nombre']));

        require __DIR__ . '/../views/respuestas/lista.php';
    }

    public function exportarExcel(): void
    {
        if (($_SESSION['rol'] ?? '') !== 'ATI') {
            http_response_code(403);
            echo 'Solo el rol ATI puede exportar las respuestas de tiendas.';
            exit;
        }
        Auth::requierePermiso('ve_resultados_tiendas');
        $filas = $this->query($this->filtrosDesdeGet());

        // Exportacion basica: tabla HTML con content-type de Excel.
        // Abre bien en Excel y LibreOffice Calc sin depender de
        // ninguna libreria. Si despues se necesita un .xlsx real con
        // formato/formulas, se agrega PhpSpreadsheet via composer.
        header('Content-Type: application/vnd.ms-excel; charset=utf-8');
        header('Content-Disposition: attachment; filename="respuestas_' . date('Y-m-d_His') . '.xls"');

        echo "<table border='1'>";
        echo '<tr>
                <th>Folio</th><th>Fecha</th><th>Negocio</th><th>Region</th><th>Plaza</th><th>Tienda</th>
                <th>Usuario</th><th>Pregunta</th><th>Calificacion (1-10)</th><th>Comentario</th>
              </tr>';

        foreach ($filas as $fila) {
            echo '<tr>'
                . '<td>' . htmlspecialchars($fila['folio'] ?? '') . '</td>'
                . '<td>' . htmlspecialchars($fila['fecha_creacion_local']) . '</td>'
                . '<td>' . htmlspecialchars($fila['negocio']) . '</td>'
                . '<td>' . htmlspecialchars($fila['region']) . '</td>'
                . '<td>' . htmlspecialchars($fila['plaza']) . '</td>'
                . '<td>' . htmlspecialchars($fila['tienda']) . '</td>'
                . '<td>' . htmlspecialchars($fila['usuario'] ?? '(usuario eliminado)') . '</td>'
                . '<td>' . htmlspecialchars($fila['pregunta']) . '</td>'
                . '<td>' . (int) $fila['calificacion'] . '</td>'
                . '<td>' . htmlspecialchars($fila['comentario'] ?? '') . '</td>'
                . '</tr>';
        }

        echo '</table>';
        exit;
    }
}
