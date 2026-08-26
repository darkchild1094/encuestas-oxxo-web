<?php

declare(strict_types=1);

namespace Reportes;

/**
 * Genera archivos .xlsx reales (formato OOXML) sin ninguna dependencia
 * externa -- ni Composer, ni PhpSpreadsheet, ni la extension `zip` de PHP
 * (usa MiniZip). Pensado para los reportes de este proyecto: varias hojas,
 * encabezados con color, anchos de columna automaticos, formato de
 * numero para decimales, y graficas de barras nativas de Excel (no
 * imagenes).
 */
final class XlsxWriter
{
    /**
     * mbstring no siempre esta disponible en el hosting -- usamos
     * substr/strlen de bytes UTF-8 pero con cuidado de no cortar un
     * caracter multibyte a la mitad (que rompe la cadena y truena el XML).
     */
    private static function largo(string $s): int
    {
        if (function_exists('mb_strlen')) {
            return mb_strlen($s);
        }
        // Aproximacion en bytes UTF-8: cuenta solo los bytes que NO son
        // continuacion (10xxxxxx), asi el largo se acerca al de caracteres.
        return strlen(preg_replace('/[\x80-\xBF]/', '', $s));
    }

    private static function recorta(string $s, int $maxCaracteres): string
    {
        if (function_exists('mb_substr')) {
            return mb_substr($s, 0, $maxCaracteres);
        }
        // Recorta por bytes pero sin partir un caracter UTF-8 a la mitad.
        $recorte = substr($s, 0, $maxCaracteres * 4);
        while ($recorte !== '' && (ord($recorte[strlen($recorte) - 1]) & 0xC0) === 0x80) {
            $recorte = substr($recorte, 0, -1);
        }
        return $recorte;
    }

    /** @var array<int, array{nombre:string, columnas:array, filas:array, anchoColumnas:array, filaCongelada:bool}> */
    private array $hojas = [];

    /** @var array<int, array{hojaIndice:int, titulo:string, columnaCategoria:string, columnasValor:array}> */
    private array $graficas = [];

    /** @var array<string, int> */
    private array $cadenasIndice = [];
    /** @var array<int, string> */
    private array $cadenasLista = [];

    /**
     * @param array<int, array{titulo:string, formato?:string}> $columnas
     * @param array<int, array<int, mixed>> $filas
     */
    public function agregarHoja(string $nombre, array $columnas, array $filas, bool $congelarEncabezado = true): int
    {
        $anchos = [];
        foreach ($columnas as $i => $col) {
            $largoTitulo = self::largo((string) $col['titulo']);
            $anchos[$i] = max(10, $largoTitulo + 3);
        }
        foreach ($filas as $fila) {
            foreach ($fila as $i => $valor) {
                $largo = self::largo((string) $valor);
                if (($anchos[$i] ?? 0) < $largo + 2) {
                    $anchos[$i] = min(60, $largo + 2);
                }
            }
        }

        $this->hojas[] = [
            'nombre' => self::recorta(preg_replace('/[\\\\\/:?*\[\]]/', '-', $nombre) ?: 'Hoja', 31),
            'columnas' => $columnas,
            'filas' => $filas,
            'anchoColumnas' => $anchos,
            'filaCongelada' => $congelarEncabezado,
        ];

        return count($this->hojas) - 1;
    }

    /**
     * @param int $hojaIndice Indice regresado por agregarHoja()
     * @param array<int, string> $columnasValor Titulos exactos de columnas numericas a graficar
     */
    public function agregarGraficaBarras(int $hojaIndice, string $titulo, string $columnaCategoria, array $columnasValor): void
    {
        $this->graficas[] = [
            'hojaIndice' => $hojaIndice,
            'titulo' => $titulo,
            'columnaCategoria' => $columnaCategoria,
            'columnasValor' => $columnasValor,
        ];
    }

