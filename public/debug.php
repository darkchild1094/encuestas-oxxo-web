<?php
/**
 * Archivo de diagnóstico para debugging en producción
 * Elimina este archivo después de usar en producción
 */

// No iniciar sesión aún, primero mostrar info
echo "<h1>Diagnóstico del Sistema</h1>";
echo "<pre>";

// 1. Info del servidor
echo "=== SERVIDOR ===\n";
echo "PHP Version: " . PHP_VERSION . "\n";
echo "Extensiones cargadas: " . (extension_loaded('pdo') ? '✓ PDO' : '✗ PDO FALTA') . "\n";
echo "Extensiones MySQL: " . (extension_loaded('pdo_mysql') ? '✓ PDO_MYSQL' : '✗ PDO_MYSQL FALTA') . "\n";

// 2. Rutas y permisos
echo "\n=== RUTAS Y PERMISOS ===\n";
echo "Script: " . __FILE__ . "\n";
echo "BASE_URL calculado: " . rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/') . "\n";
echo "REQUEST_URI: " . $_SERVER['REQUEST_URI'] . "\n";

$sessionDir = sys_get_temp_dir();
echo "Session dir: " . $sessionDir . "\n";
echo "Session dir writable: " . (is_writable($sessionDir) ? '✓ Sí' : '✗ No') . "\n";

// 3. Intentar conexión a BD
echo "\n=== CONEXIÓN A BASE DE DATOS ===\n";
require_once __DIR__ . '/../config/database.php';

try {
    $pdo = Database::conexion();
    echo "✓ Conexión exitosa\n";
    
    // Verificar tablas
    $stmt = $pdo->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "Tablas encontradas: " . count($tables) . "\n";
    echo "Tablas: " . implode(", ", $tables) . "\n";
} catch (Exception $e) {
    echo "✗ Error de conexión:\n";
    echo $e->getMessage() . "\n";
}

echo "</pre>";
echo "<hr>";
echo "<p><strong>Importante:</strong> Elimina este archivo después de diagnosticar.</p>";
