<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../src/ApiAuth.php';

class AuthApiController
{
    public function login()
    {
        $json = file_get_contents('php://input');
        $datos = json_decode($json, true);
        if (!$datos) $datos = array();

        $correo = isset($datos['correo']) ? trim($datos['correo']) : '';
        $password = isset($datos['password']) ? $datos['password'] : '';

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
        $stmt->execute(array('correo' => $correo));
        $usuario = $stmt->fetch();

        if (!$usuario || !password_verify($password, $usuario['password_hash'])) {
            http_response_code(401);
            echo json_encode(array('error' => 'Correo o password incorrectos'));
            return;
        }

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

        $pdo->exec('DELETE FROM token_acceso WHERE fecha_expiracion < NOW()');

        $stmt = $pdo->prepare('
            INSERT INTO token_acceso (token, usuario_id, fecha_expiracion)
            VALUES (:token, :usuario_id, DATE_ADD(NOW(), INTERVAL 10 YEAR))
        ');
        $stmt->execute(array('token' => $token, 'usuario_id' => $usuario['id']));

        unset($usuario['password_hash']);
        echo json_encode(array('token' => $token, 'usuario' => $usuario));
    }

    public function validar()
    {
        $usuario = ApiAuth::usuarioDesdeToken();
        if (!$usuario) {
            http_response_code(401);
            echo json_encode(array('valido' => false));
            return;
        }
        echo json_encode(array('valido' => true));
    }
}