    public function generar(): string
    {
        $zip = new MiniZip();

        $zip->agregar('[Content_Types].xml', $this->contentTypesXml());
        $zip->agregar('_rels/.rels', $this->relsRaizXml());
        $zip->agregar('xl/workbook.xml', $this->workbookXml());
        $zip->agregar('xl/_rels/workbook.xml.rels', $this->workbookRelsXml());
        $zip->agregar('xl/styles.xml', $this->stylesXml());

        foreach ($this->hojas as $indice => $hoja) {
            $numero = $indice + 1;
            $graficasDeEstaHoja = array_values(array_filter($this->graficas, fn($g) => $g['hojaIndice'] === $indice));

            $zip->agregar("xl/worksheets/sheet{$numero}.xml", $this->hojaXml($hoja, count($graficasDeEstaHoja) > 0));

            if ($graficasDeEstaHoja) {
                $zip->agregar("xl/worksheets/_rels/sheet{$numero}.xml.rels", $this->hojaRelsXml($numero));
                $zip->agregar("xl/drawings/drawing{$numero}.xml", $this->drawingXml($graficasDeEstaHoja, count($hoja['filas'])));
                $zip->agregar("xl/drawings/_rels/drawing{$numero}.xml.rels", $this->drawingRelsXml($numero, count($graficasDeEstaHoja)));
                foreach (array_values($graficasDeEstaHoja) as $gIndice => $grafica) {
                    $zip->agregar("xl/charts/chart{$numero}_{$gIndice}.xml", $this->chartXml($hoja, $grafica));
                }
            }
        }

        $zip->agregar('xl/sharedStrings.xml', $this->sharedStringsXml());

        return $zip->generar();
    }

    // ---------------------------------------------------------------
    // Shared strings
    // ---------------------------------------------------------------

    private function indiceCadena(string $texto): int
    {
        if (!isset($this->cadenasIndice[$texto])) {
            $this->cadenasIndice[$texto] = count($this->cadenasLista);
            $this->cadenasLista[] = $texto;
        }
        return $this->cadenasIndice[$texto];
    }

    private function sharedStringsXml(): string
    {
        $total = count($this->cadenasLista);
        $items = '';
        foreach ($this->cadenasLista as $texto) {
            $items .= '<si><t xml:space="preserve">' . $this->escapar($texto) . '</t></si>';
        }
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="' . $total . '" uniqueCount="' . $total . '">'
            . $items . '</sst>';
    }

    private function escapar(string $s): string
    {
        return htmlspecialchars($s, ENT_XML1 | ENT_COMPAT, 'UTF-8');
    }

    // ---------------------------------------------------------------
    // Estructura general del workbook
    // ---------------------------------------------------------------

    private function contentTypesXml(): string
    {
        $overrides = '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
            . '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
            . '<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>';

        foreach ($this->hojas as $indice => $hoja) {
            $numero = $indice + 1;
            $overrides .= '<Override PartName="/xl/worksheets/sheet' . $numero . '.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>';

            $graficasDeEstaHoja = array_values(array_filter($this->graficas, fn($g) => $g['hojaIndice'] === $indice));
            if ($graficasDeEstaHoja) {
                $overrides .= '<Override PartName="/xl/drawings/drawing' . $numero . '.xml" ContentType="application/vnd.openxmlformats-officedocument.drawing+xml"/>';
                foreach (array_keys($graficasDeEstaHoja) as $gIndice) {
                    $overrides .= '<Override PartName="/xl/charts/chart' . $numero . '_' . $gIndice . '.xml" ContentType="application/vnd.openxmlformats-officedocument.drawingml.chart+xml"/>';
                }
            }
        }

        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            . '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            . '<Default Extension="xml" ContentType="application/xml"/>'
            . $overrides . '</Types>';
    }

    private function relsRaizXml(): string
    {
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
            . '</Relationships>';
    }

    private function workbookXml(): string
    {
        $sheets = '';
        foreach ($this->hojas as $indice => $hoja) {
            $numero = $indice + 1;
            $sheets .= '<sheet name="' . $this->escapar($hoja['nombre']) . '" sheetId="' . $numero . '" r:id="rId' . $numero . '"/>';
        }
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
            . '<sheets>' . $sheets . '</sheets></workbook>';
    }

