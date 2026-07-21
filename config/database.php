<?php
class Database
{
    private static ?PDO $pdo = null;
    public static function conexion(): PDO
    {
        if (self::$pdo === null) {
            // Las credenciales reales YA NO viven aqui -- este archivo es
            // publico en GitHub y antes traia la password de la BD en
            // texto plano. Ahora se leen de config/credenciales.php,
            // que esta en .gitignore y nunca se sube al repo.
            //
            // EN EL SERVIDOR (alwaysdata): crea manualmente el archivo
            // config/credenciales.php (mismo directorio que este) usando
            // config/credenciales.php.example como plantilla, con la
            // password real. Sin ese archivo, esto truena a proposito
            // en vez de quedarse sin credenciales validas.
            $credenciales = __DIR__ . '/credenciales.php';
            if (!file_exists($credenciales)) {
                http_response_code(500);
                die('Falta config/credenciales.php en el servidor. Ver config/credenciales.php.example.');
            }
            require $credenciales; // debe definir $host, $db, $user, $pass

            $dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
            self::$pdo = new PDO($dsn, $user, $pass, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                // Reutiliza la conexion TCP a MySQL entre requests en vez
                // de abrir una nueva cada vez -- alwaysdata separa el
                // host de PHP del de MySQL, asi que esto ahorra el
                // round-trip de conectar en cada llamada a la API.
                PDO::ATTR_PERSISTENT => true,
            ]);
        }
        return self::$pdo;
    }
}
