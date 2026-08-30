<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

class AuthApiController
{
    public function login(): void
    {
        $datos = json_decode(file_get_contents('php://input'), true) ?? [];
        $correo = trim($datos['correo'] ?? '');
        $password = $datos['password'] ?? '';

        $pdo = Database::conexion();
        $stmt = $pdo->prepare('
            SELECT u.id, u.correo, u.nombre_completo, u.password_hash,
                   u.debe_cambiar_password, u.foto_perfil, u.genero,
                   u.plaza_id, pl.nombre AS plaza_nombre,
                   r.nombre AS rol, r.gestiona_preguntas,
                   (r.gestiona_usuarios OR u.id = 128) AS gestiona_usuarios,
                   r.es_encuestable, r.ve_resultados_tiendas
            FROM usuario u
            JOIN rol r ON r.id = u.rol_id
            LEFT JOIN plaza pl ON pl.id = u.plaza_id
            WHERE u.correo = :correo
            LIMIT 1
        ');
        $stmt->execute(['correo' => $correo]);
        $usuario = $stmt->fetch();

        if (!$usuario || !password_verify($password, $usuario['password_hash'])) {
            http_response_code(401);
            echo json_encode(['error' => 'Correo o password incorrectos']);
            return;
        }

        // MySQL regresa BOOLEAN como 1/0 (enteros). Sin este cast,
        // json_encode manda "1" en vez de "true" y Gson en Android
        // truena (espera boolean literal, no numero).
        $usuario['id'] = (int) $usuario['id'];
        $usuario['gestiona_preguntas'] = (bool) $usuario['gestiona_preguntas'];
        $usuario['gestiona_usuarios'] = (bool) $usuario['gestiona_usuarios'];
        $usuario['es_encuestable'] = (bool) $usuario['es_encuestable'];
        $usuario['ve_resultados_tiendas'] = (bool) $usuario['ve_resultados_tiendas'];
        $usuario['debe_cambiar_password'] = (bool) $usuario['debe_cambiar_password'];

        if ($usuario['plaza_id'] !== null) {
            $usuario['plaza_id'] = (int) $usuario['plaza_id'];
        }

        $token = bin2hex(random_bytes(32));

        // Antes se borraba CUALQUIER token anterior de este usuario_id
        // en cada login. Eso invalidaba sesiones activas en otros
        // dispositivos (o la sesion recordada del mismo dispositivo) --
        // si justo en ese momento habia encuestas pendientes de subir
        // con el token viejo, se quedaban muertas para siempre (la app
        // solo reintentaba con un token que ya nunca iba a funcionar).
        // Ahora cada login simplemente AGREGA un token nuevo; los viejos
        // siguen validos hasta su propia fecha de expiracion.
        //
        // Aprovechamos que ya estamos escribiendo en esta tabla para
        // limpiar tokens vencidos de paso (de cualquier usuario) y que
        // la tabla no crezca sin limite.
        $pdo->exec('DELETE FROM token_acceso WHERE fecha_expiracion < NOW()');

        // "Para siempre" en la practica: 10 anios. DATETIME de MySQL
        // aguanta hasta el 9999, pero no tiene sentido una sesion mas
        // larga que eso -- para cuando expire, seguro ya cambio de
        // telefono varias veces.
        $stmt = $pdo->prepare('
            INSERT INTO token_acceso (token, usuario_id, fecha_expiracion)
            VALUES (:token, :usuario_id, DATE_ADD(NOW(), INTERVAL 10 YEAR))
        ');
        $stmt->execute(['token' => $token, 'usuario_id' => $usuario['id']]);

        unset($usuario['password_hash']);
        echo json_encode(['token' => $token, 'usuario' => $usuario]);
    }

    // GET /api/auth/validar -- para que la app confirme al abrir que su
    // token guardado sigue siendo valido, y si no, mande a login de una
    // vez en vez de descubrirlo a medias de un sync fallido en silencio.
    public function validar(): void
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(['valido' => false]);
            return;
        }
        echo json_encode(['valido' => true]);
    }
}