    private function workbookRelsXml(): string
    {
        $rels = '';
        foreach ($this->hojas as $indice => $hoja) {
            $numero = $indice + 1;
            $rels .= '<Relationship Id="rId' . $numero . '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet' . $numero . '.xml"/>';
        }
        $siguiente = count($this->hojas) + 1;
        $rels .= '<Relationship Id="rId' . $siguiente . '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>';
        $rels .= '<Relationship Id="rId' . ($siguiente + 1) . '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>';
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' . $rels . '</Relationships>';
    }

    // ---------------------------------------------------------------
    // Estilos: 0 normal(con borde), 1 encabezado, 2 numero 1 decimal,
    // 3 entero, 4 titulo grande (sin usarse desde afuera por ahora)
    // ---------------------------------------------------------------

    private function stylesXml(): string
    {
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
            . '<numFmts count="1"><numFmt numFmtId="164" formatCode="0.0"/></numFmts>'
            . '<fonts count="4">'
            . '<font><sz val="11"/><name val="Calibri"/></font>'
            . '<font><sz val="11"/><name val="Calibri"/><b/><color rgb="FFFFFFFF"/></font>'
            . '<font><sz val="11"/><name val="Calibri"/></font>'
            . '<font><sz val="16"/><name val="Calibri"/><b/><color rgb="FFD71921"/></font>'
            . '</fonts>'
            . '<fills count="3">'
            . '<fill><patternFill patternType="none"/></fill>'
            . '<fill><patternFill patternType="gray125"/></fill>'
            . '<fill><patternFill patternType="solid"><fgColor rgb="FFD71921"/><bgColor indexed="64"/></patternFill></fill>'
            . '</fills>'
            . '<borders count="2">'
            . '<border><left/><right/><top/><bottom/><diagonal/></border>'
            . '<border><left style="thin"><color rgb="FFD9D9D9"/></left><right style="thin"><color rgb="FFD9D9D9"/></right><top style="thin"><color rgb="FFD9D9D9"/></top><bottom style="thin"><color rgb="FFD9D9D9"/></bottom><diagonal/></border>'
            . '</borders>'
            . '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
            . '<cellXfs count="5">'
            . '<xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1"/>'
            . '<xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf>'
            . '<xf numFmtId="164" fontId="0" fillId="0" borderId="1" xfId="0" applyNumFmt="1" applyBorder="1"/>'
            . '<xf numFmtId="1" fontId="0" fillId="0" borderId="1" xfId="0" applyNumFmt="1" applyBorder="1"/>'
            . '<xf numFmtId="0" fontId="3" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
            . '</cellXfs>'
            . '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
            . '</styleSheet>';
    }

    // ---------------------------------------------------------------
    // Hoja individual
    // ---------------------------------------------------------------

    private function colLetra(int $indiceCero): string
    {
        $n = $indiceCero + 1;
        $letra = '';
        while ($n > 0) {
            $resto = ($n - 1) % 26;
            $letra = chr(65 + $resto) . $letra;
            $n = intdiv($n - 1, 26);
        }
        return $letra;
    }

    private function estiloParaFormato(?string $formato): int
    {
        return match ($formato) {
            'numero' => 2,
            'entero' => 3,
            default => 0,
        };
    }

