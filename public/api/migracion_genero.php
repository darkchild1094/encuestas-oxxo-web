<?php
require_once __DIR__ . '/../../config/database.php';

try {
    $pdo = Database::conexion();

    // Agregar columna genero a usuario if not exists
    $stmt = $pdo->query("SHOW COLUMNS FROM `usuario` LIKE 'genero'");
    if (!$stmt->fetch()) {
        $pdo->exec("ALTER TABLE `usuario` ADD COLUMN `genero` CHAR(1) DEFAULT 'M' AFTER `foto_perfil` COMMENT 'H=Hombre, M=Mujer'");
        echo "Columna 'genero' agregada a tabla 'usuario'.\n";

        // Intentar poblar con heuristica inicial
        $usuarios = $pdo->query("SELECT id, nombre_completo FROM usuario")->fetchAll();
        $stmtUpdate = $pdo->prepare("UPDATE usuario SET genero = :g WHERE id = :id");
        foreach ($usuarios as $u) {
            $nombre = trim($u['nombre_completo']);
            $genero = "H";
            if (preg_match('/[aA]$/', explode(' ', $nombre)[0])) {
                $genero = "M";
            }
            $stmtUpdate->execute(['g' => $genero, 'id' => $u['id']]);
        }
        echo "Heuristica de genero aplicada a usuarios existentes.\n";
    } else {
        echo "La columna 'genero' ya existe.\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
