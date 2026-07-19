<?php
class Database
{
    private static ?PDO $pdo = null;
    public static function conexion(): PDO
    {
        if (self::$pdo === null) {
            $host = 'mysql-fieldserviceplus.alwaysdata.net';
            $db   = 'fieldserviceplus_nps';
            $user = 'fieldserviceplus_rahuag';
            $pass = 'Admin.12';
            $dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
            self::$pdo = new PDO($dsn, $user, $pass, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);
        }
        return self::$pdo;
    }
}