    private function hojaXml(array $hoja, bool $tieneGraficas): string
    {
        $columnas = $hoja['columnas'];
        $filas = $hoja['filas'];

        $colsXml = '<cols>';
        foreach ($hoja['anchoColumnas'] as $i => $ancho) {
            $colsXml .= '<col min="' . ($i + 1) . '" max="' . ($i + 1) . '" width="' . $ancho . '" customWidth="1"/>';
        }
        $colsXml .= '</cols>';

        $sheetData = '<row r="1" ht="22" customHeight="1">';
        foreach ($columnas as $i => $col) {
            $ref = $this->colLetra($i) . '1';
            $idx = $this->indiceCadena((string) $col['titulo']);
            $sheetData .= '<c r="' . $ref . '" s="1" t="s"><v>' . $idx . '</v></c>';
        }
        $sheetData .= '</row>';

        foreach ($filas as $fIdx => $fila) {
            $numeroFila = $fIdx + 2;
            $sheetData .= '<row r="' . $numeroFila . '">';
            foreach ($fila as $cIdx => $valor) {
                $ref = $this->colLetra($cIdx) . $numeroFila;
                $formato = $columnas[$cIdx]['formato'] ?? 'texto';
                $estilo = $this->estiloParaFormato($formato);

                if ($formato === 'numero' || $formato === 'entero') {
                    $numero = is_numeric($valor) ? $valor : 0;
                    $sheetData .= '<c r="' . $ref . '" s="' . $estilo . '"><v>' . $numero . '</v></c>';
                } else {
                    $idx = $this->indiceCadena((string) $valor);
                    $sheetData .= '<c r="' . $ref . '" s="' . $estilo . '" t="s"><v>' . $idx . '</v></c>';
                }
            }
            $sheetData .= '</row>';
        }

        $panelCongelado = $hoja['filaCongelada']
            ? '<sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>'
            : '<sheetViews><sheetView workbookViewId="0"/></sheetViews>';

        $filasTotales = count($filas) + 1;
        $colFinal = $this->colLetra(max(0, count($columnas) - 1));
        $dimension = '<dimension ref="A1:' . $colFinal . $filasTotales . '"/>';

        $drawingTag = $tieneGraficas ? '<drawing r:id="rId1"/>' : '';

        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
            . $dimension
            . $panelCongelado
            . $colsXml
            . '<sheetData>' . $sheetData . '</sheetData>'
            . $drawingTag
            . '</worksheet>';
    }

    // ---------------------------------------------------------------
    // Graficas: drawing (donde se coloca) + chart (la grafica en si)
    // ---------------------------------------------------------------

    private function hojaRelsXml(int $numeroHoja): string
    {
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing" Target="../drawings/drawing' . $numeroHoja . '.xml"/>'
            . '</Relationships>';
    }

    private function drawingXml(array $graficas, int $totalFilasDatos): string
    {
        $anchors = '';
        $filaBase = $totalFilasDatos + 3; // deja espacio debajo de la tabla
        foreach (array_values($graficas) as $i => $grafica) {
            $filaInicio = $filaBase + ($i * 20);
            $filaFin = $filaInicio + 18;
            $anchors .= '<xdr:twoCellAnchor>'
                . '<xdr:from><xdr:col>0</xdr:col><xdr:colOff>0</xdr:colOff><xdr:row>' . $filaInicio . '</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:from>'
                . '<xdr:to><xdr:col>8</xdr:col><xdr:colOff>0</xdr:colOff><xdr:row>' . $filaFin . '</xdr:row><xdr:rowOff>0</xdr:rowOff></xdr:to>'
                . '<xdr:graphicFrame macro="">'
                . '<xdr:nvGraphicFramePr><xdr:cNvPr id="' . ($i + 2) . '" name="Grafica' . ($i + 1) . '"/><xdr:cNvGraphicFramePr/></xdr:nvGraphicFramePr>'
                . '<xdr:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/></xdr:xfrm>'
                . '<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/chart">'
                . '<c:chart xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:id="rId' . ($i + 1) . '"/>'
                . '</a:graphicData></a:graphic>'
                . '</xdr:graphicFrame>'
                . '<xdr:clientData/>'
                . '</xdr:twoCellAnchor>';
        }

        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<xdr:wsDr xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">'
            . $anchors . '</xdr:wsDr>';
    }

    private function drawingRelsXml(int $numeroHoja, int $totalGraficas): string
    {
        $rels = '';
        for ($i = 0; $i < $totalGraficas; $i++) {
            $rels .= '<Relationship Id="rId' . ($i + 1) . '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart" Target="../charts/chart' . $numeroHoja . '_' . $i . '.xml"/>';
        }
        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' . $rels . '</Relationships>';
    }

    private function colorSerie(int $indice): string
    {
        $paleta = ['D71921', 'FFC72C', '2E86AB', '5A5F63', '6BAA75'];
        return $paleta[$indice % count($paleta)];
    }

