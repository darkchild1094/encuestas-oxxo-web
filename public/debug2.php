<?php
/**
 * Debug avanzado - Ejecutar esto en https://fieldserviceplus.alwaysdata.net/nps/public/debug2.php
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Debug Avanzado</h1>";
echo "<pre>";

// 1. Info básica
echo "=== AMBIENTE ===\n";
echo "Script: " . __FILE__ . "\n";
echo "REQUEST_URI: " . $_SERVER['REQUEST_URI'] . "\n";
echo "SCRIPT_NAME: " . $_SERVER['SCRIPT_NAME'] . "\n";
echo "PHP_SELF: " . $_SERVER['PHP_SELF'] . "\n";
echo "SCRIPT_FILENAME: " . $_SERVER['SCRIPT_FILENAME'] . "\n";

// 2. Verificar que index.php existe y se puede incluir
echo "\n=== ARCHIVOS CRÍTICOS ===\n";
$files = [
    'index.php',
    '../src/Auth.php',
    '../config/database.php',
    '../controllers/AuthController.php',
];

foreach ($files as $file) {
    $path = __DIR__ . '/' . $file;
    if (file_exists($path)) {
        echo "✓ $file EXISTS\n";
        if (is_readable($path)) {
            echo "  ✓ Readable\n";
        } else {
            echo "  ✗ NOT READABLE (permisos)\n";
        }
    } else {
        echo "✗ $file NOT FOUND\n";
    }
}

// 3. Intentar incluir index.php con try-catch
echo "\n=== INTENTAR INCLUIR index.php ===\n";
try {
    // Cambiar a public y simular una petición GET /login
    $_SERVER['REQUEST_METHOD'] = 'GET';
    $_SERVER['REQUEST_URI'] = '/nps/login';
    
    ob_start();
    require_once __DIR__ . '/index.php';
    $output = ob_get_clean();
    
    echo "✓ index.php se incluyó sin errores\n";
    echo "Output length: " . strlen($output) . " bytes\n";
    if (strlen($output) > 500) {
        echo "Preview (primeros 500 chars):\n";
        echo substr($output, 0, 500) . "\n...\n";
    } else {
        echo "Output:\n" . $output . "\n";
    }
} catch (Throwable $e) {
    echo "✗ ERROR:\n";
    echo "Message: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . "\n";
    echo "Line: " . $e->getLine() . "\n";
    echo "Stack:\n" . $e->getTraceAsString() . "\n";
}

// 4. Verificar permisos de escritura
echo "\n=== PERMISOS ===\n";
$dirs = [
    __DIR__,
    __DIR__ . '/uploads',
    __DIR__ . '/uploads/perfiles',
    sys_get_temp_dir(),
];

foreach ($dirs as $dir) {
    echo "$dir: ";
    if (is_writable($dir)) {
        echo "✓ writable\n";
    } else {
        echo "✗ NOT writable\n";
    }
}

// 5. Verificar BD
echo "\n=== BASE DE DATOS ===\n";
require_once __DIR__ . '/../config/database.php';
try {
    $pdo = Database::conexion();
    echo "✓ BD conectada\n";
    $tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    echo "Tablas: " . implode(", ", $tables) . "\n";
} catch (Exception $e) {
    echo "✗ Error BD: " . $e->getMessage() . "\n";
}

echo "</pre>";
