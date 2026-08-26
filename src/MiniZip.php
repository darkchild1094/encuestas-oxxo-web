<?php

declare(strict_types=1);

namespace Reportes;

/**
 * Escritor de archivos ZIP minimo, sin depender de la extension `zip` de PHP
 * (que no todos los hostings tienen habilitada). Usa gzdeflate() de zlib,
 * que si es parte del core de PHP practicamente siempre.
 *
 * Solo implementa lo necesario para producir un .xlsx valido: compresion
 * deflate por archivo, CRC32, encabezados locales + directorio central +
 * EOCD. No soporta ZIP64, streaming ni cifrado -- de sobra para hojas de
 * calculo de tamano normal.
 */
final class MiniZip
{
    /** @var array<int, array{nombre:string, datos:string}> */
    private array $entradas = [];

    public function agregar(string $nombreArchivo, string $contenido): void
    {
        $this->entradas[] = ['nombre' => $nombreArchivo, 'datos' => $contenido];
    }

    public function generar(): string
    {
        $cuerpoLocal = '';
        $directorioCentral = '';
        $offset = 0;

        foreach ($this->entradas as $entrada) {
            $nombre = $entrada['nombre'];
            $datos = $entrada['datos'];
            $crc = crc32($datos);
            $comprimido = gzdeflate($datos, 6);
            $tiempoDos = $this->fechaHoraDos();

            $encabezadoLocal = "PK\x03\x04"
                . pack('v', 20)          // version necesaria
                . pack('v', 0)           // flags
                . pack('v', 8)           // metodo: 8 = deflate
                . pack('V', $tiempoDos)  // fecha/hora DOS
                . pack('V', $crc)
                . pack('V', strlen($comprimido))
                . pack('V', strlen($datos))
                . pack('v', strlen($nombre))
                . pack('v', 0)           // extra field length
                . $nombre;

            $cuerpoLocal .= $encabezadoLocal . $comprimido;

            $directorioCentral .= "PK\x01\x02"
                . pack('v', 20)          // version que crea
                . pack('v', 20)          // version necesaria
                . pack('v', 0)
                . pack('v', 8)
                . pack('V', $tiempoDos)
                . pack('V', $crc)
                . pack('V', strlen($comprimido))
                . pack('V', strlen($datos))
                . pack('v', strlen($nombre))
                . pack('v', 0)
                . pack('v', 0)
                . pack('v', 0)
                . pack('v', 0)
                . pack('V', 0)
                . pack('V', $offset)
                . $nombre;

            $offset += strlen($encabezadoLocal) + strlen($comprimido);
        }

        $eocd = "PK\x05\x06"
            . pack('v', 0)
            . pack('v', 0)
            . pack('v', count($this->entradas))
            . pack('v', count($this->entradas))
            . pack('V', strlen($directorioCentral))
            . pack('V', $offset)
            . pack('v', 0);

        return $cuerpoLocal . $directorioCentral . $eocd;
    }

    private function fechaHoraDos(): int
    {
        // Formato fecha/hora DOS que pide el ZIP -- no importa que no sea
        // exacto, Excel no lo usa para nada al abrir el archivo.
        return ((2024 - 1980) << 25) | (1 << 21) | (1 << 16);
    }
}