    private function chartXml(array $hoja, array $grafica): string
    {
        $nombreHoja = $this->escapar($hoja['nombre']);
        $columnas = array_column($hoja['columnas'], 'titulo');
        $colCategoria = array_search($grafica['columnaCategoria'], $columnas, true);
        $totalFilas = count($hoja['filas']);
        $ultimaFila = $totalFilas + 1;

        $refCategoria = "'" . $nombreHoja . "'!\$" . $this->colLetra((int) $colCategoria) . "\$2:\$" . $this->colLetra((int) $colCategoria) . "\$" . $ultimaFila;
        $catCache = '';
        foreach ($hoja['filas'] as $i => $fila) {
            $catCache .= '<c:pt idx="' . $i . '"><c:v>' . $this->escapar((string) $fila[$colCategoria]) . '</c:v></c:pt>';
        }

        $series = '';
        foreach (array_values($grafica['columnasValor']) as $sIdx => $tituloCol) {
            $colValor = array_search($tituloCol, $columnas, true);
            $refTitulo = "'" . $nombreHoja . "'!\$" . $this->colLetra((int) $colValor) . "\$1";
            $refValor = "'" . $nombreHoja . "'!\$" . $this->colLetra((int) $colValor) . "\$2:\$" . $this->colLetra((int) $colValor) . "\$" . $ultimaFila;
            $valCache = '';
            foreach ($hoja['filas'] as $i => $fila) {
                $v = is_numeric($fila[$colValor]) ? $fila[$colValor] : 0;
                $valCache .= '<c:pt idx="' . $i . '"><c:v>' . $v . '</c:v></c:pt>';
            }

            $series .= '<c:ser>'
                . '<c:idx val="' . $sIdx . '"/><c:order val="' . $sIdx . '"/>'
                . '<c:tx><c:strRef><c:f>' . $refTitulo . '</c:f><c:strCache><c:ptCount val="1"/><c:pt idx="0"><c:v>' . $this->escapar($tituloCol) . '</c:v></c:pt></c:strCache></c:strRef></c:tx>'
                . '<c:spPr><a:solidFill><a:srgbClr val="' . $this->colorSerie($sIdx) . '"/></a:solidFill></c:spPr>'
                . '<c:cat><c:strRef><c:f>' . $refCategoria . '</c:f><c:strCache><c:ptCount val="' . $totalFilas . '"/>' . $catCache . '</c:strCache></c:strRef></c:cat>'
                . '<c:val><c:numRef><c:f>' . $refValor . '</c:f><c:numCache><c:formatCode>0.0</c:formatCode><c:ptCount val="' . $totalFilas . '"/>' . $valCache . '</c:numCache></c:numRef></c:val>'
                . '</c:ser>';
        }

        $titulo = $this->escapar($grafica['titulo']);

        return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<c:chartSpace xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
            . '<c:chart>'
            . '<c:title><c:tx><c:rich><a:bodyPr/><a:p><a:r><a:t>' . $titulo . '</a:t></a:r></a:p></c:rich></c:tx><c:overlay val="0"/></c:title>'
            . '<c:autoTitleDeleted val="0"/>'
            . '<c:plotArea><c:layout/>'
            . '<c:barChart><c:barDir val="col"/><c:grouping val="clustered"/>'
            . $series
            . '<c:axId val="111111111"/><c:axId val="222222222"/>'
            . '</c:barChart>'
            . '<c:catAx><c:axId val="111111111"/><c:scaling><c:orientation val="minMax"/></c:scaling><c:delete val="0"/><c:axPos val="b"/><c:crossAx val="222222222"/></c:catAx>'
            . '<c:valAx><c:axId val="222222222"/><c:scaling><c:orientation val="minMax"/></c:scaling><c:delete val="0"/><c:axPos val="l"/><c:crossAx val="111111111"/></c:valAx>'
            . '</c:plotArea>'
            . '<c:legend><c:legendPos val="b"/></c:legend>'
            . '<c:plotVisOnly val="1"/>'
            . '</c:chart>'
            . '</c:chartSpace>';
    }
}
