<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../src/Auth.php';

// Solo webmaster entra aqui (gestiona_usuarios). Es el catalogo de
// areas administrativas de oficina (RH, Mantenimiento, Asesores...)
// que se usa como "destino" en la encuesta de oficina, igual que las
// tiendas lo son en la encuesta de tienda.
class AdministracionController
{
    public function index(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $pdo = Database::conexion();

        $areas = $pdo->query('
            SELECT id, nombre, activo, fecha_registro
            FROM administracion
            ORDER BY nombre
        ')->fetchAll();

        // Cuantas encuestas de oficina cuelgan de cada area, para
        // avisar en la UI que borrarla sera un apagado logico.
        $conteos = [];
        foreach ($pdo->query('
            SELECT administracion_id, COUNT(*) AS n
            FROM encuesta
            WHERE administracion_id IS NOT NULL
            GROUP BY administracion_id
        ')->fetchAll() as $fila) {
            $conteos[(int) $fila['administracion_id']] = (int) $fila['n'];
        }

        require __DIR__ . '/../views/administracion/lista.php';
    }

    public function crear(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $nombre = trim($_POST['nombre'] ?? '');

        if ($nombre === '' || mb_strlen($nombre) > 120) {
            $_SESSION['error_admin'] = 'El nombre del area es obligatorio (max 120 caracteres).';
            header('Location: ' . BASE_URL . '/administracion');
            exit;
        }

        $pdo = Database::conexion();
        try {
            $stmt = $pdo->prepare('INSERT INTO administracion (nombre) VALUES (:n)');
            $stmt->execute(['n' => $nombre]);
        } catch (PDOException $e) {
            $_SESSION['error_admin'] = ($e->getCode() === '23000')
                ? 'Ya existe un area con ese nombre.'
                : 'No se pudo crear el area.';
            error_log('[administracion/crear] ' . $e->getMessage());
            header('Location: ' . BASE_URL . '/administracion');
            exit;
        }

        $_SESSION['mensaje'] = 'Area creada.';
        header('Location: ' . BASE_URL . '/administracion');
        exit;
    }

    public function editar(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $id = (int) ($_POST['id'] ?? 0);
        $nombre = trim($_POST['nombre'] ?? '');

        if ($id <= 0 || $nombre === '' || mb_strlen($nombre) > 120) {
            $_SESSION['error_admin'] = 'Revisa los datos: el nombre es obligatorio.';
            header('Location: ' . BASE_URL . '/administracion');
            exit;
        }

        $pdo = Database::conexion();
        try {
            $stmt = $pdo->prepare('UPDATE administracion SET nombre = :n WHERE id = :id');
            $stmt->execute(['n' => $nombre, 'id' => $id]);
        } catch (PDOException $e) {
            $_SESSION['error_admin'] = ($e->getCode() === '23000')
                ? 'Ya existe un area con ese nombre.'
                : 'No se pudo renombrar el area.';
            error_log('[administracion/editar] ' . $e->getMessage());
            header('Location: ' . BASE_URL . '/administracion');
            exit;
        }

        $_SESSION['mensaje'] = 'Area actualizada.';
        header('Location: ' . BASE_URL . '/administracion');
        exit;
    }

    public function activar(): void
    {
        $this->cambiarActivo(1, 'Area reactivada.');
    }

    public function desactivar(): void
    {
        $this->cambiarActivo(0, 'Area desactivada: ya no aparece en la encuesta de oficina.');
    }

    private function cambiarActivo(int $valor, string $mensaje): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $id = (int) ($_POST['id'] ?? 0);
        if ($id <= 0) {
            header('Location: ' . BASE_URL . '/administracion');
            exit;
        }

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('UPDATE administracion SET activo = :v WHERE id = :id');
        $stmt->execute(['v' => $valor, 'id' => $id]);

        $_SESSION['mensaje'] = $mensaje;
        header('Location: ' . BASE_URL . '/administracion');
        exit;
    }

    public function eliminar(): void
    {
        Auth::requierePermiso('gestiona_usuarios');
        $id = (int) ($_POST['id'] ?? 0);
        if ($id <= 0) {
            header('Location: ' . BASE_URL . '/administracion');
            exit;
        }

        $pdo = Database::conexion();

        // Borrado fisico si se puede; si hay encuestas ligadas la FK
        // (RESTRICT en DELETE) lo impide y caemos a apagado logico,
        // igual que PreguntaController::eliminar con las preguntas.
        try {
            $stmt = $pdo->prepare('DELETE FROM administracion WHERE id = :id');
            $stmt->execute(['id' => $id]);
            $_SESSION['mensaje'] = 'Area eliminada.';
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                $stmt = $pdo->prepare('UPDATE administracion SET activo = 0 WHERE id = :id');
                $stmt->execute(['id' => $id]);
                $_SESSION['mensaje'] = 'El area tiene encuestas ligadas: se desactivo en vez de borrarse.';
            } else {
                $_SESSION['error_admin'] = 'No se pudo eliminar el area.';
                error_log('[administracion/eliminar] ' . $e->getMessage());
            }
        }

        header('Location: ' . BASE_URL . '/administracion');
        exit;
    }
}
