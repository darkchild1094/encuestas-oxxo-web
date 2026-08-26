-- Tabla para registrar intentos de sincronización y errores
CREATE TABLE IF NOT EXISTS encuesta_sync_log (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    encuesta_id CHAR(36) NOT NULL,
    usuario_id INT UNSIGNED,
    tienda_id INT UNSIGNED NOT NULL,
    intento_numero INT UNSIGNED NOT NULL DEFAULT 1,
    estado ENUM('pendiente', 'enviando', 'exito', 'error') NOT NULL DEFAULT 'pendiente',
    codigo_respuesta INT,
    mensaje_error TEXT,
    handshake_id CHAR(36), -- UUID para confirmar recepción
    confirmado_servidor TINYINT(1) DEFAULT 0,
    fecha_intento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_confirmacion DATETIME,
    INDEX idx_encuesta (encuesta_id),
    INDEX idx_estado (estado),
    INDEX idx_tienda (tienda_id),
    INDEX idx_handshake (handshake_id),
    FOREIGN KEY (encuesta_id) REFERENCES encuesta(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índice para optimizar búsquedas de PFS
CREATE INDEX idx_tienda_estado ON encuesta_sync_log(tienda_id, estado);
