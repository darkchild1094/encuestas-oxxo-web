-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: mysql-fieldserviceplus.alwaysdata.net
-- Generation Time: Aug 25, 2026 at 10:24 AM
-- Server version: 10.11.18-MariaDB
-- PHP Version: 8.4.24

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fieldserviceplus_nps`
--

-- --------------------------------------------------------

--
-- Table structure for table `cuestionario`
--

CREATE TABLE `cuestionario` (
  `id` int(10) UNSIGNED NOT NULL,
  `plaza_id` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cuestionario`
--

INSERT INTO `cuestionario` (`id`, `plaza_id`, `nombre`, `activo`) VALUES
(1, 1, 'Encuesta de satisfaccion', 1);

-- --------------------------------------------------------

--
-- Table structure for table `encuesta`
--

CREATE TABLE `encuesta` (
  `id` char(36) NOT NULL,
  `usuario_id` int(10) UNSIGNED DEFAULT NULL,
  `tienda_id` int(10) UNSIGNED NOT NULL,
  `cuestionario_id` int(10) UNSIGNED NOT NULL,
  `folio` varchar(50) DEFAULT NULL,
  `comentario` text DEFAULT NULL,
  `fecha_creacion_local` datetime NOT NULL,
  `sincronizado` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_sincronizacion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `negocio`
--

CREATE TABLE `negocio` (
  `id` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `es_default` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `negocio`
--

INSERT INTO `negocio` (`id`, `nombre`, `es_default`) VALUES
(1, 'OXXO', 1);

-- --------------------------------------------------------

--
-- Table structure for table `plaza`
--

CREATE TABLE `plaza` (
  `id` int(10) UNSIGNED NOT NULL,
  `region_id` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `cr` varchar(10) DEFAULT NULL,
  `es_default` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `plaza`
--

INSERT INTO `plaza` (`id`, `region_id`, `nombre`, `cr`, `es_default`) VALUES
(1, 1, 'Ciudad Valles', '32YXH', 1),
(2, 1, 'Ciudad Victoria', '32HJR', 0),
(3, 1, 'Matamoros', '32WPF', 0),
(4, 1, 'Tampico', '32RNA', 0);

-- --------------------------------------------------------

--
-- Table structure for table `pregunta`
--

CREATE TABLE `pregunta` (
  `id` int(10) UNSIGNED NOT NULL,
  `cuestionario_id` int(10) UNSIGNED NOT NULL,
  `creado_por_usuario_id` int(10) UNSIGNED DEFAULT NULL,
  `texto` varchar(255) NOT NULL,
  `orden` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `es_fija` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pregunta`
--

INSERT INTO `pregunta` (`id`, `cuestionario_id`, `creado_por_usuario_id`, `texto`, `orden`, `activo`, `es_fija`) VALUES
(1, 1, NULL, 'En una escala del 0 al 10. ¿Como calificarias en general el servicio del area de TI?', 9999, 1, 1),
(2, 1, NULL, 'En una escala del 0 al 10 ¿Que tan satisfecho estás con la atención y servicio proporcionado por el Prestador de Field Service (PFS) cuando tienes una incidencia?', 2, 1, 0),
(3, 1, NULL, 'En una escala del 0 al 10 ¿Que tan satisfecho estás con el funcionamiento de las plataformas y herramientas tecnológicas que utilizas en tu tienda?', 3, 1, 0),
(5, 1, 128, 'En una escala del 0 al 10 ¿Que tan satisfecho estás con el tiempo y la efectividad con que TI resuelve tus incidencias?', 4, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `region`
--

CREATE TABLE `region` (
  `id` int(10) UNSIGNED NOT NULL,
  `negocio_id` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `cr` varchar(10) DEFAULT NULL,
  `es_default` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `region`
--

INSERT INTO `region` (`id`, `negocio_id`, `nombre`, `cr`, `es_default`) VALUES
(1, 1, 'Tamaulipas', '10UMI', 1);

-- --------------------------------------------------------

--
-- Table structure for table `respuesta_detalle`
--

CREATE TABLE `respuesta_detalle` (
  `id` char(36) NOT NULL,
  `encuesta_id` char(36) NOT NULL,
  `pregunta_id` int(10) UNSIGNED NOT NULL,
  `calificacion` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rol`
--

CREATE TABLE `rol` (
  `id` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `gestiona_preguntas` tinyint(1) NOT NULL DEFAULT 0,
  `gestiona_usuarios` tinyint(1) NOT NULL DEFAULT 0,
  `es_encuestable` tinyint(1) NOT NULL DEFAULT 0,
  `ve_resultados_tiendas` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rol`
--

INSERT INTO `rol` (`id`, `nombre`, `gestiona_preguntas`, `gestiona_usuarios`, `es_encuestable`, `ve_resultados_tiendas`) VALUES
(1, 'ATI', 1, 0, 0, 1),
(2, 'WEBMASTER', 1, 1, 1, 0),
(3, 'PFS', 0, 0, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `tienda`
--

CREATE TABLE `tienda` (
  `id` int(10) UNSIGNED NOT NULL,
  `plaza_id` int(10) UNSIGNED NOT NULL,
  `codigo` varchar(20) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `latitud` decimal(10,7) DEFAULT NULL,
  `longitud` decimal(10,7) DEFAULT NULL,
  `asesor_ti_usuario_id` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tienda`
--

INSERT INTO `tienda` (`id`, `plaza_id`, `codigo`, `nombre`, `direccion`, `latitud`, `longitud`, `asesor_ti_usuario_id`) VALUES
(1, 1, '500FM', 'Paso del Humo', 'Calle Insurgentes, #617, Col. California , Pueblo Viejo, Veracruz, México, 92033, entre 12 De Mayo Y Benito Juárez', 22.2056498, -97.8439232, 129),
(2, 1, '50D30', 'El Sion Tam', 'Carretera Nacional, #S/N, Col. Santa Elena, Pueblo Viejo, Veracruz, México, 92030, entre Esq, Miguel Aleman', 22.1933025, -97.8346104, 129),
(3, 1, '50DRN', 'Los Cocos Tam', 'Calle 20 De Noviembre, #806, Col. Anahuac, Pueblo Viejo, Veracruz, México, 92035, entre Violeta Y Camelia', 22.2080466, -97.8611097, 129),
(4, 1, '50DT8', 'El Rio Tam', 'Calle Insurgentes, #704, Col. California , Pueblo Viejo, Veracruz, México, 92033, entre J.O De Domínguez Y Emiliano Zapata', 22.2074264, -97.8395522, 129),
(5, 1, '50GZU', 'California Tam', 'Avenida Benito Juarez, #109, Col. California , Pueblo Viejo, Veracruz, México, 92033, entre Francisco I. Madero Y 16 De Septiembre', 22.2024827, -97.8424381, 129),
(6, 1, '50HXA', 'Anahuac Tam', 'Calle 20 De Noviembre, #101, Col. Anahuac, Pueblo Viejo, Veracruz, México, 92035, entre Geranio Y Tulipan', 22.2055165, -97.8534921, 129),
(7, 1, '50IM5', 'Carretera Nacional Maf', 'Calle Benito Juarez, #S/N, Col. Benito Juarez, Pueblo Viejo, Veracruz, México, 92033, entre ', 22.1982263, -97.8382790, 129),
(8, 1, '50JCL', 'La Loma Tam', 'Calle Colombia, #111, Col. Anahuac, Pueblo Viejo, Veracruz, México, 92035, entre Matamoros Y Morelia', 22.1976155, -97.8555570, 129),
(9, 1, '50O56', 'Independencia Tam', 'Calle Ignacio Allende, #1101, Col. California , Pueblo Viejo, Veracruz, México, 92033, entre Esq. Independencia Y Emiliano Zapata', 22.2039800, -97.8371100, 129),
(10, 1, '501IO', 'Matinchild Tam', 'Calle Morelos, #5001, Col. Ozuluama De Mascareñas, Ozuluama, Veracruz, México, 92080, entre Esquina Matinchild Y Nacional Hidalgo', 21.6630747, -97.8517972, 129),
(11, 1, '5022Z', 'El Mango Tam', 'Calle Mangle, #307, Col. Primero De Mayo, Pueblo Viejo, Veracruz, México, 92039, entre Esq. Reforma De La Congr, Entre Campesino Y Tule', 22.2237704, -97.8201420, 129),
(12, 1, '506WR', 'Gas Cuauhtemoc Tam', 'Carretera Tampico Tuxpan Km 175+600, #S/N, Col. Ciudad Cuauhtemoc, Pueblo Viejo, Veracruz, México, 92030, entre Ave. Lazaro Cardenas E Ignacio Allende', 22.1929447, -97.8252318, 129),
(13, 1, '5084Z', 'Veteranos Tam', 'Calle Francisco I Madero, #606-A, Col. Ciudad Cuauhtemoc, Pueblo Viejo, Veracruz, México, 92030, entre Esquina Calle Sin Nombre Y La Laguna', 22.1786048, -97.8361449, 129),
(14, 1, '50C7P', 'Horconcitos Tam', 'Carretera Tuxpan Tampico Km. 148, #5308, Col. Horconcitos, Ozuluama, Veracruz, México, 92080, entre Sin Entre Calles', 21.8498592, -97.7493161, 129),
(15, 1, '50CXO', 'Ozuluama Centro Tam', 'Calle Matamoros, #101, Col. Ozuluama De Mascareñas, Ozuluama, Veracruz, México, 92080, entre Francisco Javier Mina Y Ac De Los 14', 21.6599176, -97.8501806, 129),
(16, 1, '50EG5', 'Villa Tampico Tam', 'Carretera Tampico-Poza Rica, #S/N, Col. Buenavista, Tampico Alto, Veracruz, México, 92055, entre Esq.Camino A Mata De Chavez', 22.1098653, -97.8036020, 129),
(17, 1, '50K2P', 'Abasolo Tam', 'Calle J De La Luz Enriquez, #S/N, Col. Ciudad Cuauhtemoc, Pueblo Viejo, Veracruz, México, 92030, entre Esq. Pablo A. Gutierrez Y Mariano Abasolo', 22.1879000, -97.8342000, 129),
(18, 1, '50K5T', 'Mata Redonda Tam', 'Calle 20 De Noviembre, #409, Col. Mata Redonda, Pueblo Viejo, Veracruz, México, 92037, entre Jose Maria Morelos Y Calle 1 Dicha', 22.2288193, -97.8277806, 129),
(19, 1, '50KOJ', 'Edarsi Tam', 'Carretera Tuxpan Tampico Km 124+269.5-A, #S/N, Col. Ozuluama De Mascareñas, Ozuluama, Veracruz, México, 92080, entre Congregacion Encinal Y Meza', 21.7981573, -97.7727056, 129),
(20, 1, '50LDJ', 'Pueblo Viejo Tam', 'Calle Abasolo, #21, Col. Ciudad Cuauhtemoc, Pueblo Viejo, Veracruz, México, 92030, entre Lazaro Cardenas Y Benito Juarez', 22.1845903, -97.8362164, 129),
(21, 1, '50OPF', 'Tampico Alto II Tam', 'Calle Carranza, #S/N, Col. Centro, Tampico Alto, Veracruz, México, 92050, entre Esq. Vicente Guerrero Y Jose Maria Morelos', 22.1114030, -97.8011370, 129),
(22, 1, '50OZL', 'Ozuluama Ii Tam', 'Carretera Tampico-Tuxpam, #S/N, Col. Ozuluama De Mascareñas, Ozuluama, Veracruz, México, 92080, entre Blvd.Sara Garcia Iglesias Y Calle Sin Nombre', 21.6750403, -97.8598394, 129),
(23, 1, '50OZU', 'Ozuluama Tam', 'Carretera Tuxpan Tampico, #KM 126+523.8, Col. Ozuluama De Mascareñas, Ozuluama, Veracruz, México, 92080, entre Dentro De La Gasolinera Servicio Ozuluama', 21.6845983, -97.8549675, 129),
(24, 1, '50SNN', 'Congreg Hidalgo Tam', 'Calle Independencia, #901-C, Col. Hidalgo, Pueblo Viejo, Veracruz, México, 92037, entre Hombres Ilustres Y Primero De Mayo', 22.2367397, -97.8300033, 129),
(25, 1, '5080M', 'Cruz Tam', 'Calle Pino Suarez, #32, Col. La Cruz, Panuco, Veracruz, México, 93996, entre Desiderio Pavón Y Adalberto Tejeda', 22.0497090, -98.1785925, 129),
(26, 1, '50AGD', 'Burocrata Tam', 'Calle Salvador Diaz Miron, #1001, Col. Burocrata, Panuco, Veracruz, México, 93998, entre 5 De Mayo Y Loma Verde', 22.0578619, -98.1869665, 129),
(27, 1, '50DGC', 'Flores Magon Tam', 'Calle Ricardo Flores Magon, #S/N, Col. Zurita, Panuco, Veracruz, México, 93997, entre Cuauhtemoc Y Zapata', 22.0535256, -98.1823304, 129),
(28, 1, '50IPO', 'Tempoal Centro Tam', 'Calle 5 De Febrero, #10-A, Col. Centro, Tempoal, Veracruz, México, 92060, entre Hidalgo E Independencia', 21.5209546, -98.3952150, 129),
(29, 1, '50JWA', 'Santos Tam', 'Calle Mariano Escobedo, #27-A, Col. La Brisa, Tempoal, Veracruz, México, 92063, entre Santos Degollado E Ignacio De La Llave', 21.5221375, -98.3914051, 129),
(30, 1, '50TI2', 'Llave Tam', 'Calle Santos Degollado, #8-A, Col. La Brisa, Tempoal, Veracruz, México, 92063, entre Esq.5 De Mayo Y Aldama', 21.5197000, -98.3914000, 129),
(31, 1, '50TPY', 'Tempoal Tam', 'Carretera Tuxpan-Tampico, #KM 139, Col. Tempoal De Sanchez, Tempoal, Veracruz, México, 92060, entre Dentro De La Gasolinera', 21.5231334, -98.3798279, 129),
(32, 1, '50WM8', 'La Gloria Tam', 'Calle 5 De Mayo, #79, Col. 20 De Noviembre, Tempoal, Veracruz, México, 92063, entre Eutiquio Bravo Y Adalberto Tejada', 21.5161449, -98.3824960, 129),
(33, 1, '50X0E', 'Gas Tempoal Tam', 'Carretera Federal Tuxpan Tampico, #101-A , Col. Llano Grande, Tempoal, Veracruz, México, 92075, entre Carretera Huejutla De Reyes Y Ave 5 De Mayo', 21.4930343, -98.3569612, 129),
(34, 1, '501W1', 'Gas Jaibo Tam', 'Boulevard Salvador Diaz, #S/N, Col. Corregidora, Panuco, Veracruz, México, 93995, entre Esq. Carretera Panuco Tempoal Y Lic. Guillermo Dia', 22.0460899, -98.1911686, 129),
(35, 1, '50BDR', 'Olmecas Tam', 'Prolongacion Venustiano Carranza, #S/N, Col. Electricista, Panuco, Veracruz, México, 93994, entre Esq. Olmecas', 22.0414595, -98.1824095, 129),
(36, 1, '50JBU', 'Panuco Dif Tam', 'Calle Flores Magon, #10, Col. Revolucion Mexicana, Panuco, Veracruz, México, 93997, entre Nicolas Hernandez Y Calle R. Flores Magon', 22.0500177, -98.1899044, 129),
(37, 1, '50MT3', '21 De Abril Tam', 'Calle Cuautla, #S/N, Col. Venustiano Carranza, Panuco, Veracruz, México, 93994, entre 21 De Abril Y Jose Azueta', 22.0379611, -98.1868000, 129),
(38, 1, '50OS4', '05 De Febrero Tam', 'Boulevard S. Diaz Miron, #S/N, Col. Revolucion Mexicana, Panuco, Veracruz, México, 93997, entre 05 De Febrero Y 24 De Febrero', 22.0532771, -98.1888534, 129),
(39, 1, '50PUC', 'Panuco II Tam', 'Boulevard Diaz Miron, #S/N, Col. Rafael Hernandez Ochoa, Panuco, Veracruz, México, 93995, entre Carret. Fed. Panuco Tempoal', 22.0456466, -98.1920340, 129),
(40, 1, '50QFG', 'Panuco Iv Tam', 'Calle Carranza, #16, Col. Panuco Centro, Panuco, Veracruz, México, 93990, entre 16 De Septiembre Y Fco. De J.Colorado', 22.0495806, -98.1827407, 129),
(41, 1, '5004C', 'Aquiles Serdan Tam', 'Calle Benito Juarez, #110, Col. Deportiva, San Vicente Tancuayalab, San Luis Potosi, México, 79820, entre Aquiles Serdan Y Julian Carrillo', 21.7139846, -98.5859814, 129),
(42, 1, '50AGP', 'San Vicente Tam', 'Carretera Xolol Tamuin Km 37 \"A\", #S/N, Col. Deportiva, San Vicente Tancuayalab, San Luis Potosi, México, 79820, entre Al Higo Y Calle Florida', 21.7181165, -98.5886067, 129),
(43, 1, '50D37', 'Tanquian Escobedo Maf', 'Calle Fray Andres  De Olmos, #53, Col. Tanquian De Escobedo, Tanquian De Escobedo, San Luis Potosi, México, 79840, entre ', 21.6091186, -98.6611923, 129),
(44, 1, '50GUB', 'Tanquian Tam', 'Calle Independencia, #19, Col. Tanquian De Escobedo, Tanquian De Escobedo, San Luis Potosi, México, 79840, entre Vicente Guerrero Y Mariano Escobedo', 21.5988000, -98.6634423, 129),
(45, 1, '500BP', 'Ebano Carretera Tam', 'Calle Lazaro Cardenas, #9, Col. Dieciocho De Marzo, Ebano, San Luis Potosi, México, 79160, entre Vicente Guerrero Y Paciencia', 22.2176034, -98.3772980, 129),
(46, 1, '50264', 'Corregidora Tam', 'Avenida Pedro Antonio De Los Santos, #501, Col. Victor Manuel Santos, Tamuin, San Luis Potosi, México, 79202, entre Santos Degollado Y Corregidora', 22.0050419, -98.7690209, 129),
(47, 1, '506A4', 'Miguel Hidalgo  Tam', 'Calle Miguel Hidalgo, #99-A, Col. Obrera, Ebano, San Luis Potosi, México, 79140, entre Esq. Coahuila', 22.2121752, -98.3879670, 129),
(48, 1, '506ZZ', 'Yucatan Tam', 'Calle Lazaro Cardenas, #115-1, Col. Obrera, Ebano, San Luis Potosi, México, 79140, entre Zacatecas Y Yucatan', 22.2128112, -98.3964140, 129),
(49, 1, '50ARP', 'Larraga Tam', 'Calle Manuel C. Larraga, #49 B, Col. Antonio Bermudez, Ebano, San Luis Potosi, México, 79120, entre Melchor Ocampo Y Guillermo Prieto', 22.2231652, -98.3718434, 129),
(50, 1, '50EWK', 'Ebano Tam', 'Calle Vicente Guerrero, #1-A, Col. Tulipanes, Ebano, San Luis Potosi, México, 79170, entre 5 De Febrero Y Lazaro Cardenas', 22.2143100, -98.3746300, 129),
(51, 1, '50F4Z', 'La Estacion Tmp', 'Calle Manuel C. Larraga, #66, Col. Zostepec, Ebano, San Luis Potosi, México, 79110, entre Aquismon Y Privada Manuel C. Larraga', 22.2278751, -98.3692853, 129),
(52, 1, '50IMG', 'Tamuin Centro Tam', 'Calle Juarez, #202, Col. Centro, Tamuin, San Luis Potosi, México, 79200, entre Nicolas Bravo E Independencia', 22.0055106, -98.7746775, 129),
(53, 1, '50M3P', 'Pujal Coy Tam', 'Carretera Federal 70 Ciudad Valles Tampico, #1081-A , Col. Nuevo Progreso, Ebano, San Luis Potosi, México, 79293, entre Entre Puente Los Cerones Y Parador Tres Hermanos', 22.1520340, -98.5058330, 129),
(54, 1, '50O3Y', 'Huasteca Tmp', 'Carretera A Estacion Tamuin, #301, Col. Juarez, Tamuin, San Luis Potosi, México, 79206, entre Jarrilla Y Comonfort', 22.0083565, -98.7819901, 129),
(55, 1, '50QFS', 'Tres Filos Tam', 'Carretera Valles Tampico Km 21+600, #S/N, Col. Tamuin, Tamuin, San Luis Potosi, México, 79200, entre Tantoc Y Tunel Abra Taninul', 21.9703968, -98.8188430, 129),
(56, 1, '50ST3', 'Boulevard Tamuin Tam', 'Boulevard Adolfo López Mateos, #600, Col. Nuevo Tamuin, Tamuin, San Luis Potosi, México, 79207, entre 5 De Mayo Y 10 De Mayo', 22.0112034, -98.7885990, 129),
(57, 1, '50TUI', 'Tamuin Tam', 'Carretera Tampico Valles, #KM 54 + 800, Col. Tamuin, Tamuin, San Luis Potosi, México, 79200, entre Dentro Gasolinera Serv. Sarogar', 22.0775039, -98.6525403, 129),
(58, 1, '50VOG', 'Ebano Centro Tam', 'Avenida Benito Juarez, #47, Col. Veinte De Noviembre, Ebano, San Luis Potosi, México, 79161, entre Morelos Y Reforma', 22.2103107, -98.3787688, 129),
(59, 1, '50XDY', 'Iturbide Tam', 'Avenida Pedro Antonio De Los Santos, #600, Col. Lindavista, Tamuin, San Luis Potosi, México, 79205, entre Agustin De Iturbide Y Jarrilla', 22.0025619, -98.7798619, 129),
(60, 1, '500HQ', 'Santa Maria Tam', 'Calle Adolfo Lopez Mateos, #1103, Col. Morelos Y Pavon, Ciudad Valles, San Luis Potosi, México, 79010, entre Rio Caballero Y Felipe Angeles', 22.0055000, -99.0308590, 128),
(61, 1, '502AS', 'Soto Y Gama Tam', 'Calle Soto Y Gama, #329, Col. La Lajita, Ciudad Valles, San Luis Potosi, México, 79020, entre Esq. Costa Rica', 22.0102000, -99.0159580, 128),
(62, 1, '505GO', 'Tambaca Tam', 'Avenida 20 De Noviembre, #315, Col. Tambaca, Tamasopo, San Luis Potosi, México, 79730, entre Esq. Calle Panteon Y Durango', 21.9614000, -99.3022060, 128),
(63, 1, '507QF', 'Mexico Tam', 'Calle Mexico, #S/N, Col. Loma Bonita, Ciudad Valles, San Luis Potosi, México, 79020, entre Calle Palma Y Cedro', 22.0007094, -99.0189598, 128),
(64, 1, '50916', 'La Curva Tam', 'Calle 500, #101, Col. La Curva , Ciudad Valles, San Luis Potosi, México, 79033, entre Esq.Blvd. Lic.Adolfo Lopez Mateos Y Av.Ferrocarri', 21.9989687, -99.0243617, 128),
(65, 1, '50993', 'Emiliano Zapata Tam', 'Calle Gral Jose Maria Morelos, #800, Col. Morelos Y Pavon, Ciudad Valles, San Luis Potosi, México, 79010, entre Esq. Tehuacan', 22.0110927, -99.0261899, 128),
(66, 1, '509YH', 'Agua Buena Tam', 'Carretera A Tambaca, #2, Col. Agua Buena, Tamasopo, San Luis Potosi, México, 79703, entre A Lado De Plaza Principal', 21.9572721, -99.3924110, 128),
(67, 1, '509YS', 'Carretera Tamasopo Tam', 'Calle Ferrocarril, #111, Col. Tamasopo Centro, Tamasopo, San Luis Potosi, México, 79710, entre Carretera Tamasopo Y Estacion', 21.9272000, -99.3915000, 128),
(68, 1, '50APO', 'Praderas Del Rio Tam', 'Calle Camino Santa Rosa, #180, Col. Villa Del Sol, Ciudad Valles, San Luis Potosi, México, 79035, entre Rio Amazonas Y Acapulco', 22.0110984, -99.0537467, 128),
(69, 1, '50BMT', 'Santa Lucia Tam', 'Boulevard Adolfo Lopez Mateos, #1803, Col. Santa Lucia, Ciudad Valles, San Luis Potosi, México, 79019, entre Ave. Santa Lucia Y Tauro', 22.0089943, -99.0377581, 128),
(70, 1, '50GEC', 'El Consuelo Tam', 'Calle Pilar, #301, Col. El Consuelo, Ciudad Valles, San Luis Potosi, México, 79010, entre Julieta Y Elvira', 22.0270426, -99.0260080, 128),
(71, 1, '50GSH', 'Valles Tam', 'Carretera Valles-Rio Verde, #413, Col. Tetuan, Ciudad Valles, San Luis Potosi, México, 79090, entre La Puerta De Valles Y Ave. Pedro Antonio De Los Sa', 21.9924207, -99.0302368, 128),
(72, 1, '50JZ9', 'Tamasopo Tam', 'Calle Francisco I. Madero, #3, Col. Tamasopo Centro, Tamasopo, San Luis Potosi, México, 79710, entre Esq. Allende Y Miguel Hidalgo', 21.9221697, -99.3924950, 128),
(73, 1, '50K9Q', 'De Las Rosas Tam', 'Calle De Las Rosas, #500, Col. Dieciocho De Marzo, Ciudad Valles, San Luis Potosi, México, 79020, entre Encino Y Zasafras', 22.0060725, -99.0128719, 128),
(74, 1, '50NFH', 'La Pimienta Tam', 'Calle Constitucion, #500, Col. La Pimienta , Ciudad Valles, San Luis Potosi, México, 79068, entre Cedro Y Segunda Calle Palma', 22.0020355, -98.9980615, 128),
(75, 1, '50OR1', 'Avance  Tam', 'Calle Toltecas, #1000, Col. Francisco I Madero, Ciudad Valles, San Luis Potosi, México, 79040, entre Pedro J Méndez Y Privada Hilda', 21.9958470, -99.0192000, 128),
(76, 1, '50SFL', 'Doracely Tam', 'Avenida Mexico, #901, Col. Emiliano Zapata, Ciudad Valles, San Luis Potosi, México, 79020, entre Dalia Y Clavel', 22.0055010, -99.0195764, 128),
(77, 1, '50UT9', 'Vista Hermosa Tam', 'Calle Lic. Adolfo Lopez Mateos, #1400, Col. Vista Hermosa, Ciudad Valles, San Luis Potosi, México, 79010, entre Esq. Francisco Gonzalez Bocanegra Y Graciano Sanc', 22.0195523, -99.0273680, 128),
(78, 1, '50WXT', 'Aire Tam', 'Calle Pedro Antonio De Los Santos, #560, Col. Cuauhtemoc, Ciudad Valles, San Luis Potosi, México, 79040, entre Boulevard De La Feria Y 2 De Enero', 21.9934396, -99.0236648, 128),
(79, 1, '50380', 'El Cafetal Maf', 'Calle Francisco Villa, #1032, Col. Pedregal, Tamasopo, San Luis Potosi, México, 79712, entre ', 21.9232216, -99.3991513, 128),
(80, 1, '50ANI', 'Panuco I Tam', 'Avenida 5 De Mayo, #S/N, Col. Zona Centro, Panuco, Veracruz, México, 92000, entre Benito Juarez Y I De La Llave', 22.0574618, -98.1793394, 129),
(81, 1, '50F31', 'Villa Cacalilao Tam', 'Carretera Cd.Valles - Tampico, #S/N, Col. Villa Cacalilao, Panuco, Veracruz, México, 92009, entre Esq.Ursulo Galvan', 22.1522554, -98.1753120, 129),
(82, 1, '50O58', 'Caseta Panuco Tam', 'Carretera Tampico Panuco, #S/N, Col. Las Animas, Panuco, Veracruz, México, 92000, entre Entre Carretera Cd. Valles Tampico Y Plaza De Cobr', 22.1504734, -98.1467689, 129),
(83, 1, '50TDF', 'Xalapa Tam', 'Calle Xalapa, #302, Col. Gonzalez, Panuco, Veracruz, México, 93998, entre Netzahuacoyotl Y Plutarco Elias Calles', 22.0660101, -98.1837070, 129),
(84, 1, '50TT2', 'Mercado Panuco Tam', 'Calle Ignacio Allende, #12, Col. Panuco Centro, Panuco, Veracruz, México, 93990, entre Esq. Zaragoza Y Sebastian Lerdo De Tejada', 22.0592898, -98.1808937, 129),
(85, 1, '50UCT', 'Panuco Iii Tam', 'Carretera Panuco Canoas, #KM 1 + 100, Col. Panuco Centro, Panuco, Veracruz, México, 93990, entre Dentro Gasolinera Serv.De Panuco', 22.0636679, -98.1696990, 129),
(86, 1, '50ZMJ', 'Malecon Tam', 'Calle Ocampo, #3, Col. Zona Centro, Panuco, Veracruz, México, 92000, entre Zamora E Hidalgo', 22.0567120, -98.1775361, 129),
(87, 1, '50EFS', 'Tampico Valles Tam', 'Carretera Federal Tampico Valles, #85, Col. Moralillo, Panuco, Veracruz, México, 92018, entre Octava Y Novena', 22.2241500, -97.9079500, 129),
(88, 1, '50H3I', 'Tamos Tam', 'Carretera Tampico-Valles Esq. Rivera, #S/N, Col. Tamos, Panuco, Veracruz, México, 92018, entre Rivera Y Reforma', 22.2195134, -98.0002632, 129),
(89, 1, '50L80', 'Calentadores Tam', 'Carretera Tampico- Cd.Valles-La Palma El Barco, #S/N, Col. Calentadores Dos, Panuco, Veracruz, México, 92018, entre Sin Entre Calle', 22.1729301, -98.0887500, 129),
(90, 1, '50OMU', 'Moralillo Ii Tam', 'Carretera Tampico Valles, #S/N, Col. Moralillo, Panuco, Veracruz, México, 92018, entre Esquina Emiliano Zapata', 22.2251655, -97.9018293, 129),
(91, 1, '50OOM', 'Moralillo Tam', 'Carretera Tampico Valles, #KM 1, Col. Zona Centro, Panuco, Veracruz, México, 92000, entre Gasolinera Rodriguez', 22.2242319, -97.9032011, 129),
(92, 1, '50SAQ', 'Sabalo Tam', 'Carretera Tampico-Valles Km 5, #km 5, Col. Moralillo, Panuco, Veracruz, México, 92018, entre ', 22.2227377, -97.9166371, 129),
(93, 1, '5006G', 'Las Puentes Tam', 'Carretera El Higo La Y Griega, #S/N, Col. Puentes Nuevas, El Higo, Veracruz, México, 92405, entre Sin Entre Calle', 21.7733753, -98.4195754, 128),
(94, 1, '502AO', 'Ejercito Nacional Tmp', 'Prolongacion Ejercito Nacional, #8, Col. Los Manguitos, El Higo, Veracruz, México, 92400, entre Esq. Jose Maria Morelos Y Escolastico Lopez', 21.7684000, -98.4498000, 128),
(95, 1, '502J3', 'Miguel Aleman Tam', 'Calle Miguel Aleman, #9, Col. La Gloria, El Higo, Veracruz, México, 92400, entre Ignacio Allende Y Mariano Matamoros', 21.7618727, -98.4525290, 128),
(96, 1, '508ZZ', 'Ribera Tam', 'Calle Ribera, #S/N, Col. El Higo, El Higo, Veracruz, México, 92400, entre Bugambilias Y Framboyan', 21.7728028, -98.4556698, 128),
(97, 1, '50JWC', 'El Higo Tam', 'Calle Francisco I. Madero, #5, Col. El Higo, El Higo, Veracruz, México, 92400, entre 1Ro.De Mayo Y 5 De Febrero', 21.7683970, -98.4529707, 128),
(98, 1, '50NFI', 'Gas Higo Tam', 'Carretera A Panuco, #6, Col. Virgilio Lara, El Higo, Veracruz, México, 92400, entre Constitucion Y Revolucion', 21.7770438, -98.4462471, 128),
(99, 1, '50M20', 'Televalles Tam', 'Boulevard Mexico Laredo, #1100, Col. Lomas Ponientes, Ciudad Valles, San Luis Potosi, México, 79082, entre Esq. Calle Primera Y Segunda Avenida', 21.9767045, -99.0036979, 128),
(100, 1, '500EP', 'Rotarios Tam', 'Avenida Pujal, #203, Col. Ciudad Valles Centro, Ciudad Valles, San Luis Potosi, México, 79000, entre Hermenegildo Galeana', 21.9808362, -99.0132570, 128),
(101, 1, '500H3', '16 De Septiembre  Tam', 'Calle 16 De Septiembre, #701, Col. Ciudad Valles Centro, Ciudad Valles, San Luis Potosi, México, 79000, entre Hermenegildo Galeana Y Blvd. Mexico Laredo', 21.9889434, -99.0136830, 128),
(102, 1, '500S1', 'Eco Grande Tam', 'Calle Niños Heroes, #205, Col. Ciudad Valles Centro, Ciudad Valles, San Luis Potosi, México, 79000, entre Venustiano Carranza Y Hermenegildo Galeana', 21.9827766, -99.0150489, 128),
(103, 1, '505WE', 'Tercer Mundo Tam', 'Calle Francisco I Madero, #126, Col. Morelos Y Pavon, Ciudad Valles, San Luis Potosi, México, 79010, entre Esq. Las Flores Y Ferrocarril', 22.0003000, -99.0132000, 128),
(104, 1, '5073X', 'Mendez Tam', 'Avenida Ejercito Mexicano, #208 SUR, Col. Lomas Del Mirador, Ciudad Valles, San Luis Potosi, México, 79050, entre Esquina Monte De Los Olivos Y Monte Casino', 21.9844104, -99.0014872, 128),
(105, 1, '508K0', 'Comonfort Tam', 'Calle Jose Maria Morelos Y Pavón, #525, Col. Ciudad Valles Centro, Ciudad Valles, San Luis Potosi, México, 79000, entre 16 De Septiembre E Ignacio Comonfort', 21.9904000, -99.0176000, 128),
(106, 1, '50AGE', 'Salazar Tam', 'Calle Vicente C. Salazar, #1020, Col. Ciudad Valles Centro, Ciudad Valles, San Luis Potosi, México, 79000, entre Venustiano Carranza Y Francisco I. Madero', 21.9929822, -99.0138339, 128),
(107, 1, '50BDQ', 'Lerdo De Tejada Tam', 'Calle Lerdo De Tejada, #100, Col. Obrera, Ciudad Valles, San Luis Potosi, México, 79050, entre Lic. Benito Juarez Y Tamaulipas', 21.9857741, -99.0064560, 128),
(108, 1, '50C7Y', 'Unidad Norte Maf', 'Calle 5 de Mayo, #1636, Col. Unidad, Tanquian De Escobedo, San Luis Potosi, México, 79840, entre Esq. Ignacio Zaragoza y Julian Carrillo', 21.6110573, -98.6635611, 128),
(109, 1, '50E1G', 'Ferrocarril', 'Calle Ferrocarril, #828, Col. Villa Real De Santiago, Ciudad Valles, San Luis Potosi, México, 79050, entre Fray Rafael Rodriguez Esq Con Calle Zaragoza', 21.9887511, -98.9961888, 128),
(110, 1, '50EFO', 'Pedregal Tam', 'Carretera Valles-Mante, #1201 NTE, Col. Fracc. Villa Brisa, Ciudad Valles, San Luis Potosi, México, 79058, entre Quinta Privada Y Washington', 22.0098557, -99.0015364, 128),
(111, 1, '50IMH', 'Frontera Tam', 'Calle Ejercito Mexicano, #818, Col. Altavista, Ciudad Valles, San Luis Potosi, México, 79050, entre Pedro J. Mendez Y Frontera', 21.9930698, -99.0019358, 128),
(112, 1, '50IMJ', 'Ecocentralita Tam', 'Calle Mariano Abasolo, #314, Col. Ciudad Valles Centro, Ciudad Valles, San Luis Potosi, México, 79000, entre Independencia Y Francisco I Madero', 21.9843314, -99.0160706, 128),
(113, 1, '50J2L', 'Fray Andres Tam', 'Calle Fray Andres De Olmos, #933, Col. Lomas Ponientes, Ciudad Valles, San Luis Potosi, México, 79082, entre Segunda Y Tercera', 21.9767632, -99.0059428, 128),
(114, 1, '50K58', 'El Carmen Tam', 'Calle Ana, #318, Col. Del Carmen, Ciudad Valles, San Luis Potosi, México, 79068, entre Reyna Elena Y Engracia', 21.9960371, -98.9944388, 128),
(115, 1, '50L5A', 'Aurora Tam', 'Avenida Ejercito Mexicano, #805, Col. Tampico, Ciudad Valles, San Luis Potosi, México, 79064, entre Carretera Valles Tampico Y Aurora', 21.9801702, -98.9979780, 128),
(116, 1, '50LCB', 'General Anaya Tam', 'Calle Secundaria, #1500, Col. Hidalgo, Ciudad Valles, San Luis Potosi, México, 79080, entre General Anaya Y Fray Andres De Olmos', 21.9754455, -99.0101811, 128),
(117, 1, '50QV1', 'Villa Huasteca Tam', 'Carretera Mexico Laredo, #2732, Col. El Pacifico, Ciudad Valles, San Luis Potosi, México, 79027, entre Esq. Puerto Vallarta Y Mazatlan', 22.0172000, -98.9972000, 128),
(118, 1, '50R68', 'Acuario Tam', 'Calle Benito Juarez, #510, Col. Ciudad Valles Centro, Ciudad Valles, San Luis Potosi, México, 79000, entre Hermenegildo Galeana Y Boulevard México-Laredo', 21.9861561, -99.0132300, 128),
(119, 1, '50S9S', 'Motolinia', 'Calle Vicente Salazar, #1405, Col. Altavista, Ciudad Valles, San Luis Potosi, México, 79050, entre Manuel Jose Othon Y Francisco Gonzalez Bocanegra', 21.9927522, -99.0094942, 128),
(120, 1, '50SFT', 'Linares Tam', 'Calle Linares, #226, Col. Veinte De Noviembre, Ciudad Valles, San Luis Potosi, México, 79020, entre Tancanhuitz', 22.0005347, -99.0042936, 128),
(121, 1, '50T0H', 'Zaragoza Tam', 'Calle Zaragoza, #1335, Col. Obrera, Ciudad Valles, San Luis Potosi, México, 79050, entre 30 De Mayo Y Lerdo De Tejada', 21.9902600, -99.0050460, 128),
(122, 1, '50TBI', 'Tampaon Tam', 'Avenida Rio Tampaon, #100, Col. Cecyt, Ciudad Valles, San Luis Potosi, México, 79098, entre Boulevard Mexico-Laredo', 21.9975870, -99.0105643, 128),
(123, 1, '50TEJ', 'Glorieta Tam', 'Calle Glorieta Hidalgo, #819, Col. Mirador, Ciudad Valles, San Luis Potosi, México, 79050, entre Avenida Valles Y Avenida Monterrey', 21.9821213, -99.0055280, 128),
(124, 1, '50VBC', 'Valles Centro Tam', 'Calle Benito Juarez, #109, Col. Ciudad Valles Centro, Ciudad Valles, San Luis Potosi, México, 79000, entre Morelos Y Vicente Guerrero', 21.9864463, -99.0183428, 128),
(125, 1, '50YNI', 'Apolo Tam', 'Calle Apolo, #1201, Col. Lazaro Cardenas, Ciudad Valles, San Luis Potosi, México, 79020, entre Oro Y Piedra Azul', 22.0094553, -99.0090994, 128),
(126, 1, '50DHN', 'Las Aguilas Tam', 'Carretera Valles Tampico Km 41.5, #KM 41.5, Col. Las Aguilas, Ciudad Valles, San Luis Potosi, México, 79060, entre Ave. De Las Aguilas Y Ave Del Condor', 21.9767562, -98.9717610, 128),
(127, 1, '50LFI', 'San Felipe Tam', 'Carretera Nacional Tramo Valles Tampico Km. 5.7, #5105, Col. Las Aguilas, Ciudad Valles, San Luis Potosi, México, 79060, entre Sin Entrecalles', 21.9768834, -98.9565067, 128),
(128, 1, '50Z98', 'Del Campo Tam', 'Calle Romualdo Del Campo, #S/N, Col. Rafael Curiel, Ciudad Valles, San Luis Potosi, México, 79060, entre Tambaca Y Tampaon', 21.9816283, -98.9782830, 128),
(129, 1, '50U2F', 'Galeana Valles Maf', 'Calle Gral. Ignacio Zaragoza , #742, Col. Ciudad Valles Centro, Ciudad Valles, San Luis Potosi, México, 79000, entre Esq. Blvr. México-Laredo', 21.9907751, -99.0123331, 128),
(130, 1, '500Q5', 'Servando Tam', 'Calle Canales, #111 PTE, Col. Zona Centro, El Mante, Tamaulipas, México, 89800, entre Esq. Morelos E Hidalgo', 22.7449000, -98.9723000, 129),
(131, 1, '500X5', 'Ciudad Del Maiz Tam', 'Boulevard Miguel Barragan, #40, Col. Ciudad Del Maiz Centro, Ciudad Del Maiz, San Luis Potosi, México, 79320, entre Ignacio Allende Y Benito Juarez', 22.4038794, -99.6028670, 129),
(132, 1, '5012J', 'Xico Mercado Tam', 'Calle Vicente Guerrero, #500 PTE, Col. Xicotencatl Centro, Xicotencatl, Tamaulipas, México, 89755, entre Ocampo Y Oriente', 22.9978879, -98.9383770, 129),
(133, 1, '502E1', 'Del Pino Maf', 'Boulevard Luis Echeverria Alvarez, #802, Col. Ciudad Mante Centro, El Mante, Tamaulipas, México, 89800, entre Esquina Tula Y Tampico', 22.7345778, -98.9642886, 129),
(134, 1, '503BF', 'Loma Alta Tam', 'Calle Valentín Gomez Farías, #S/N, Col. Loma Alta, Gomez Farias, Tamaulipas, México, 89790, entre Allende Y Valentín Gomez Farías', 22.8826157, -99.0272300, 129),
(135, 1, '5081M', 'El Abra Maf', 'Carretera Mante Ant Morelos, #km 12, Col. El Abra, El Mante, Tamaulipas, México, 89939, entre Sin Entre Calles', 22.6282696, -99.0229962, 129),
(136, 1, '50947', 'Blvd Colosio Tam', 'Boulevard Colosio, #101 Pte, Col. Miguel Aleman, El Mante, Tamaulipas, México, 89820, entre Manuel Avila Camacho Y Adolfo Ruiz Cortinez', 22.7559844, -98.9691050, 129),
(137, 1, '5095M', 'Guillermo Prieto', 'Calle Guillermo Prieto, #406 S, Col. Nuñez, El Mante, Tamaulipas, México, 89850, entre Xicotencatl', 22.7402653, -98.9827835, 129),
(138, 1, '509DV', 'Luis Echeverria Tam', 'Calle Luis Echeverria Alvarez, #501 Sur, Col. Ciudad Mante Centro, El Mante, Tamaulipas, México, 89800, entre Xicotencatl Y Prolongacion Magiscatzin', 22.7383714, -98.9635837, 129),
(139, 1, '50A7Z', 'Ganadera Tam', 'Calle Pedro J.Mendez, #403, Col. Ciudad Ocampo, Ocampo, Tamaulipas, México, 87980, entre Esq. 5 De Mayo Y Carranza', 22.8456001, -99.3323500, 129),
(140, 1, '50EEN', 'Rio Mante Tam', 'Boulevard Ramon Cano Manilla, #300, Col. Independencia, El Mante, Tamaulipas, México, 89888, entre Ocampo Y Escobedo', 22.7323883, -98.9712167, 129),
(141, 1, '50GFU', 'Escobedo Tam', 'Calle Guerero, #S/N, Col. Ciudad Mante Centro, El Mante, Tamaulipas, México, 89800, entre Cuauhtemoc Y Escobedo', 22.7422834, -98.9683141, 129),
(142, 1, '50GG2', 'Nuevo Morelos Maf', 'Boulevard Nuevo Morelos, #505, Col. Nuevo Morelos, Nuevo Morelos, Tamaulipas, México, 89970, entre Esq. Alvaro Obregon Y Melchor Ocampo', 22.5338503, -99.2212434, 129),
(143, 1, '50GMH', 'Mante Tam', 'Carretera Nacional Mexico Laredo, #KM 91, Col. Ciudad Mante Centro, El Mante, Tamaulipas, México, 89800, entre Tramo Mante Valles', 22.7088093, -98.9923335, 129),
(144, 1, '50HN6', 'Ciudad Ocampo Tam', 'Calle Benito Juarez, #100, Col. Ciudad Ocampo, Ocampo, Tamaulipas, México, 87980, entre Pedro Jose Lopez Y Francisco Sarabia', 22.8439131, -99.3365421, 129),
(145, 1, '50NML', 'Limon Tam', 'Carretera Nacional Mexico-Laredo, #300 SUR, Col. El Limon, El Mante, Tamaulipas, México, 89910, entre Carretera Nacional Mexico Laredo', 22.8218502, -99.0103359, 129),
(146, 1, '50NTK', 'Autopark Mante Tam', 'Avenida Juan De Dios Villarreal, #101 PTE, Col. Chapultepec, El Mante, Tamaulipas, México, 89846, entre Ave. De Las Flores Y Niños Heroes', 22.7474075, -98.9921242, 129),
(147, 1, '50NWL', 'Bernal Tam', 'Calle Antonio Casso, #101, Col. Cerro Del Bernal, El Mante, Tamaulipas, México, 89818, entre Mangos Y Ciruelos', 22.7578550, -98.9618210, 129),
(148, 1, '50OR5', 'El Martillo Tam', 'Calle Rotaria, #700, Col. El Martillo, El Mante, Tamaulipas, México, 89827, entre Paniagua Y Jose Vasconcelos', 22.7486649, -98.9617438, 129),
(149, 1, '50PGW', 'Paniagua Tam', 'Calle Morelos, #667, Col. Miguel Aleman, El Mante, Tamaulipas, México, 89820, entre Paniagua Y Guadalupe Victoria', 22.7498627, -98.9713478, 129),
(150, 1, '50Q0M', 'Condueños Maf', 'Calle Condueños, #300, Col. Anahuac 1, Mante, Tamaulipas, México, 89830, entre Guadalupe Victoria y Alejandro Prieto', 22.7469111, -98.9765905, 129),
(151, 1, '50Q7H', 'Naranjo Centro Tam', 'Avenida Miguel Hidalgo, #677, Col. El Naranjo Centro, El Naranjo, San Luis Potosi, México, 79300, entre Esq. Jorge Pasquel Y Ponciano Arriaga', 22.5224433, -99.3259000, 129),
(152, 1, '50RD4', 'Aviacion Mante Tam', 'Calle Zacatecas, #301, Col. Aeropuerto, El Mante, Tamaulipas, México, 89849, entre Constitucion Y Valle Hermoso', 22.7534037, -99.0053359, 129),
(153, 1, '50RG8', 'Carretera Del Maiz Tam', 'Calle Calzada Riva Palacio, #48, Col. Villa De San Jose, Ciudad Del Maiz, San Luis Potosi, México, 79326, entre Blvd. Miguel Barragan Y Jose M. Arteaga', 22.4006041, -99.6076250, 129),
(154, 1, '50SM7', 'Carretera Mante Tam', 'Carretera Tampico-Mante, #213, Col. Union Burocratica Sect 2, El Mante, Tamaulipas, México, 89868, entre Huizache E Higueron', 22.7260481, -98.9622627, 129),
(155, 1, '50U5K', 'Mante Platino Maf', 'Carretera Mante- Victoria, #KM 104.5, Col. Ejido Santa Elena, Mante, Tamaulipas, México, 89918, entre ', 22.8034639, -99.0134389, 129),
(156, 1, '50U9L', 'Mante Centro Tam', 'Calle Hidalgo, #701 Sur, Col. Zona Centro, El Mante, Tamaulipas, México, 89800, entre Quintero Y Tampico', 22.7377535, -98.9726290, 129),
(157, 1, '50UR4', 'Nicolas Moreno Tam', 'Calle Manuel Jose Othon, #600, Col. Nicolas Moreno, El Mante, Tamaulipas, México, 89870, entre Manuel Acuña Y Leona Vicario', 22.7336489, -98.9816130, 129),
(158, 1, '50V1D', 'Chicoasen Maf', 'Boulevard Río Mante (Blvr. Ramón Cano Manilla), #217, Col. Esfuerzo Obrero, El Mante, Tamaulipas, México, 89865, entre Chicoasén', 22.7326240, -98.9598331, 129),
(159, 1, '50V37', 'Antiguo Morelos Tam', 'Calle Mina, #404 OTE, Col. Zona Centro, Antiguo Morelos, Tamaulipas, México, 89960, entre Esq. Francisco Javier Mina', 22.5543000, -99.0785660, 129),
(160, 1, '50VMJ', 'Olivo Tam', 'Boulevard Enrique Cardenas Gonzalez, #S/N, Col. Del Bosque, El Mante, Tamaulipas, México, 89840, entre Calle Olivo Y Guillermo Prieto', 22.7453550, -98.9837176, 129),
(161, 1, '50W7N', 'La Esperanza Tam', 'Calle Benito Juárez, #S/N, Col. La Esperanza Sur, El Naranjo, San Luis Potosi, México, 79303, entre Lázaro Cárdenas Y Sebastian Lerdo De Tejada', 22.5236676, -99.3332986, 129),
(162, 1, '50XIJ', 'Xico Tam', 'Carretera Ingenio-s, #KM 3, Col. Xicohtencatl, Xicotencatl, Tamaulipas, México, 89750, entre ', 22.9889816, -98.9467760, 129),
(163, 1, '501E4', 'Estacion Cardenas Maf', 'Boulevard Enrique Cardenas Gonzalez , #1112, Col. Del Bosque, Ciudad Mante, San Luis Potosi, México, 89840, entre ', 22.7455713, -98.9865396, 129),
(164, 1, '502RQ', 'Loma Bonita', 'Calle Morelos, #140, Col. Real Del Rio, Axtla De Terrazas, San Luis Potosi, México, 79930, entre Esq.Libramiento Jose Maria Morelos Y 5 De Mayo', 21.4378530, -98.8682726, 128),
(165, 1, '503HS', 'Aquismon Tam', 'Calle Crucero Marcelino Zamarrón, #S/N, Col. Crucero Marcelino Zamarron, Tancanhuitz De Santos, San Luis Potosi, México, 79800, entre Damián Carmona Y  Carr Matlapa- Ciudad Valles', 21.6233499, -98.9869980, 128),
(166, 1, '5068M', 'Centro Tampacan', 'Calle 5 De Mayo, #63, Col. Guadalupe, Tampacan, San Luis Potosi, México, 79940, entre Esq. Hermenegildo Galeana Y Francisco I. Madero', 21.4021360, -98.7285800, 128),
(167, 1, '506F8', 'Deportiva Valles Tam', 'Calle Pico De Orizaba, #517, Col. Lomas De San Jose, Ciudad Valles, San Luis Potosi, México, 79094, entre Herradura Y Pico De Orizaba', 21.9710406, -98.9939960, 128),
(168, 1, '506J3', 'San Miguel Tam', 'Calle Margarita Maza De Juarez, #201, Col. San Miguel, Tamazunchale, San Luis Potosi, México, 79960, entre Mariano Matamoros Y  Cuitlahuac', 21.2541425, -98.7869140, 128),
(169, 1, '5077X', 'Tetlama Tam', 'Avenida 20 De Noviembre, #50, Col. San Juan, Tamazunchale, San Luis Potosi, México, 79960, entre Esq. Callejon Tetlama Y Del Aguacate', 21.2629492, -98.7927803, 128),
(170, 1, '5083G', 'Tampacan Tam', 'Carretera Ciudad Valles-Tamazunchale, #94-A, Col. Matlapa, Matlapa, San Luis Potosi, México, 79970, entre Calle Plan De Iguala Y Ave. Uno', 21.3289000, -98.8199000, 128),
(171, 1, '5089E', 'Chapulhuacanito Tam', 'Calle Lázaro Cárdenas, #420 int. A, Col. Chapulhuacanito, Tamazunchale, San Luis Potosi, México, 79980, entre Esq Calle Sin Nombre Y 8 De Mayo', 21.2083661, -98.6712625, 128),
(172, 1, '50AGG', 'Xolol Tam', 'Carretera Nacional Mexico Laredo Km 322, #S/N, Col. Tancanhuitz De Santos, Tancanhuitz De Santos, San Luis Potosi, México, 79800, entre Entre Crucero Xolol Y Entrada A Aquismon', 21.5934401, -98.9928564, 128),
(173, 1, '50ARH', 'Tencaxapa Tam', 'Calle Educacion, #2, Col. Xew, Tamazunchale, San Luis Potosi, México, 79960, entre Ave Benito Juarez Y Mirador', 21.2480868, -98.7806925, 128),
(174, 1, '50BPR', 'Lomasdesantiago Tam', 'Calle Antiguo Camino Al Pujal, #601, Col. Lomas De Santiago, Ciudad Valles, San Luis Potosi, México, 79095, entre Carlos Rivera Palacios Y Calle 5A', 21.9586000, -98.9939000, 128),
(175, 1, '50CLC', 'Entronquexilitla Tam', 'Carretera Nacional Mexico Laredo, #85, Col. Rancho Nuevo, Axtla De Terrazas, San Luis Potosi, México, 79931, entre Carretera Nacional Y Coamila El Paraiso', 21.4449578, -98.9280247, 128),
(176, 1, '50FBM', 'Hospital Tam', 'Boulevard Miguel Angel Oliva, #125, Col. Oxitipa, Ciudad Valles, San Luis Potosi, México, 79090, entre Framboyan Y Campestre', 21.9488727, -98.9943585, 128),
(177, 1, '50FCQ', 'Matlapa Tam', 'Avenida Francisco I Madero, #21-A, Col. Matlapa Centro, Matlapa, San Luis Potosi, México, 79970, entre Vicente Guerrero Y Graciano Sanchez', 21.3353659, -98.8269595, 128),
(178, 1, '50GQU', 'Tampamolon Tam', 'Calle Pedro Antonio De Los Santos, #S/N, Col. Tampamolon Corona, Tampamolon Corona, San Luis Potosi, México, 79850, entre Crisoforo Martell Y Vicente Guerrero', 21.5597810, -98.8166575, 128),
(179, 1, '50HXF', 'Providencia Tam', 'Carretera Nacional Mexico Laredo, #5216 SUR, Col. Oxitipa, Ciudad Valles, San Luis Potosi, México, 79090, entre Periferico Lib. Sur Y Puente Rio Tampaon', 21.9325400, -98.9727400, 128),
(180, 1, '50IMI', 'Auto Park Valles Tam', 'Libramiento Sur San Luis Potosi-Tampico, #217 PTE, Col. Lomas De Yuejat, San Luis Potosi, San Luis Potosi, México, 79082, entre Chucho Robles Martinez Y Libramiento Sur', 21.9651052, -98.9990242, 128),
(181, 1, '50IUD', 'Villavicencio Tam', 'Boulevard Mexico-Laredo Sur, #2011, Col. Comercial Central, Ciudad Valles, San Luis Potosi, México, 79097, entre Juan Villavicencio Y Calle Cd. Valles', 21.9693263, -98.9996087, 128),
(182, 1, '50K35', 'Centro Aquismon Maf', 'Calle Benito Juarez, #, Col. Zona Centro, Aquismon, San Luis Potosi, México, 79760, entre ', 21.6217907, -99.0205226, 128),
(183, 1, '50L8J', 'La Purisima Tam', 'Calle Venustiano Carranza, #13, Col. La Libertad, Axtla De Terrazas, San Luis Potosi, México, 79930, entre Esq. Niños Heroes Y Vicente Guerrero', 21.4409000, -98.8776000, 128),
(184, 1, '50L9W', 'Plaza Tancanhuitz Tam', 'Calle Miguel Hidalgo Y Costilla, #13, Col. Tamunzoc, Tancanhuitz De Santos, San Luis Potosi, México, 79800, entre Independencia Y Gonzalo N. Santos', 21.5976000, -98.9671000, 128),
(185, 1, '50MDN', 'Zacatipan Tam', 'Carretera A San Martin Km 01-A, #S/N, Col. Zacatipan, Tamazunchale, San Luis Potosi, México, 79960, entre Epigmenio Garcia Y Adolfo Lopez Mateos', 21.2481979, -98.7749820, 128),
(186, 1, '50O9V', 'Huehuetlan Tam', 'Carretera Federal Mexico Laredo, #8, Col. Huichihuayan, Huehuetlan, San Luis Potosi, México, 79890, entre Esq. Vicente Guerrero Y 5 De Mayo', 21.4814000, -98.9667000, 128),
(187, 1, '50PJW', 'Pujal Tam', 'Carretera Mexico Laredo, #KM 2.64 14, Col. El Pujal, Ciudad Valles, San Luis Potosi, México, 79260, entre Calle Del Panteon Del Pujal Y Curva De La Entrada', 21.8543270, -98.9424869, 128),
(188, 1, '50Q27', 'Buenos Aires Tam', 'Calle Graciano Sanchez, #110, Col. El Piñal, Tamazunchale, San Luis Potosi, México, 79960, entre Miguel Hidalgo Y Benito Juarez', 21.2521082, -98.7494853, 128),
(189, 1, '50RF7', 'San Martin Tam', 'Boulevard Independencia, #3, Col. San Martin Chalchicuautla, San Martin Chalchicuautla, San Luis Potosi, México, 79950, entre Carlos Jonguitud Barrios Y Vicente Guerre', 21.3705254, -98.6581382, 128),
(190, 1, '50TES', 'Xilitla Tam', 'Calle Jardin Hidalgo, #120 A, Col. Xilitla, Xilitla, San Luis Potosi, México, 79900, entre Ignacio Zaragoza Y Mariano Escobedo', 21.3849662, -98.9898080, 128),
(191, 1, '50THJ', 'Centro Tamanzuchale Tam', 'Calle Hidalgo, #72, Col. San Miguel, Tamazunchale, San Luis Potosi, México, 79960, entre Porfirio Diaz Y Xicotencatl', 21.2605796, -98.7893690, 128),
(192, 1, '50TTN', 'Crucero Tam', 'Calle 20 De Noviembre, #604, Col. San Miguel, Tamazunchale, San Luis Potosi, México, 79960, entre Ave Benito Juarez Y Ave Miguel Hidalgo', 21.2593876, -98.7880150, 128),
(193, 1, '50U1U', 'Coxcatlan Tam', 'Calle Guillermo Prieto, #20, Col. Coxcatlan, Coxcatlan, San Luis Potosi, México, 79860, entre Esq.Amado Nervo Y Carlos Jongitud Barrios', 21.5408801, -98.9058100, 128),
(194, 1, '50W6J', 'Ahuacatlan Tam', 'Carretera Xilitla-Jalpan, #1, Col. Ahuacatlan, Xilitla, San Luis Potosi, México, 79920, entre Corregidora Y Camposanto', 21.3211170, -99.0520400, 128),
(195, 1, '50XXC', 'Axtla Tam', 'Calle Miguel Hidalgo, #8, Col. Axtla De Terrazas, Axtla De Terrazas, San Luis Potosi, México, 79930, entre Jose Maria Morelos Y 5 De Mayo', 21.4360760, -98.8746615, 128),
(196, 1, '509Q2', 'Azalea Maf', 'Carretera Xilitla- San Juan Del Rio  , #539, Col. Xilitla, Xilitla, San Luis Potosi, México, 79900, entre ', 21.3875846, -98.9853257, 128),
(197, 1, '50PZ5', 'Huichihuayan Maf', 'Carretera Nacional México-Laredo, #10, Col. Chinuntzen, Huehuetlan, San Luis Potosi, México, 79891, entre Esq. Niños Heroes y Laureles', 21.4836677, -98.9709730, 128),
(198, 1, '507LE', 'Gas Tamazunchale Maf', 'Carretera Mexico Laredo , #KM 366.5 A, Col. Ixtlapalaco, Tamazunchale, San Luis Potosi, México, 79960, entre ', 21.2662874, -98.7756415, 128),
(199, 1, '50Y75', 'Palmira Maf', ' , #, Col. , , , , , entre ', 21.6776155, -98.9713187, 128),
(200, 1, '50EW2', 'Comoca Maf', ' , #, Col. , , , , , entre ', 21.4248448, -98.8901577, NULL),
(201, 1, '506LS', 'Rascon 2 Maf', ' , #, Col. , , , , , entre ', 21.9666243, -99.2558955, 128),
(202, 2, '506RG', 'Llera Centro Tam', 'Calle Miguel Hidalgo y Costilla, #S/N, Col. Llera De Canales, Llera, Tamaulipas, México, 87200, entre esq. Servando Canales y Pedro José Méndez', 23.3183449, -99.0234087, 134),
(203, 2, '50AU4', 'Villa Llera Maf', 'Carretera Nacional Mexico Laredo, #Km170, Col. Las Huertas, Llera de Canales, Tamaulipas, México, 87200, entre Josefa Llera y Sandia', 23.3080896, -99.0212745, 134),
(204, 2, '50LFF', 'Llera Tam', 'Carretera Federal 81 a Gonzalez, #Km 50, Col. Mariano Escobedo, Llera, Tamaulipas, México, 87220, entre Estacion Escandon', 23.1164182, -98.7507026, 134),
(205, 2, '50Y9K', 'Jose Silva Tam', 'Boulevard Josefa Llera, #356, Col. Emiliano Zapata, Llera, Tamaulipas, México, 87200, entre esq. José Silva Sanchez y Libertad', 23.3130930, -99.0217376, 134),
(206, 2, '50SO2', '14 Carrera Maf', 'Calle Alberto Carrera Torres, #395, Col. Zona Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Emiliano P Nafarrete y Manuel Gonzalez', 23.7381528, -99.1492969, 134),
(207, 2, '50UXE', 'Estadio Maf', 'Calle Mier Y Teran, #811, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Con Aldama', 23.7394869, -99.1536816, 134),
(208, 2, '50VDI', '16 Veracruz Maf', 'Avenida Norberto Treviño Zapata, #S/N, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Con Veracruz', 23.7469388, -99.1502768, 134),
(209, 2, '50CRW', '8 Carrera Maf', 'Calle Juan B. Tijerina, #1002, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Carrera Torres Y Abasolo', 23.7371000, -99.1436000, 134),
(210, 2, '50JZU', '9 Y Berriozabal Maf', 'Calle Cristobal Colon, #836, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Mina Y Berriozabal', 23.7401431, -99.1447991, 134),
(211, 2, '502CG', '31 Berriozabal Maf', 'Calle Berriozabal, #1501, Col. Sierra Madre, Ciudad Victoria, Tamaulipas, México, 87037, entre Esquina Con Sierra Madre Occidental', 23.7422000, -99.1683000, 130),
(212, 2, '50BAA', 'Refineria Maf', 'Calle Las Torres, #6, Col. Lazaro Cardenas, Ciudad Victoria, Tamaulipas, México, 87030, entre Refineria', 23.7434448, -99.1645185, 130),
(213, 2, '50D9A', 'Keppler Maf', 'Boulevard Emilio Portes Gil, #502, Col. Tecnologico, Ciudad Victoria, Tamaulipas, México, 87037, entre Esquina Con J. Kepler', 23.7505901, -99.1705524, 130),
(214, 2, '50FEY', 'Nacozary Maf', 'Avenida Lauro Rendon, #626, Col. Heroe De Nacozari, Ciudad Victoria, Tamaulipas, México, 87030, entre Esq. Con Abasolo', 23.7379479, -99.1629987, 130),
(215, 2, '50JZV', 'Oaxaca Maf', 'Calle Mier Y Teran, #2480, Col. Fovissste, Ciudad Victoria, Tamaulipas, México, 87020, entre Esq. Con Oaxaca', 23.7550317, -99.1519488, 130),
(216, 2, '50OUK', 'Adelitas Maf', 'Avenida Lazaro Cardenas, #1485, Col. Las Adelitas, Ciudad Victoria, Tamaulipas, México, 87049, entre Camino A La Libertad', 23.7470733, -99.1594454, 130),
(217, 2, '50OUW', 'La Escondida Maf', 'Avenida Division Del Golfo, #24, Col. La Escondida, Ciudad Victoria, Tamaulipas, México, 87033, entre Esq. Con Av. Central', 23.7408888, -99.1599736, 130),
(218, 2, '50SNQ', 'San Luisito Maf', 'Avenida Michoacan, #S/N, Col. San Luisito, Ciudad Victoria, Tamaulipas, México, 87049, entre Esq. Con Santa Iliana', 23.7594442, -99.1522882, 130),
(219, 2, '50YJH', 'Conrado Maf', 'Calle Mier Y Teran, #S/N, Col. Pedro J. Mendez, Ciudad Victoria, Tamaulipas, México, 87040, entre Esq. Conrado Castillo', 23.7448255, -99.1527471, 130),
(220, 2, '50YM7', 'Almendros Maf', 'Avenida Michoacan, #2554, Col. Los Alimendros, Ciudad Victoria, Tamaulipas, México, 87049, entre Esq. Con Av. Los Almendros', 23.7593510, -99.1584847, 130),
(221, 2, '50YTC', 'Tec Maf', 'Calle Emilio Portes Gil, #1254, Col. Tecnologico, Ciudad Victoria, Tamaulipas, México, 87037, entre Seferino Fajardo Y Fracc.Nuevo Santander', 23.7522734, -99.1649102, 130),
(222, 2, '50VJE', 'Eje Vial Maf', 'Avenida Lazaro Cardenas, #2328, Col. Los Alimendros, Ciudad Victoria, Tamaulipas, México, 87049, entre Esq. Con Zacatecas', 23.7565400, -99.1603400, 130),
(223, 2, '50HJB', '15 Berriozabal Maf', 'Avenida Berriozabal, #391, Col. San Francisco, Ciudad Victoria, Tamaulipas, México, 87050, entre Esq. Con Manuel Gonzalez ', 23.7414754, -99.1495148, 130),
(224, 2, '5065F', 'La Estrella Maf', 'Libramiento Naciones Unidas, #182, Col. Estrella, Ciudad Victoria, Tamaulipas, México, 87015, entre Venus Y Camino A La Libertad', 23.7715000, -99.1732000, 130),
(225, 2, '506AR', 'El Barretal Maf', 'Carretera Victoria - Monterrey, #S/N, Col. Ursulo Galvan, Guemez, Tamaulipas, México, 87799, entre ', 24.0854750, -99.1244110, 130),
(226, 2, '507SX', 'Monte Alto Umi', 'Carretera Interejidal, #649, Col. Monte Alto, Ciudad Victoria, Tamaulipas, México, 87019, entre Esquina Con Calle Valle Grande', 23.7814000, -99.1675000, 130),
(227, 2, '50BRK', 'Laborcitas Maf', 'Carretera Victoria-Monterrey, #S/N, Col. Las Laborcitas, Ciudad Victoria, Tamaulipas, México, 87000, entre Km. 9', 23.8214000, -99.1225000, 130),
(228, 2, '50DPJ', 'Zeferino 2 Maf', 'Calle Zeferino Fajardo, #S/N, Col. Industrial, Ciudad Victoria, Tamaulipas, México, 87018, entre Esq. Con Matamoros', 23.7563600, -99.1644700, 130),
(229, 2, '50DQV', 'La Presita Maf', 'Carretera Interejidal, #501, Col. La Presita, Ciudad Victoria, Tamaulipas, México, 87019, entre Juan Baez Guerra Y Silvestre Mata', 23.7749801, -99.1671974, 130),
(230, 2, '50DQZ', 'Zeferino Maf', 'Avenida Zeferino Fajardo, #284, Col. Enrique Cárdenas , Ciudad Victoria, Tamaulipas, México, 87018, entre Esq. Con Villa De Llera', 23.7627227, -99.1676992, 130),
(231, 2, '50GFO', 'Nacional Maf', 'Carretera Victoria-Monterrey, #S/N, Col. Victoria-Monterrey, Ciudad Victoria, Tamaulipas, México, 87000, entre Km. 27', 23.7920105, -99.1571523, 130),
(232, 2, '50GZK', 'Guemez Maf', 'Carretera Victoria-Monterrey, #S/N, Col. Plan De Ayala, Guemez, Tamaulipas, México, 87249, entre Km. 34+400', 23.7900388, -99.1506470, 130),
(233, 2, '50HVX', 'Las Americas Maf', 'Avenida Las Americas, #287, Col. Tierra Y Libertad, Ciudad Victoria, Tamaulipas, México, 87019, entre Colombia Y Vias Del Ferrocarril', 23.7660899, -99.1617688, 130),
(234, 2, '50K6D', 'Los Troncones Maf', 'Carretera Ejidal A Cd. Victoria, #1400, Col. La Libertad, Ciudad Victoria, Tamaulipas, México, 87260, entre Esquina Con Carretera A Nacimiento', 23.7989630, -99.1780510, 130),
(235, 2, '50MY5', 'Tomaseno Maf', 'Carretera Ciudad Victoria- Linares Km 777.5, #S/N, Col. El Tomaseño, Hidalgo, Tamaulipas, México, 87805, entre Interior Gasolinera', 24.2605000, -99.4366000, 130),
(236, 2, '50NUD', 'Naciones Unidas II Maf', 'Avenida Lazaro Cardenas, #1191, Col. Naciones Unidas , Ciudad Victoria, Tamaulipas, México, 87049, entre Lib.Naciones Unidas Y Teotihuacan', 23.7732405, -99.1610827, 130),
(237, 2, '50SDQ', 'Naciones Unidas Maf', 'Libramiento Naciones Unidas, #1048 OTE., Col. Favisa, Ciudad Victoria, Tamaulipas, México, 87027, entre Esq. Con Carretera A Monterrey', 23.7730148, -99.1391155, 130),
(238, 2, '50TMK', 'Oralia Guerra Maf', 'Libramiento Naciones Unidas, #442, Col. Oralia Guerra De Villareal, Ciudad Victoria, Tamaulipas, México, 87049, entre Esq. Con Av. Las Torres', 23.7733371, -99.1530167, 130),
(239, 2, '50VE7', 'Subida Alta Maf', 'Carretera Nacional Mexico Laredo, #200, Col. Subida Alta, Guemez, Tamaulipas, México, 87237, entre ', 23.9122020, -99.1135230, 130),
(240, 2, '50W7M', 'Colinas Del Valle Maf', 'Calle Zeferino Fajardo Luna, #400, Col. Colinas Del Valle, Ciudad Victoria, Tamaulipas, México, 87018, entre Esquina Con Calle Privada', 23.7673000, -99.1706000, 130),
(241, 2, '50WU2', 'Villagran Maf', 'Carretera Victoria - Monterrey Km 101.4, #S/N, Col. Villagran, Villagran, Tamaulipas, México, 87880, entre Entrada Camino Garza Valdez', 24.4689360, -99.4931638, 130),
(242, 2, '50OSD', '16 Sierra de Casas Maf', 'Calle 5 De Mayo, #3071, Col. Magisterial, Ciudad Victoria, Tamaulipas, México, 87026, entre Esquina Calle Sierra De Casas', 23.7658021, -99.1475256, 130),
(243, 2, '50XIQ', 'Naciones Unidas III Maf', 'Libramiento Naciones Unidas, #1025, Col. Villa Real, Ciudad Victoria, Tamaulipas, México, 87027, entre Norberto Treviño Y Carretera A Monterrey', 23.7738877, -99.1438848, 130),
(244, 2, '50WM4', 'La Salle Victoria Maf', 'Avenida Norberto Treviño Zapata, #3545, Col. Fraccionamiento la Salle, Ciudad Victoria, Tamaulipas, Mexico, 87027, entre Colegio Jose de Escandon la Salle - Campus Norte', 23.7792483, -99.1461479, 130),
(245, 2, '508QJ', 'La Libertad Maf', ' , #, Col. , , , , , entre ', NULL, NULL, 130),
(246, 2, '5029T', 'Gas Altamira Tam', 'Libramiento Altamira Puerto Industrial, #8903, Col. Puerto Industrial, Altamira, Tamaulipas, México, 89603, entre esq. Blvr de los Ríos', 22.4648285, -97.9034906, 134),
(247, 2, '503OF', 'Tres Marias Maf', 'Carretera Tampico-Mante, #35, Col. Benito Juarez, ALtamira, Tamaulipas, México, 89636, entre Gas Carretera', 22.4823693, -98.0155360, 134),
(248, 2, '506L1', 'Santa Fe Tam', 'Boulevard Adolfo Lopez Mateos, #202, Col. El Huerto, Gonzalez, Tamaulipas, México, 89715, entre esq. Carril Ejido Santa Fe y Hermenegildo Galeana', 22.8220313, -98.4281815, 134),
(249, 2, '5074G', 'De Los Rios Tam', 'Avenida Cam. Al Ejido Ricardo Flores Magon, #803, Col. Puerto Industrial, Altamira, Tamaulipas, México, 89603, entre esq. Blvr de los Ríos', 22.4530549, -97.8998904, 134),
(250, 2, '5081E', 'Esteros Tam', 'Calle Cuahutemoc, #100, Col. Esteros, Altamira, Tamaulipas, México, 89620, entre esq Carretera Tampico Mante e Hidalgo', 22.5217400, -98.1245533, 134),
(251, 2, '509KX', 'Gas El 40 Tam', 'Carretera Federal 80 Tampico Mante, #40308, Col. Perseverancia, Altamira, Tamaulipas, México, 89642, entre Benito Juarez  Y Carretera Estacion Colonias', 22.4978707, -98.0602239, 134),
(252, 2, '50CGZ', 'Gonzalez Centro Tam', 'Calle Benito Juarez, #116, Col. Zona Centro, Gonzalez, Tamaulipas, México, 89700, entre esq. Blvr Morelos y Francisco I. Madero', 22.8284285, -98.4264394, 134),
(253, 2, '50ESH', 'Est. Cuauhtemoc Tam', 'Carretera Tampico Mante, #101, Col. Cuauhtemoc, Altamira, Tamaulipas, México, 89610, entre Jose Escandon y Altamira', 22.5528278, -98.1496564, 134),
(254, 2, '50KHB', 'Manuel Centro Tam', 'Calle Miguel Hidalgo, #207, Col. Zona Centro, Villa Manuel, Tamaulipas, México, 89730, entre esq. Belisario Dominguez y Revolucion', 22.7280785, -98.3216801, 134),
(255, 2, '50LFD', 'Lib. Manuel Tam', 'Libramiento Manuel Gonzalez Km 404, #4450, Col. Cuauhtemoc, Altamira, Tamaulipas, México, 89610, entre Gasolineras', 22.7437762, -98.2984855, 134),
(256, 2, '50LO8', 'Agropecuarios Maf', 'Carretera Federal 80 Mante-Tampico, #S/N, Col. Zona Rural Norte, Altamira, Tamaulipas, México, 89602, entre Acceso a Policyd y Ej. Santa Amailia', 22.4497570, -97.9768308, 134);
INSERT INTO `tienda` (`id`, `plaza_id`, `codigo`, `nombre`, `direccion`, `latitud`, `longitud`, `asesor_ti_usuario_id`) VALUES
(257, 2, '50M73', 'Gas Manuel Tmp', 'Libramiento Estacion Manuel Gonzalez Km 7+300, #1008 nte, Col. Villa Gonzalez, Gonzalez, Tamaulipas, México, 89710, entre Gasolineras Nexum', 22.7613614, -98.3154911, 134),
(258, 2, '50NF7', 'Seis Tam', 'Avenida Insurgentes, #S/N, Col. Estacion Manuel Centro, Gonzalez, Tamaulipas, México, 89730, entre Esq. Seis', 22.7294424, -98.3121644, 134),
(259, 2, '50PV1', 'Jose Maria Tam', 'Avenida Insurgentes, #313 pte, Col. Zona Centro, Villa Manuel, Tamaulipas, México, 89730, entre esq. Jose Maria Pino Suarez y Álvaro Obregón', 22.7324790, -98.3243282, 134),
(260, 2, '50QDV', 'Cuauhtemoc Centro Tam', 'Avenida Altamira, #101, Col. Cuauhtemoc, Altamira, Tamaulipas, México, 89610, entre esq. Ave. Cuauhtemoc y Pedro Jose Mendez', 22.5425223, -98.1504510, 134),
(261, 2, '50QLK', 'Puerto Altamira Tam', 'Boulevard De Los Rios, #3280, Col. Alejandro Briones, Altamira, Tamaulipas, México, 89603, entre esq. Entrada UT', 22.4336497, -97.8914126, 134),
(262, 2, '50RA5', 'Estacion Colonias Tam', 'Calle Adolfo Lopez Mateos, #100, Col. Estación Colonias, Altamira, Tamaulipas, México, 89650, entre esq. Fidel Velazquez', 22.4412578, -98.0166804, 134),
(263, 2, '50TS7', 'Puente Roto Maf', 'Carretera Federal 80 Tampico Mante, #31000-A, Col. Zona Rural Norte, Altamira, Tamaulipas, México, 89636, entre Equina con Nuevo Libramiento de Altamira al Puerto Industrial', 22.4591589, -97.9816275, 134),
(264, 2, '50WIY', 'Villa Cuauhtemoc Tam', 'Carretera Tampico Mante Km 53+200, #340, Col. Cuauhtemoc, Altamira, Tamaulipas, México, 89610, entre Jose de Escandon y Enrique Cardenas', 22.5559397, -98.1511849, 134),
(265, 2, '50ZBK', 'Gonzalez Tam', 'Carretera Tampico Mante, #907 PTE., Col. Gonzalez Villa, Gonzalez, Tamaulipas, México, 89700, entre Felipe Angeles Y Emiliano Zapata', 22.8235155, -98.4377925, 134),
(266, 2, '505Q5', 'Rio Tamesi Maf', 'Calle Rio Tamesi, #200, Col. Graciano Sanchez, Gonzalez, Tamaulipas, México, 89740, entre Esquina Enrique Cardenas Gonzalez y 10 de Abril', 22.6605670, -98.5513413, 134),
(267, 2, '50H2A', 'Villa Manuel Maf', 'Calle 16 De Septiembre, #518, Col. Estacion Manuel Centro, Gonzalez, Tamaulipas, México, 89730, entre esq. Emiliano Zapata y Aquiles Serdan', 22.7285973, -98.3170772, 134),
(268, 2, '505EV', 'Gonzalitos Maf', 'Calle Guadalupe Victoria, #1100, Col. Cesar Lopez De Lara, Gonzalez, Tamaulipas, México, 89716, entre esq. Maclovio Herrera y Genovevo Rivas', 22.8322614, -98.4347266, 134),
(269, 2, '50FE7', 'Santa Amalia Tam', 'Calle 10, #315, Col. Felipe Carrillo Puerto, Altamira, Tamaulipas, México, 89602, entre esq. Central 5 y Central 6', 22.4320309, -97.9668336, 134),
(270, 2, '501XQ', 'Vialidad Pd Tam', 'Vialidad PD, #2321, Col. Arboledas, Altamira, Tamaulipas, México, 89603, entre esq. Calle Limon sobre Blvr. Julio Rodolfo Moctezuma', 22.3971000, -97.8990410, 134),
(271, 2, '5096D', 'Electricistas Tam', 'Calle Real, #121, Col. Electricistas, Altamira, Tamaulipas, México, 89602, entre Pico de Orizaba y Manzanillo', 22.4195635, -97.9345376, 134),
(272, 2, '50GKB', 'Ornato Tam', 'Calle Tabasco, #1701, Col. Leon F Gual S-2, Altamira, Tamaulipas, México, 89602, entre esq. Ornato y San Luis Potosi', 22.4159374, -97.9229252, 134),
(273, 2, '50181', 'Camaleon Tam', 'Carretera Tampico Mante esq. Naranjo, #103, Col. Alameda, Altamira, Tamaulipas, México, 89602, entre Naranjo y Cedro', 22.4042280, -97.9294080, 134),
(274, 2, '501HK', 'Santa Elena', 'Calle Miguel Hidalgo y Costilla, #201-B, Col. Revolución Verde, Altamira, Tamaulipas, México, 89604, entre C.Quetzal y Constitución', 22.3252571, -97.8492715, 134),
(275, 2, '502R0', 'C-5 Maf', 'Avenida Perimetral duport, #785, Col. Fraccionamiento San Jacinto, Altamira, Tamaulipas, México, 89603, entre esq. San Angel y San Jacinto', 22.3904766, -97.9078756, 134),
(276, 2, '506IK', 'Valle Dorado Tam', 'Avenida Armada de mexico, #216, Col. Americo Villareal Guerra, Altamira, Tamaulipas, México, 89604, entre esq. Cielo y Divisoria', 22.3244245, -97.8704158, 134),
(277, 2, '509UI', 'Gas Monte Alto Tam', 'Avenida De La Industria, #18000, Col. Monte Alto, Altamira, Tamaulipas, México, 89606, entre Esq. Calle 15 Y Calle 17', 22.3813595, -97.9144040, 134),
(278, 2, '50ABO', 'Arboledas Tam', 'Vialidad Perimetro Duport, #S/N, Col. Altamira, Altamira, Tamaulipas, México, 89600, entre esq. C2 y Cipres', 22.3875104, -97.9123526, 134),
(279, 2, '50AV6', 'Valle Esmeralda Tam', 'Calle C-2, #101, Col. Valle Esmeralda, Altamira, Tamaulipas, México, 89607, entre contra esq. C.1 y C.100', 22.3996579, -97.9135001, 134),
(280, 2, '50BAM', 'Nuevo Madero Tam', 'Calle Oceano Pacifico, #2121, Col. Nuevo Madero, Altamira, Tamaulipas, México, 89604, entre esq. Golfo de Tehuantepec y Golfo de Bengala', 22.3475830, -97.8548613, 134),
(281, 2, '50BXH', 'Deportivo Sur Tam', 'Carretera Puerto Industrial, #2440, Col. Venustiano Carranza, Altamira, Tamaulipas, México, 89600, entre esq. Primex y Esmeralda', 22.4033879, -97.9106014, 134),
(282, 2, '50CZK', 'Vidal Tam', 'Avenida De La Industria, #10680, Col. Tampico Altamira, Altamira, Tamaulipas, México, 89609, entre esq. Plaza Arenas', 22.3287594, -97.8744190, 134),
(283, 2, '50D8L', 'Avenida Cuarta Tam', 'Avenida 18 De Marzo, #1611, Col. Miramar Sector 1, Altamira, Tamaulipas, México, 89604, entre esq. C. Cuarta y Tercera', 22.3417435, -97.8689310, 134),
(284, 2, '50DCO', 'Crit Tam', 'Avenida Plan De Ayala, #1400, Col. Fidel Velazquez, Altamira, Tamaulipas, México, 89602, entre esq. con Carretera Tampico Mante', 22.4025861, -97.9271686, 134),
(285, 2, '50DVR', 'Divisoria Tam', 'Carretera Tampico Mante, #409, Col. Americo Villareal Guerra, Altamira, Tamaulipas, México, 89609, entre esq. Divisoria', 22.3236853, -97.8760260, 134),
(286, 2, '50HVY', 'Durazno Tam', 'Calle Durazno, #101, Col. Guadalupe Victoria , Altamira, Tamaulipas, México, 89602, entre contra esq. C.Pera', 22.4093664, -97.9192421, 134),
(287, 2, '50NVK', 'Pedrera Tam', 'Calle C.16, #S/N, Col. Santa Monica, Altamira, Tamaulipas, México, 89600, entre esq. Rosa Limbo', 22.3885761, -97.8847904, 134),
(288, 2, '50OP3', 'Retama Tam', 'Calle C7 Sur, #406, Col. Corredor Industrial , Altamira, Tamaulipas, México, 89603, entre C. 7 Pte y Papelera', 22.3819510, -97.9112913, 134),
(289, 2, '50SVA', 'Los Olivos Tam', 'Calle Paseo De Los Olivos, #120-A, Col. Los Olivos, Altamira, Tamaulipas, México, 89603, entre Vialidad PD', 22.3963415, -97.9031520, 134),
(290, 2, '50VIA', 'Villas Tam', 'Avenida Tamaulipas, #100, Col. Villas De Altamira, Altamira, Tamaulipas, México, 89600, entre esq. Arboledas y C.15', 22.3959173, -97.8863698, 134),
(291, 2, '50WXF', 'Bateria 7 Tam', 'Calle Olmo, #1500, Col. Altamira Sector 4, Altamira, Tamaulipas, México, 89605, entre esq. Los Mangos y Ornato', 22.4160926, -97.9315814, 134),
(292, 2, '50YUO', 'Ficus Tam', 'Calle C-5, #179, Col. Arboledas, Altamira, Tamaulipas, México, 89603, entre esq. Acacia y Ficus', 22.3928603, -97.9099713, 134),
(293, 2, '50YUV', 'Arrecifes Tam', 'Calle C.15, #103, Col. Arrecifes, Altamira, Tamaulipas, México, 89603, entre esq Ave. Tamaulipas y Acamaya', 22.3954222, -97.8877749, 134),
(294, 2, '50YUX', 'Sauce II Tam', 'Calle Sauce, #200, Col. Arboledas, Altamira, Tamaulipas, México, 89603, entre Fresno Y Almendro', 22.3952654, -97.9016043, 134),
(295, 2, '50973', 'Sector 3 Tam', 'Boulevard Allende, #1100, Col. Sector 3, Altamira, Tamaulipas, México, 89602, entre Guadalajara y Lazaro Cárdenas', 22.4089078, -97.9381230, 134),
(296, 2, '50H6R', 'Madrid Maf', 'Calle Primera de Mayo, #1800, Col. Primavera, Miramar, Tamaulipas, México, 89604, entre Esq. Madrid y Paris', 22.3301460, -97.8628730, 134),
(297, 2, '5008G', 'Palmillas Maf', 'Carretera Cd. Victoria - Tula, #Km. 85, Col. Palmillas, Palmillas, Tamaulipas, México, 87976, entre Sin entre calles', 23.3083459, -99.5568429, 134),
(298, 2, '501EA', 'Baez Maf', 'Carretera Cd. Victoria-Llera de Canales, #S/N, Col. Ejido Santa Librada, Ciudad Victoria, Tamaulipas, México, 87136, entre ', 23.7052814, -99.1190102, 134),
(299, 2, '502K2', 'Jaumave Plaza Maf', 'Calle Miguel Hidalgo y Costilla, #S/N, Col. Jaumave, Jaumave, Tamaulipas, México, 87930, entre esq. Nicolas Bravo y Guadalupe Victoria', 23.4053852, -99.3750376, 134),
(300, 2, '5060E', 'Pedro Sosa 1 Maf', 'Calle America Española, #S/N, Col. Ampliacion Pedro Sosa, Ciudad Victoria, Tamaulipas, México, 87180, entre Esq. Sucesion Sosa', 23.7166692, -99.1327118, 134),
(301, 2, '507EU', 'Rio Blanco Maf', 'Calle Gonzalez, #223, Col. Centro De Desarrollo De La Comunidad, Ciudad Victoria, Tamaulipas, México, 87100, entre Esquina Calle Martires De Rio Blanco', 23.7249408, -99.1351195, 134),
(302, 2, '508HH', 'Clinica Imss Maf', 'Calle Enrique Cardenas Gonzalez, #11, Col. Barrio El Jicote, Tula, Tamaulipas, México, 87900, entre Esq. Con Mateo Acuña', 22.9917444, -99.7181107, 134),
(303, 2, '50GZW', '8 Y Garza Maf', 'Calle Juan B. Tijerina, #102, Col. Guadalupe Mainero, Ciudad Victoria, Tamaulipas, México, 87100, entre Esq Con Juan Jose De La Garza', 23.7274095, -99.1442639, 134),
(304, 2, '50JQ5', 'Lomas De Guadalupe Maf', 'Carretera A Cd. Mante, #1310, Col. Lomas De Guadalupe, Ciudad Victoria, Tamaulipas, México, 87270, entre Entrada Al Fracc. Lomas De Guadalupe', 23.7126659, -99.1285782, 134),
(305, 2, '50JUM', 'Jaumave Maf', 'Carretera Victoria-San Luis Potosí Km. 112, #S/N, Col. Jaumave, Jaumave, Tamaulipas, México, 87930, entre Pedro Jose Mendez e Ignacio Lopez Rayon', 23.4083813, -99.3857221, 134),
(306, 2, '50JYD', 'Santuario 2 Maf', 'Calle Lomas De Santuario, #236, Col. Pedro Sosa, Ciudad Victoria, Tamaulipas, México, 87120, entre Argentina Y Guatemala', 23.7181000, -99.1453000, 134),
(307, 2, '50JZW', 'San Luis Maf', 'Carretera Rumbo Nuevo, #S/N, Col. Boca De Juan Capitan, Ciudad Victoria, Tamaulipas, México, 87261, entre Km. 1', 23.6633332, -99.1075913, 134),
(308, 2, '50P0X', 'Arroyo Loco Maf', 'Calle Lerdo De Tejada, #1, Col. Tula Centro, Tula, Tamaulipas, México, 87900, entre Esq. Con Emiliano Vazquez Gomez', 22.9994383, -99.7120471, 134),
(309, 2, '50PD1', 'Jaumave 2 Maf', 'Carretera Jaumave Tula Km 108, #410, Col. Jaumave, Jaumave, Tamaulipas, México, 87930, entre Sin Calles', 23.3951258, -99.4141151, 134),
(310, 2, '50SUO', 'Santuario Maf', 'Avenida Del Santuario, #S/N, Col. Loma Alta, Ciudad Victoria, Tamaulipas, México, 87180, entre Esq. Republica De Mexico', 23.7173700, -99.1444100, 134),
(311, 2, '50W07', 'Tula Centro Maf', 'Calle Juarez, #1, Col. Tula Centro, Tula, Tamaulipas, México, 87900, entre Esq. Con Calle Matamoros', 22.9967716, -99.7118080, 134),
(312, 2, '50Y4M', 'Jaumave Centro Maf', 'Calle Miguel Hidalgo y Costilla, #652, Col. Zona Centro, Jaumave, Tamaulipas, México, 87930, entre esq. Aldama e Ignacio Allende', 23.4059013, -99.3832764, 134),
(313, 2, '50YLO', 'La Loma Maf', 'Calle Paseo Lomas De Rosales, #225, Col. La Gloria, Ciudad Victoria, Tamaulipas, México, 87130, entre esq. Av. De la Unidad y Blvr Fidel Velazquez', 23.7193664, -99.1288111, 134),
(314, 2, '50DY4', '4 Boulevard Maf', 'Boulevard Praxedis Balboa, #1403, Col. Zona Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre esq. Ascension Gomez y Gral L. Valle Nte.', 23.7291732, -99.1404331, 134),
(315, 2, '50FMY', '8 Boulevard Maf', 'Calle Juan B. Tijerina, #237, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Boulevard Praxedis Balboa', 23.7298609, -99.1440892, 134),
(316, 2, '50SA8', '12 de Septiembre Maf', 'Calle 5 de Febrero, #106, Col. Constituyentes, Ciudad Victoria, Tamaulipas, México, 87180, entre Esq. Republica De Mexico y 19 de Mayo.', 23.7111730, -99.1426410, 134),
(317, 2, '50401', 'Revolucion Verde Maf', ' , #, Col. , , , , , entre ', 23.7487025, -99.1304042, 130),
(318, 2, '509AD', 'Del Norte Maf', 'Boulevard Fidel Velazquez, #1915, Col. Fraccionamiento los Doctores, Ciudad Victoria, Tamaulipas, México, 87024, entre Dr. Carlos Canales y Dr. Anaya Damaso', 23.7498650, -99.1390894, 130),
(319, 2, '501XB', 'Martires Maf', 'Calle Martires De Chicago, #2057, Col. Zona Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esquina Con Zaragoza', 23.7888000, -99.1334000, 130),
(320, 2, '503CP', 'Sulaiman Maf', 'Avenida Jose Sulaiman Chagnon, #3005, Col. Adolfo Lopez Mateos, Ciudad Victoria, Tamaulipas, México, 87020, entre Esquina Con Calle Janambres', 23.7471960, -99.1263570, 130),
(321, 2, '505CV', 'Hombres Ilustres 2 Maf', 'Avenida Familia Rotaria, #867, Col. Adolfo Lopez Mateos, Ciudad Victoria, Tamaulipas, México, 87020, entre Esquina Fray Luis Caballero', 23.7512782, -99.1292846, 130),
(322, 2, '507Q4', 'Teosuchil Maf', 'Avenida Tenochtitlan, #301, Col. Teocaltiche, Ciudad Victoria, Tamaulipas, México, 87024, entre Esquina Con Calle Treosuchil', 23.7556074, -99.1283171, 130),
(323, 2, '50BSX', 'Abasolo Maf', 'Boulevard Fidel Velazquez, #613, Col. Tamaulipas, Ciudad Victoria, Tamaulipas, México, 87090, entre Abasolo Y Allende', 23.7350065, -99.1300317, 130),
(324, 2, '50CSB', 'Fidel Velazquez II Maf', 'Calle Fidel Velazquez, #275, Col. Tamaulipas, Ciudad Victoria, Tamaulipas, México, 87090, entre Esq. Con Miguel Hidalgo', 23.7311674, -99.1298976, 130),
(325, 2, '50DQC', '14 Boulevard Maf', 'Boulevard Adolfo Lopez Mateos, #438, Col. Dr Treviño Zapata, Ciudad Victoria, Tamaulipas, México, 87020, entre Esq. Con Calle Catorce', 23.7527134, -99.1471809, 130),
(326, 2, '50FDV', 'Fidel Velazquez Maf', 'Boulevard Fidel Velazquez, #1310, Col. Residencial Las Palmas, Ciudad Victoria, Tamaulipas, México, 87050, entre Jose Sulaiman Y Olivia Ramirez', 23.7414177, -99.1333942, 130),
(327, 2, '50FYA', 'Arguelles Maf', 'Calle Morelos, #200, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Con Nuñez De Caceres ', 23.7321169, -99.1424399, 130),
(328, 2, '50HII', 'Hombres Ilustres Maf', 'Avenida Rotarios, #301, Col. Adolfo Lopez Mateos, Ciudad Victoria, Tamaulipas, México, 87025, entre Esq. Con Av. Autonoma De Nuevo Leon', 23.7523835, -99.1362296, 130),
(329, 2, '50HVZ', '5 Ceros Maf', 'Calle Gral. Carrera Torres, #2302, Col. Obrera, Ciudad Victoria, Tamaulipas, México, 87090, entre Esq. Con Articulo 123 ', 23.7357195, -99.1326041, 130),
(330, 2, '50RRA', '18 De Julio Maf', 'Calle 18 De Julio, #1050, Col. Benito Juarez, Ciudad Victoria, Tamaulipas, México, 87090, entre Esq. Con Blvd. Fidel Velázquez ', 23.7379382, -99.1298648, 130),
(331, 2, '50SAC', 'Salubridad Maf', 'Calle Francisco I. Madero (Calle 17), #451, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esquina Con Bravo', 23.7354362, -99.1517294, 130),
(332, 2, '50TGU', '13 Yucatan Maf', 'Calle Gaspar De La Garza, #430, Col. Valle Aguayo, Ciudad Victoria, Tamaulipas, México, 87020, entre Esq. Con Yucatán', 23.7570481, -99.1462740, 130),
(333, 2, '50TWQ', 'Tenochtitlan Maf', 'Calle Rio Corona, #S/N, Col. Teocaltiche, Ciudad Victoria, Tamaulipas, México, 87024, entre Esq. Con Rio Guayalejo', 23.7535578, -99.1274609, 130),
(334, 2, '50UXB', 'Berriozabal Maf', 'Avenida Berriozabal, #1108, Col. Morelos, Ciudad Victoria, Tamaulipas, México, 87050, entre F De La Garza Y Calle Privada', 23.7401039, -99.1372245, 130),
(335, 2, '50VGY', 'Valle De Aguayo Maf', 'Boulevard Adolfo Lopez Mateos, #899, Col. Valle Aguayo, Ciudad Victoria, Tamaulipas, México, 87020, entre Esq. Con Cristobal Colon', 23.7529611, -99.1434371, 130),
(336, 2, '50WMI', 'Ocho Michoacan Maf', 'Avenida Tamaulipas, #3191, Col. Villa Verde, Ciudad Victoria, Tamaulipas, México, 87025, entre Esq. Con Michoacan', 23.7591296, -99.1400879, 130),
(337, 2, '50WQN', 'Castaneda Maf', 'Calle Prolongacion Mina, #847, Col. Tamaulipas, Ciudad Victoria, Tamaulipas, México, 87090, entre Esq. Con Estefania Castañeda', 23.7372489, -99.1235536, 130),
(338, 2, '50XDG', '1 Matamoros Maf', 'Calle Matamoros, #1647, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Con Calle Uno', 23.7324460, -99.1377946, 130),
(339, 2, '50XJL', 'Rectoria Maf', 'Calle Matamoros, #301, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Con Cristobal Colon (Calle 9)', 23.7332193, -99.1449377, 130),
(340, 2, '50YCR', '3 Carrera Maf', 'Calle Carrera Torres, #1501, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Con Leandro Valle', 23.7368433, -99.1391557, 130),
(341, 2, '50YHI', '14 Hidalgo Maf', 'Calle Miguel Hidalgo, #401, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Con Emiliano P.Nafarrete', 23.7319460, -99.1496888, 130),
(342, 2, '50YJF', 'Rotario Maf', 'Avenida Familia Rotaria, #S/N, Col. Burocratas Municipales, Ciudad Victoria, Tamaulipas, México, 87024, entre Esq. Con Av. Jose Sulaiman', 23.7507466, -99.1239292, 130),
(343, 2, '50YJI', 'Olivia Maf', 'Calle J. Nuuez De Caceres, #S/N, Col. Las Palmas, Ciudad Victoria, Tamaulipas, México, 87140, entre Esq. Con Olivia Ramírez', 23.7423570, -99.1412599, 130),
(344, 2, '50YJN', 'Hospital General Maf', 'Avenida Ricardo Flores Magon, #S/N, Col. Doctores, Ciudad Victoria, Tamaulipas, México, 87024, entre Esq. Con Fidel Velázquez', 23.7490888, -99.1379780, 130),
(345, 2, '50YNX', 'Colon Maf', 'Calle Cristobal Colon, #295, Col. San Jose, Ciudad Victoria, Tamaulipas, México, 87040, entre Esq. Con Veracruz ', 23.7467007, -99.1444532, 130),
(346, 2, '5085F', 'Tamaulipas II Tam', 'Calle Agustin de Iturbide, #310, Col. Zona Centro, Altamira, Tamaulipas, México, 89600, entre esq. Tamaulipas y Matamoros', 22.3933806, -97.9338671, 134),
(347, 2, '50ALR', 'Altamira Tam', 'Carretera Tampico Mante, #1312, Col. Altamira Sect 4, Altamira, Tamaulipas, México, 89602, entre Emiliano Portes Gil y México', 22.4145351, -97.9374062, 134),
(348, 2, '50BAX', 'Fco I. Madero Tam', 'Calle Gral. Fco. I. Madero, #603-A, Col. Francisco I. Madero, Altamira, Tamaulipas, México, 89603, entre esq. Reforma y Alfredo Vladimir Bonfil', 22.3582522, -97.8830196, 134),
(349, 2, '50CMP', 'Floresta Tam', 'Avenida Dr. Burton E. Grossman, #211, Col. Loma Bonita, Altamira, Tamaulipas, México, 89605, entre esq. Lic. Francisco T. Villareal y Lic. Enrique Luengas Piñeiro', 22.3236620, -97.8875965, 134),
(350, 2, '50DDL', 'Santa Anita Tam', 'Calle 20 De Noviembre, #517, Col. Revolucion Verde, Altamira, Tamaulipas, México, 89607, entre esq.Tampico y Obregon', 22.3912605, -97.9463695, 134),
(351, 2, '50E20', 'Capitan Tam', 'Calle Fundo Legal, esq. Capitan Perez, #303, Col. Zona Centro, Altamira, Tamaulipas, México, 89600, entre Cto. del Muelle y Campanario Residencial', 22.3936427, -97.9413116, 134),
(352, 2, '50EJN', 'Allende Tam', 'Boulevard I Allende, #1500, Col. Roger Gomez, Altamira, Tamaulipas, México, 89603, entre esq. Blvr Jose Romero Garcia y Ebano', 22.4136361, -97.9408672, 134),
(353, 2, '50IFF', 'Florida Tam', 'Boulevard De La Laguna, #S/N, Col. Revolucion Verde, Altamira, Tamaulipas, México, 89607, entre Lindero Y Calle Sin Nombre', 22.3995165, -97.9438036, 134),
(354, 2, '50IOX', 'El Eden Tam', 'Calle Hipólito Cepeda, #701, Col. Industrial Guerrero , Altamira, Tamaulipas, México, 89603, entre Lerdo Tejeda y Canatlan', 22.3957319, -97.9279432, 134),
(355, 2, '50LB3', 'Ejido Miramar Tam', 'Calle Salvador Días Miron, #1515, Col. Serapio Venegas, Altamira, Tamaulipas, México, 89604, entre esq. Jose Ortiz de Dominguez y 2 de Mayo', 22.3308851, -97.8668281, 134),
(356, 2, '50M82', 'Osa Mayor Tam', 'Calle Meteorito, #918, Col. Unidad Satelite , Altamira, Tamaulipas, México, 89603, entre esq. Osa Mayor y Ave. Del Sol', 22.3618817, -97.8825664, 134),
(357, 2, '50MBJ', 'Altamira Mercado Tam', 'Calle Miguel Hidalgo, #104, Col. Zona Centro, Altamira, Tamaulipas, México, 89600, entre Melchor Ocampo y Blvr. I Allende', 22.3965613, -97.9358785, 134),
(358, 2, '50NXH', '18 De Marzo Tam', 'Avenida 18 De Marzo, #1100-C, Col. Nuevo Tampico, Miramar, Tamaulipas, México, 89604, entre esq. Lazaro Cardenas y Juarez', 22.3356332, -97.8662991, 134),
(359, 2, '50O53', 'Tec Monterrey Tam', 'Boulevard Petrocel, #Km 1.3, Col. Puerto Industrial De Altamira, Altamira, Tamaulipas, México, 89603, entre Aulas 1 Incubadora de empresas Tecnologico de Monterrey', 22.3815732, -97.9022013, 134),
(360, 2, '50OAT', 'Altamira Centro Tam', 'Calle Morelos, #410, Col. Zona Centro, Altamira, Tamaulipas, México, 89600, entre esq. Quintero y Capitán Pérez', 22.3917731, -97.9357760, 134),
(361, 2, '50ODK', 'Gaviotas Tam', 'Boulevard I. Allende, #601, Col. Villas De Altamira, Altamira, Tamaulipas, México, 89600, entre esq Blvr. Cuco Sánchez', 22.3915643, -97.9300480, 134),
(362, 2, '50RRG', 'Benito Juarez Tam', 'Calle Altamira, #610, Col. Petrolera, Altamira, Tamaulipas, México, 89602, entre esq. Benito Juarez y Simon Bolivar', 22.4056079, -97.9423943, 134),
(363, 2, '50RXV', 'Revolucion Tam', 'Calle Altamira, #402, Col. Revolucion Verde, Altamira, Tamaulipas, México, 89607, entre esq. Jose Escandon y Obregon', 22.3873778, -97.9450338, 134),
(364, 2, '50TY6', 'Santos Degollado Tam', 'Avenida Adolfo Lopez Mateos, #1001, Col. Tampico Altamira Sector 2, Altamira, Tamaulipas, México, 89605, entre esq. Santos Degollado y Francisco Javier Mina', 22.3264677, -97.8827363, 134),
(365, 2, '50U0F', 'Movil Victoria Maf', 'Calle Emiliano P. Nafarrete, #401-B, Col. Zona Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Hidalgo Y Morelos', 23.7322000, -99.1498000, 134),
(366, 2, '50V28', 'El Faro', 'Calle Pedro J Mendez, #53-46, Col. Jardines de champayan, Altamira, Tamaulipas, México, 89607, entre esq Pedro J. Mendez y Laguna de Champayan', 22.3875552, -97.9500173, 134),
(367, 2, '50VJ7', 'Secundaria 1 Maf', 'Calle Vicente Guerrero, #537, Col. Zona Centro, Altamira, Tamaulipas, México, 89600, entre esq. C. Juarez y Quintero', 22.3903273, -97.9389727, 134),
(368, 2, '50XBK', 'Mina Tam', 'Calle Francisco Javier Mina, #218, Col. Zona Centro, Altamira, Tamaulipas, México, 89600, entre esq. Iturbide y Mariano Abasolo', 22.3941533, -97.9373321, 134),
(369, 2, '50YNE', 'Argentina Tam', 'Avenida 18 De Marzo, #2117-C, Col. Primavera, Miramar, Tamaulipas, México, 89604, entre esq. Nuevo Leon y Nayarit', 22.3267327, -97.8622229, 134),
(370, 2, '50ZMH', 'Guerrero II Tam', 'Calle Vicente Guerrero, #605, Col. Infonavit, Altamira, Tamaulipas, México, 89605, entre esq. Lazaro Cardenas y Guillermo Prieto', 22.3332118, -97.8811296, 134),
(371, 2, '50F4P', 'Fundo Legal Maf', 'Calle Fundo Legal, #S/N, Col. Altamira Centro, Altamira, Tamaulipas, México, 89600, entre Esq. Mariano Abasolo e Iturbide', 22.3956616, -97.9407397, 134),
(372, 2, '50V7Z', 'Bahia Tam', 'Calle 2 De Mayo, #206, Col. Jose Maria Morelos, Altamira, Tamaulipas, México, 89604, entre esq. Segunda y Primera', 22.3338463, -97.8605004, 134),
(373, 2, '503OG', 'Barquito Tam', 'Carretera Tampico-Mante Cd. Mante-Tampico, #Km 14, Col. Avenida de la Industria, Altamira, Tamaulipas, México, 89605, entre Blvr. Nautico y Emiliano Zapata', 22.3427330, -97.8756858, 134),
(374, 2, '50KH9', 'Avenida De La Industria Tam', 'Avenida De La Industria, #12720, Col. La Laguna De La Puerta, Altamira, Tamaulipas, México, 89609, entre esq. Acceso interiror Hules Mexicanos y Acceso a Chemours', 22.3475251, -97.8776009, 134),
(375, 2, '502O6', 'Colinas Tam', 'Calle Veracruz, #500, Col. Colinas De Altamira, Altamira, Tamaulipas, México, 89603, entre Durango Y Chihuahua', 22.3682037, -97.8813073, 134),
(376, 2, '503DX', 'Encinos Tam', 'Avenida De La Industria, #13850-A, Col. Laguna De La Puerta, Altamira, Tamaulipas, México, 89603, entre Laguna De Champayan Nte Y Blvd. Nautico', 22.3533329, -97.8866309, 134),
(377, 2, '504W9', 'Moroncito Tam', 'Calle Matamoros, #402, Col. Aldama, Aldama, Tamaulipas, México, 89670, entre Esquina Calle Nicolas Bravo', 22.9178004, -98.0779755, 134),
(378, 2, '505MH', 'Lagunas De Miralta Tam', 'Avenida De la Industria, #14170-A, Col. Residencial Laguna de Miralta, Altamira, Tamaulipas, México, 89605, entre Laguna de Champayan Norte', 22.3554676, -97.8893216, 134),
(379, 2, '507OV', 'Villas Del Sol Tam', 'Calle Altamira, #323, Col. Fraccionamiento Municipios Libres, Altamira, Tamaulipas, México, 89603, entre esq. Jaumave y Abasolo', 22.3681363, -97.8857603, 134),
(380, 2, '508SU', 'Canarios Tam', 'Calle Pelicanos, #100, Col. Fraccionamiento Canarios, Altamira, Tamaulipas, México, 89606, entre contra esquina Avestruz y Arao', 22.3760534, -97.9141274, 134),
(381, 2, '50956', 'Luis Caballero Tam', 'Calle Primo De Verdad, #209-A, Col. Luis Caballero, Aldama, Tamaulipas, México, 89670, entre Esq.Josefa Ortiz De Dominguez', 22.9313100, -98.0789700, 134),
(382, 2, '50APC', 'Lirios Tam', 'Calle Cedro, #1415, Col. Monte Alto 3, Altamira, Tamaulipas, México, 89606, entre esq. Gardenia y Rosal', 22.3691866, -97.9061922, 134),
(383, 2, '50BDP', 'Azteca Tam', 'Calle Cuauhtemoc, #153, Col. Azteca, Altamira, Tamaulipas, México, 89606, entre Esq Quinta Avenida y Cuarta Avenida', 22.3636059, -97.9101294, 134),
(384, 2, '50DMW', 'Aldama II Tam', 'Calle Pedro J. Mendez, #919, Col. Zona Centro, Aldama, Tamaulipas, México, 89670, entre esq. Carretera Costera del Golfo Federal 180 y Ocampo', 22.9229804, -98.0809626, 134),
(385, 2, '50KAD', 'Aldama Tam', 'Carretera Costera del Golfo Federal 180, #S/N, Col. Zona Centro, Aldama, Tamaulipas, México, 89670, entre esq. Enrique Cardenaz', 22.9210753, -98.0848413, 134),
(386, 2, '50LCI', 'Constitucion Tam', 'Calle Constitucion, #581, Col. Constitucion, Aldama, Tamaulipas, México, 89670, entre esq. America y Argentina', 22.9126553, -98.0755837, 134),
(387, 2, '50MXY', 'Monte Alto Tam', 'Avenida Ciudad Mante-Tampico, #600, Col. Monte Alto, Altamira, Tamaulipas, México, 89608, entre entre esq. Calle 3 y Calle 1', 22.3777662, -97.9101116, 134),
(388, 2, '50PHB', 'Brownsville Tam', 'Calle Libertad, #407, Col. Brownsville, Aldama, Tamaulipas, México, 89670, entre esq. Jardin y Carranza', 22.9260024, -98.0740950, 134),
(389, 2, '50SIR', 'Satelite Tam', 'Avenida Pedrera, #901, Col. Unidad Satelite , Altamira, Tamaulipas, México, 89603, entre esq. Ave del Sol y Osa Mayor', 22.3619408, -97.8876417, 134),
(390, 2, '50TG3', 'Rio Blanco Tam', 'Calle Demetrio Briones, #201, Col. Las Brisas, Altamira, Tamaulipas, México, 89606, entre esq. Rio Blanco y Golfo de Mexico', 22.3629130, -97.9154932, 134),
(391, 2, '50TML', 'Miraltas Tam', 'Carretera Tampico Mante Km 16 + 200, #1000, Col. La Laguna De La Puerta, Altamira, Tamaulipas, México, 89609, entre esq. Tampico y contra esq Laguna de Champayan Nte.', 22.3591184, -97.8913691, 134),
(392, 2, '50UUM', 'Aldama Centro Tam', 'Calle Independencia, #101, Col. Zona Centro, Aldama, Tamaulipas, México, 89670, entre esq. Centenario y Miguel Hidalgo y Costilla', 22.9199131, -98.0734628, 134),
(393, 2, '50W74', 'Carmin Tam', 'Calle Carmin, #1824, Col. Alejandro Briones 3, Altamira, Tamaulipas, México, 89606, entre esq. Camelia y Alcatraz', 22.3646636, -97.9046563, 134),
(394, 2, '50YOB', 'Arecas Tam', 'Calle Carrizo, #123, Col. Corredor Industrial , Altamira, Tamaulipas, México, 89603, entre C. 11 y Alamo', 22.3794245, -97.9065431, 134),
(395, 2, '50CQ8', 'Club de Leones Maf', 'Calle Matamoros, #402, Col. Zona Centro, Aldama, Tamaulipas, México, 89670, entre Esq. Lic. Benito Juárez y Xicoténcatl', 22.9170097, -98.0705718, 134),
(396, 2, '50EUP', 'La Paz II Maf', 'Avenida La Paz, #445, Col. La Paz, Ciudad Victoria, Tamaulipas, México, 87040, entre Esq. Con Calle Hnos. De La Garza', 23.7476711, -99.1202239, 130),
(397, 2, '504AD', 'Marina Centro', 'Calle Benito Juarez, #211, Col. Soto La Marina Centro, Soto La Marina, Tamaulipas, México, 87670, entre Esq. Con Felipe De La Garza', 23.7663322, -98.2060228, 130),
(398, 2, '505CO', 'Ejido la Pesca Maf', 'Calle Fracción Del Lote 9 Manzana 18 Zona 1, #S/N, Col. La Pesca, Soto La Marina, Tamaulipas, México, 87678, entre Sin Entre Calles', 23.7875995, -97.7755656, 130),
(399, 2, '508DH', 'Vicente Guerrero Maf', 'Calle La Paz, #930, Col. Vicente Guerrero, Ciudad Victoria, Tamaulipas, México, 87086, entre Esq Con Soto La Marina', 23.7374352, -99.1137053, 130),
(400, 2, '508FV', 'Coplamar Maf', 'Calle Antonio Caso, #130, Col. Zona Centro, Soto La Marina, Tamaulipas, México, 87670, entre Justo Sierra y Vicente Suarez', 23.7750000, -98.2050000, 130),
(401, 2, '5097Z', 'Marte Maf', 'Libramiento Naciones Unidas, #2061, Col. Marte R Gomez, Ciudad Victoria, Tamaulipas, México, 87137, entre Esq Con Ruben F. Flores', 23.7336594, -99.0917070, 130),
(402, 2, '509YX', 'Aptiv Maf', 'Calle Transformacion, #S/N, Col. Parque Industrial Nuevo Santander, Ciudad Victoria, Tamaulipas, México, 87137, entre Seccion Ii', 23.7256000, -99.0831000, 130),
(403, 2, '50C2U', 'Valle del Sol', 'Avenida 16 De Septiembre, #1490, Col. Valle Dorado, Ciudad Victoria, Tamaulipas, México, 87086, entre Esquina Con Valle Del Bravo', 23.7432379, -99.1130177, 130),
(404, 2, '50D60', 'Todos Por Tamaulipas Maf', 'Calle Rio Guadalquivir, #2238, Col. Todos Por Tamaulipas, Ciudad Victoria, Tamaulipas, México, 87134, entre Esq Calle Rio Ebreo', 23.7369375, -99.0976017, 130),
(405, 2, '50DM5', 'Lindavista Maf', 'Calle Ejercito Libertador, #311, Col. Linda Vista, Ciudad Victoria, Tamaulipas, México, 87134, entre Esquina Con Ejercito Mexicano', 23.7350000, -99.1064000, 130),
(406, 2, '50DQT', 'La Moderna Maf', 'Calle Rodriguez Inurrigaro, #3654, Col. Moderna, Ciudad Victoria, Tamaulipas, México, 87134, entre Esq. Con Azucena', 23.7328680, -99.1129095, 130),
(407, 2, '50E2Q', 'Aviles Maf', 'Carretera Soto La Marina, #S/N, Col. Altavista, Ciudad Victoria, Tamaulipas, México, 87134, entre Avenida Carlos A. Aviles', 23.7197845, -99.1047527, 130),
(408, 2, '50GFP', 'La Paz Maf', 'Avenida La Paz, #1205, Col. La Paz, Ciudad Victoria, Tamaulipas, México, 87089, entre 5 De Febrero Y 16 De Septiembre', 23.7415548, -99.1168614, 130),
(409, 2, '50GZA', 'Zaragoza Maf', 'Carretera A Soto La Marina, #S/N, Col. La Gloria, Ciudad Victoria, Tamaulipas, México, 87130, entre Km. 5', 23.7070527, -98.9929217, 130),
(410, 2, '50JYC', 'Chapultepec Maf', 'Avenida Mariano Otero, #1506, Col. Paseo De Los Olivos , Ciudad Victoria, Tamaulipas, México, 87130, entre Esq. Con Carlos A. Avilés', 23.7189906, -99.1166326, 130),
(411, 2, '50JZT', 'Zaragoza 2 Maf', 'Carretera 85 Nacional, #7105, Col. San Juan Y El Ranchito, Ciudad Victoria, Tamaulipas, México, 87273, entre Km. 64+700', 23.7226587, -98.9984358, 130),
(412, 2, '50KD1', 'Marina Vieja II Maf', 'Carretera Slm-Aldama, #S/N, Col. Soto La Marina, Soto La Marina, Tamaulipas, México, 87670, entre Carretera Slm-Aldama Y Slm-Cd. Victoria', 23.7309564, -98.2199911, 130),
(413, 2, '50MRJ', 'Marina Vieja Maf', 'Calle Miguel Hidalgo, #S/N, Col. Soto La Marina, Soto La Marina, Tamaulipas, México, 87670, entre Sarabia Y Bocanegra', 23.7703727, -98.2035909, 130),
(414, 2, '50RNV', 'Rumbo Nuevo Maf', 'Carretera A Soto La Marina, #S/N, Col. La Gloria, Ciudad Victoria, Tamaulipas, México, 87130, entre Km. 5', 23.7183419, -99.0949671, 130),
(415, 2, '50S1T', 'Alta Vista Maf', 'Carretera A Soto La Marina, #2817, Col. Altavista, Ciudad Victoria, Tamaulipas, México, 87078, entre Lomas Del Palmar Y Lomas De Castillo', 23.7195000, -99.1078000, 130),
(416, 2, '50Z3O', 'San Felipe II Maf', 'Calle Loma Linda, #2226, Col. Villas Del Carmen, Ciudad Victoria, Tamaulipas, México, 87135, entre Esq. Con Calle Alamo', 23.7164547, -99.1086900, 130),
(417, 2, '50A92', 'Zurita Maf', ' , #, Col. , , , , , entre ', 23.7492368, -99.1220400, 130),
(418, 2, '504VH', 'Malitzin Maf', 'Calle Horacio Teran, #S/N, Col. Bosques Campestre, Ciudad Victoria, Tamaulipas, México, 87024, entre Esq. Malitzin y Juan Escutia', 23.7591500, -99.1254340, 130),
(419, 2, '50UDG', 'Campestre Maf', 'Avenida Tenochtitlan, #1415, Col. Campestre, Ciudad Victoria, Tamaulipas, México, 87028, entre Marte R. Gomez Y Articulo 32', 23.7606800, -99.1299400, 130),
(420, 2, '5025Q', 'Royal Country Maf', 'Avenida Del Valle, #1312-1372, Col. Fraccionamiento del Valle, Ciudad Victoria, Tamaulipas, México, 87025, entre Baudelio Villanueva y 18 de Nov. De 1913', 23.7614244, -99.1335385, 130),
(421, 2, '504XP', 'Valle de Pajaritos Maf', 'Libramiento Naciones Unidas, #S/N, Col. Los Mirlos Residencial, Ciudad Victoria, Tamaulipas, México, 87084, entre Esquina Con Calle Dr. Jose Manuel Tirado', 23.7623554, -99.1089450, 130),
(422, 2, '505C7', 'Sierra Gorda Maf', 'Calle Mariano Matamoros, #S/N, Col. Centro, Jimenez, Tamaulipas, México, 87700, entre Esq. Sierra Gorda', 24.2137141, -98.4830154, 130),
(423, 2, '507JI', 'Nuevo Santander Umi', 'Calle Mexico, #256, Col. Nuevo Santander, Ciudad Victoria, Tamaulipas, México, 87039, entre Esquina Con Casa Tienda Cuervo', 23.7508536, -99.1115165, 130),
(424, 2, '50B9S', 'Olivin Maf', 'Carretera Victoria-Matamoros, #5330, Col. El Olivo, Ciudad Victoria, Tamaulipas, México, 87277, entre N/A', 23.7722140, -99.1083942, 130),
(425, 2, '50C6M', 'Agronomos Maf', 'Libramiento Naciones Unidas, #1809, Col. Agronomo, Ciudad Victoria, Tamaulipas, México, 87025, entre contra esq. Articulo 1', 23.7697561, -99.1232227, 130),
(426, 2, '50C8A', 'Privanzas Maf', 'Libramiento Naciones Unidas, #M-1 L-16 y 17, Col. Fraccionamiento Privanzas 2, Ciudad Victoria, Tamaulipas, México, 87024, entre Santa martha y Articulo 31', 23.7657374, -99.1171783, 130),
(427, 2, '50DWQ', 'Nuevo Padilla II Maf', 'Carretera Victoria-Matamoros, #S/N, Col. Nueva Villa De Padilla, Padilla, Tamaulipas, México, 87780, entre Km. 47+400', 24.0579771, -98.8909636, 130),
(428, 2, '50JJZ', 'Jimenez II Maf', 'Carretera Victoria-Matamoros, #S/N, Col. Santander Jimenez, Jimenez, Tamaulipas, México, 87700, entre Km. 97', 24.2214690, -98.4928239, 130),
(429, 2, '50K4E', 'Guemez Centro Maf', 'Calle 9, #101, Col. Zona Centro, Guemez, Tamaulipas, México, 87230, entre Esquina Con Benito Juarez', 23.9185275, -99.0079688, 130),
(430, 2, '50N72', 'Servitrail Maf', 'Carretera Estatal Libre Monterrey - Zaragoza Km 79.5, #S/N, Col. Guemez, Guemez, Tamaulipas, México, 87230, entre Carretera', 23.8539470, -99.0554080, 130),
(431, 2, '50NPD', 'Nuevo Padilla Maf', 'Carretera Victoria-Matamoros, #S/N, Col. Padilla, Padilla, Tamaulipas, México, 87780, entre Km. 46', 24.0441753, -98.8978653, 130),
(432, 2, '50S7R', 'Azteca Maf', 'Calle 16 De Septiembre, #940, Col. Azteca, Ciudad Victoria, Tamaulipas, México, 87024, entre Esquina Con Ahuitzotl', 23.7447247, -99.1088034, 130),
(433, 2, '50T2X', 'Benito Sierra 1 Maf', 'Calle Benito Sierra, #28, Col. Zona Centro, Abasolo, Tamaulipas, México, 87760, entre Esquina 20 De Octubre', 24.0589274, -98.3725795, 130),
(434, 2, '50U2L', 'Padilla Centro Maf', 'Calle Hidalgo, #6, Col. Nueva Villa De Padilla, Padilla, Tamaulipas, México, 87780, entre Esq. Con Calle 3', 24.0501997, -98.9009642, 130),
(435, 2, '50V8G', 'Mirlos Maf', 'Vialidad Transversal Sur (Ing. Antonio C. Valdez B, #914, Col. Los Mirlos Residencial, Ciudad Victoria, Tamaulipas, México, 87084, entre Esquina Circuito Mirlos', 23.7711868, -99.1035538, 130),
(436, 2, '50VYB', 'Especialidades Maf', 'Libramiento Naciones Unidas, #3115, Col. Guadalupe Victoria, Ciudad Victoria, Tamaulipas, México, 87086, entre Esq. Con Aguila Azteca', 23.7615756, -99.1093386, 130),
(437, 2, '50XQZ', 'Pajaritos Maf', 'Avenida De Los Pajaritos, #1509, Col. Barrio De Los Pajaritos, Ciudad Victoria, Tamaulipas, México, 87086, entre Esq. Con Aguila Azteca', 23.7540720, -99.1065068, 130),
(438, 2, '50D83', 'Olivin Centro Maf', 'Carretera Federal 101 (Victoria-Matamoros), #5555, Col. Ejido el Olivo, Ciudad Victoria, Tamaulipas, Mexico, 87277, entre Esq. Con Calle sin Nombre', 23.7848040, -99.1001770, 130),
(439, 2, '50BBG', 'Cuartel Maf', 'Calle 77 Batallon De Infanteria, #2550, Col. Luis Donaldo Colosio , Ciudad Victoria, Tamaulipas, México, 87014, entre Esq. Con Calle 23 De Marzo', 23.7558731, -99.1738785, 130),
(440, 2, '500N0', 'Relaciones Exteriores Maf', 'Calle Hidalgo, #111 L1, Col. Zona Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Entre Francisco I Madero Y 5 De Mayo', 23.7321000, -99.1519000, 130),
(441, 2, '50QOL', '17 Y Juarez Maf', 'Calle Juarez, #101, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Con Francisco I. Madero ', 23.7307961, -99.1527349, 130),
(442, 2, '508UF', '33 Juarez Maf', 'Calle Juarez, #1615, Col. Miguel Aleman, Ciudad Victoria, Tamaulipas, México, 87030, entre Tulipan', 23.7306000, -99.1690000, 130),
(443, 2, '50ASH', 'Asent. Humanos Maf', 'Calle Contadores, #104, Col. Bernardo Gutierrez De Lara, Ciudad Victoria, Tamaulipas, México, 87160, entre Tecnicos Y Asentamientos Humanos', 23.7146451, -99.1616360, 130),
(444, 2, '50CP6', 'Lara Maf', 'Calle Sexta, #135, Col. Villa del Prado, Ciudad Victoria, Tamaulipas, México, 87078, entre esq. Privada Via Lactea y Alamo', 23.7238728, -99.1694974, 130),
(445, 2, '50DQF', '22 Rosales Maf', 'Calle Venustiano Carranza, #701, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Esq. Con Rosales', 23.7262927, -99.1578771, 130),
(446, 2, '50HBI', 'Paseo Mendez Maf', 'Calle Francisco I Madero, #850, Col. Zona Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Gutierrez De Lara Esquina', 23.7242275, -99.1536563, 130),
(447, 2, '50IKT', 'Tamatan Maf', 'Calle Calzada Gral. Luis Caballero, #127, Col. Del Maestro, Ciudad Victoria, Tamaulipas, México, 87070, entre Luis Castro Y Ramon Del Castillo', 23.7204631, -99.1650483, 130),
(448, 2, '50ISP', 'Americo Maf', 'Calle Ceferino Morales, #137, Col. Américo Villarreal , Ciudad Victoria, Tamaulipas, México, 87070, entre Graciano Sanchez Y Jose Luis Mora', 23.7185747, -99.1792393, 130),
(449, 2, '50JZY', 'Sierra Maf', 'Avenida Sierra Madre Oriental, #247, Col. Sierra Madre, Ciudad Victoria, Tamaulipas, México, 87037, entre Esq. Con Emilio Portes Gil', 23.7459046, -99.1722304, 130),
(450, 2, '50KMT', 'Del Maestro Maf', 'Calle Del Maestro, #118, Col. Del Maestro, Ciudad Victoria, Tamaulipas, México, 87070, entre Esq. Con Genaro Ruiz', 23.7216800, -99.1641660, 130),
(451, 2, '50MC0', 'Alvaro Obregon Maf', 'Libramiento Emilio Portes Gil, #760, Col. Altavista, Ciudad Victoria, Tamaulipas, México, 87078, entre Esquina Con Calle Doblado', 23.7259451, -99.1802320, 130),
(452, 2, '50N7H', 'Laurel Maf', 'Calle Laurel, #304, Col. America De Juarez, Ciudad Victoria, Tamaulipas, México, 87078, entre Esq. Privada Laurel ', 23.7271023, -99.1695991, 130),
(453, 2, '50NBQ', '7 De Noviembre Maf', 'Libramiento Emilio Portes Gil, #105, Col. Siete De Noviembre, Ciudad Victoria, Tamaulipas, México, 87070, entre 7 De Noviembre Y Altepetlalli', 23.7149300, -99.1781200, 130),
(454, 2, '50PA0', '32 Y Matamoros Maf', 'Calle Matamoros, #1555, Col. Miguel Aleman, Ciudad Victoria, Tamaulipas, México, 87030, entre Esq. Calle Nardo', 23.7342098, -99.1690193, 130),
(455, 2, '50RW8', 'Casas Blancas 2 Maf', 'Calle Camino Del Pueblo, #332, Col. Unidad Modelo, Ciudad Victoria, Tamaulipas, México, 87160, entre Esquina Con Calle Ebano', 23.7092110, -99.1574290, 130),
(456, 2, '50TKE', 'Libramiento II Maf', 'Calle Matamoros, #2250, Col. Miguel Aleman, Ciudad Victoria, Tamaulipas, México, 87030, entre Libramiento Portes Gil Y Henequenal', 23.7338197, -99.1768403, 130),
(457, 2, '50U7A', 'Amalia G Maf', 'Calle Ciruela, #142, Col. Amalia G De Castillo Ledon, Ciudad Victoria, Tamaulipas, México, 87170, entre Esq. Con Alamo', 23.7078323, -99.1612522, 130),
(458, 2, '50UQX', 'Sierra Madre Maf', 'Calle Sierra San Carlos, #128, Col. Tamatan, Ciudad Victoria, Tamaulipas, México, 87060, entre Rio Corona', 23.7104842, -99.1806651, 130),
(459, 2, '50WSR', '28 Juarez Maf', 'Calle Juarez, #1036, Col. Heroe De Nacozari, Ciudad Victoria, Tamaulipas, México, 87030, entre Esquina Gabriel Saldivar', 23.7306691, -99.1632478, 130),
(460, 2, '50YIT', '22 Iturbide Maf', 'Calle Venustiano Carranza, #102, Col. Ciudad Victoria Centro, Ciudad Victoria, Tamaulipas, México, 87000, entre Hidalgo Y Juarez', 23.7320349, -99.1575894, 130),
(461, 2, '50NS8', '21 de Marzo Maf', ' , #, Col. , , , , , entre ', NULL, NULL, NULL),
(462, 2, '50K87', 'Villa Padilla Maf', ' , #, Col. , , , , , entre ', NULL, NULL, NULL),
(463, 3, '50AZQ', '14 Diagonal Maf', 'Calle Diagonal Cuahutemoc, #30, Col. San Francisco, Matamoros, Tamaulipas, México, 87350, entre Entre Calle 14 Y Leyes De Reforma', 25.8742047, -97.5103100, 132),
(464, 3, '50BIR', 'Laguna Salada Maf', 'Calle Ocho, #401, Col. Industrial, Matamoros, Tamaulipas, México, 87350, entre Esq. Con Laguna Salada', 25.8693195, -97.5052897, 132),
(465, 3, '50D98', 'Laguneta Maf', 'Calle 21, #1421, Col. Heroica Matamoros Centro, Heroica Matamoros, Tamaulipas, México, 87300, entre ', 25.8804160, -97.5183610, 132),
(466, 3, '50FXY', '8 Abasolo Maf', 'Calle Ocho, #125, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Abasolo', 25.8809935, -97.5066587, 132),
(467, 3, '50HYA', 'Ayala Maf', 'Calle Calixto Ayala, #142, Col. San Francisco, Matamoros, Tamaulipas, México, 87350, entre Esq. Con Calle 20', 25.8705779, -97.5171672, 132),
(468, 3, '50JZL', 'Centro Historico Maf', 'Avenida Gonzalez, #S/N, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Seis Y Siete', 25.8802397, -97.5049674, 132),
(469, 3, '50KDE', 'Teran Maf', 'Calle Cuatro, #35, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esq. Con Teran', 25.8748598, -97.5023051, 132),
(470, 3, '50KTV', 'Mercado Juarez Maf', 'Calle Diez, #919, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esquina Con Matamoros', 25.8815000, -97.5084000, 132),
(471, 3, '50NAQ', 'Laguna Jasso Maf', 'Avenida Sexta, #601, Col. Industrial, Matamoros, Tamaulipas, México, 87350, entre Esq. Con Laguna Jasso', 25.8674235, -97.5038458, 132),
(472, 3, '50NKV', '20 Y Gonzalez Maf', 'Calle Gonzalez, #1906, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esq. Con Calle 20', 25.8780361, -97.5166336, 132),
(473, 3, '50OTU', 'Triangulo Maf', 'Calle Catorce, #1093, Col. San Francisco, Matamoros, Tamaulipas, México, 87350, entre Esq.Con Calixto Ayala.', 25.8669576, -97.5106138, 132),
(474, 3, '50PAY', 'Plan De Ayutla Maf', 'Calle Calixto Ayala, #S/N, Col. Industrial, Matamoros, Tamaulipas, México, 87350, entre Esq. Con Plan De Ayutla', 25.8651374, -97.5047626, 132),
(475, 3, '50SGZ', 'Seguro Social Maf', 'Avenida Sexta, #97, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esq. Con Juarez', 25.8733180, -97.5044445, 132),
(476, 3, '50UCA', 'San Francisco Maf', 'Calle Dieciocho, #19, Col. San Francisco, Matamoros, Tamaulipas, México, 87350, entre Esq. Con Laguna Salada', 25.8690937, -97.5146428, 132),
(477, 3, '50UGZ', 'Gonzalez Maf', 'Calle Gonzalez, #S/N, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esq. Con Calle 13', 25.8791971, -97.5105856, 132),
(478, 3, '50UOM', 'Morelos Maf', 'Calle Catorce, #256, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esq. Con Morelos', 25.8783491, -97.5110264, 132),
(479, 3, '50UOV', 'Diagonal Y 20 Maf', 'Calle 20, #0, Col. San Francisco, Matamoros, Tamaulipas, México, 87350, entre Esq. Con Diagonal Cuahutemoc', 25.8759307, -97.5170314, 132),
(480, 3, '50USC', 'Canales Maf', 'Calle Canales, #S/N, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esq. Con Sexta', 25.8711667, -97.5036912, 132),
(481, 3, '50ZPZ', 'Plaza Allende Maf', 'Calle Morelos, #S/N, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esq. Con Calle 10', 25.8788759, -97.5079153, 132),
(482, 3, '50ZYU', 'Zaragoza Maf', 'Avenida Sexta, #202, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esq. Con Zaragoza', 25.8753260, -97.5040665, 132),
(483, 3, '502BE', 'Sat Maf', 'Calle Calixto Ayala, #300, Col. Control 3 Sur, Matamoros, Tamaulipas, México, 87340, entre Esquina Con Miguel Treviño', 25.8752000, -97.5203000, 132),
(484, 3, '50UOA', 'Aguila Maf', 'Carretera A Reynosa Km.1, #S/N, Col. San Rafael, Matamoros, Tamaulipas, México, 87340, entre Esq. Con Sendero Nacional', 25.8758764, -97.5253270, 132),
(485, 3, '505JL', 'Puente Viejo Maf', ' , #, Col. , , , , , entre ', 25.8864115, -97.5084126, 132),
(486, 3, '500OX', 'Brecha 119 Maf', 'Avenida Las Palmas, #1000, Col. Villa Satelite, Valle Hermoso, Tamaulipas, México, 87507, entre Esq. Con Calle Brecha 119', 25.6792000, -97.8257000, NULL),
(487, 3, '50MDW', 'Madero Maf', 'Avenida Lazaro Cardenas, #400, Col. Valle Hermoso Centro, Valle Hermoso, Tamaulipas, México, 87500, entre Esq. Con Madero', 25.6695698, -97.8156647, NULL),
(488, 3, '50DNS', 'Cardenas Maf', 'Avenida Lazaro Cardenas, #1, Col. Valle Hermoso Centro, Valle Hermoso, Tamaulipas, México, 87500, entre Esq. Con Aquiles Serdan', 25.6796949, -97.8163557, NULL),
(489, 3, '5000G', 'Alameda Maf', 'Calle Jose Vasconselos, #171 B, Col. Valle Hermoso Centro, Valle Hermoso, Tamaulipas, México, 87500, entre Esq. Calle Alameda', 25.6667990, -97.8171370, NULL),
(490, 3, '501TH', 'Paso Real Maf', 'Carretera San Fernando - Cd. Victoria, #1001, Col. Paso Real, San Fernando, Tamaulipas, México, 87606, entre Esq. Calle Jacaranda', 24.8404822, -98.1647229, NULL),
(491, 3, '506BJ', 'Rosalinda Guerrero Maf', 'Avenida Rosalinda Guerrero, #45, Col. Mexico, Valle Hermoso, Tamaulipas, México, 87503, entre Esquina Con Calle Cuarta', 25.6786581, -97.8099300, NULL),
(492, 3, '50805', '6 Y Juarez Maf', 'Calle Seis, #105, Col. Valle Hermoso Centro, Valle Hermoso, Tamaulipas, México, 87500, entre Esquina Con Juarez', 25.6721434, -97.8074142, NULL),
(493, 3, '50CHF', 'Chavez Maf', 'Calle Eduardo Chavez, #117, Col. Eduardo Chavez, Valle Hermoso, Tamaulipas, México, 87503, entre Esq. Blvd Luis Echeverria', 25.6664744, -97.8124667, NULL),
(494, 3, '50CHV', 'Echeverria Maf', 'Avenida Luis Echeverria A., #1, Col. Aurora, Valle Hermoso, Tamaulipas, México, 87504, entre Esq. Con Calle 12', 25.6670584, -97.8004320, NULL),
(495, 3, '50DBK', 'Dos De Abril Maf', 'Calle Juarez, #1574, Col. Valle Hermoso Centro, Valle Hermoso, Tamaulipas, México, 87500, entre Esq. Con Dos De Abril', 25.6720959, -97.8202719, NULL),
(496, 3, '50DZJ', '15 Y Juarez Maf', 'Calle 15, #S/N, Col. Soberon , Valle Hermoso, Tamaulipas, México, 87506, entre Esq. Con Juarez', 25.6720459, -97.7959015, NULL),
(497, 3, '50EUE', 'Echeverria III Maf', 'Carretera 82, #3902, Col. Colonia Olimpica, Valle Hermoso, Tamaulipas, México, 87504, entre Esq. Con Brecha 122', 25.6662950, -97.7963139, NULL),
(498, 3, '50GHE', 'Echeverria Iimaf', 'Calle Luis Echeverria Alvarez, #3125, Col. Foissste Eduardo Chavez, Valle Hermoso, Tamaulipas, México, 87504, entre Esq. Con Lucio Avalos', 25.6662598, -97.7841767, NULL),
(499, 3, '50HQW', 'Hidalgo Maf', 'Calle Hidalgo, #208, Col. Valle Hermoso Centro, Valle Hermoso, Tamaulipas, México, 87500, entre Calle Uno Y Calle Dos', 25.6729996, -97.8130822, NULL),
(500, 3, '50ICT', 'Castillo Maf', 'Avenida Ing. Santiago Guajardo, #S/N, Col. Valle Hermoso Centro, Valle Hermoso, Tamaulipas, México, 87500, entre Esq. Con Carretera 82', 25.6673187, -97.8256469, NULL),
(501, 3, '50KCS', 'Cardenas Ii Maf', 'Calle Brecha 120, #S/N, Col. Magueyes, Valle Hermoso, Tamaulipas, México, 87500, entre Km. 79+100', 25.6933696, -97.8152913, NULL),
(502, 3, '50L32', 'Cosme Santos Maf', 'Calle Cosme Santos, #102, Col. Tamaulipas, Valle Hermoso, Tamaulipas, México, 87507, entre Esq. Av. Santiago Guajardo', 25.6741884, -97.8259646, NULL),
(503, 3, '50Q58', 'Independencia Maf', 'Calle Miguel Hidalgo, #2002, Col. Gustavo Diaz Ordaz, Valle Hermoso, Tamaulipas, México, 87507, entre Esquina Con Brecha 118', 25.6733341, -97.8357356, NULL),
(504, 3, '50RLT', 'El Realito Maf', 'Carretera Estatal 99, #S/N, Col. El Realito, Valle Hermoso, Tamaulipas, México, 87520, entre Km. 80', 25.6670082, -97.8676961, NULL),
(505, 3, '50SFS', 'Los Fresnos Maf', 'Carretera Las Yescas, #2503, Col. Los Fresnos, Valle Hermoso, Tamaulipas, México, 87505, entre Carr.Las Yescas', 25.6512403, -97.8167147, NULL),
(506, 3, '50V6D', 'Brecha 82 Maf', 'Calle Brecha 82, #1256, Col. Ricardo Flores Magon, Valle Hermoso, Tamaulipas, México, 87506, entre Esq. Calle Miguel Hidalgo Y Costilla', 25.6665544, -97.8401282, NULL),
(507, 3, '50YME', 'America Maf', 'Calle Lazaro Cardenas, #1, Col. Valle Hermoso Centro, Valle Hermoso, Tamaulipas, México, 87500, entre Esq. Con America', 25.6754963, -97.8162888, NULL),
(508, 3, '50ZZZ', 'Cipres Maf', 'Carretera A San Fernando (Brecha 120), #S/N, Col. Ambrosio Ruiz, Valle Hermoso, Tamaulipas, México, 87505, entre Esq. Con Cipres', 25.6608093, -97.8153069, NULL),
(509, 3, '502GT', 'Lopez Mateos Maf', 'Calle Sexta, #7108, Col. Modelo, Valle Hermoso, Tamaulipas, México, 87503, entre Esq.Ignacio Aldama y Eva Samano', 25.6859207, -97.8075443, NULL),
(510, 3, '50L92', 'Soberon Maf', 'Carretera 82, #1122, Col. Soberon, Valle Hermoso, Tamaulipas, México, 87504, entre ', 25.6668511, -97.7892827, NULL),
(511, 3, '505UA', 'Las Rusias Maf', 'Carretera Matamoros - Rio Bravo, #4510, Col. Ejido Las Rusias, Heroica Matamoros, Tamaulipas, México, 87324, entre ', 25.9079320, -97.5518150, NULL),
(512, 3, '50BNK', 'Luicio Blanco Ii Maf', 'Carretera Matamoros-Reynosa, #S/N, Col. Lucio Blanco, Matamoros, Tamaulipas, México, 87444, entre Fco I. Madero Y Entronque A Autopista', 25.9359470, -97.7777460, NULL),
(513, 3, '50BYS', 'Las Brisas Maf', 'Avenida Las Brisas, #02, Col. Paseo De Las Brisas, Matamoros, Tamaulipas, México, 87313, entre Laguna De Alvarado Y Bahia De Chetumal', 25.8643968, -97.5568631, NULL),
(514, 3, '50DEW', 'Sendero Iii Maf', 'Carretera Sendero Nacional Km 6.5, #S/N, Col. Los Arados, Matamoros, Tamaulipas, México, 87560, entre Esq. Con Libramiento Emilio Portes Gil', 25.8637758, -97.5778104, NULL),
(515, 3, '50EIB', 'El Capote Maf', 'Carretera Matamoros-Reynosa, #S/N, Col. San Fructuoso , Matamoros, Tamaulipas, México, 87300, entre Km. 21.5', 25.9716305, -97.6962433, NULL),
(516, 3, '50HWC', 'Anahuac Maf', 'Carretera Valle Hermoso-El Empalme Km 70, #S/N, Col. Anahuac, Valle Hermoso, Tamaulipas, México, 87510, entre Km. 70', 25.7754468, -97.7955433, NULL),
(517, 3, '50J3R', 'Anahuac Centro Maf', 'Carretera Valle Hermoso Matamoros, #567, Col. Anahuac, Valle Hermoso, Tamaulipas, México, 87510, entre ', 25.7750744, -97.7773583, NULL),
(518, 3, '50JZI', 'Las Brisas 3 Maf', 'Calle Brisas Del Valle, #S/N, Col. Brisas Del Valle , Matamoros, Tamaulipas, México, 87313, entre Esq. Con Mar Muerto', 25.8648523, -97.5634755, NULL);
INSERT INTO `tienda` (`id`, `plaza_id`, `codigo`, `nombre`, `direccion`, `latitud`, `longitud`, `asesor_ti_usuario_id`) VALUES
(519, 3, '50QOO', 'Lucio Blanco Maf', 'Carretera Matamoros-Reynosa, #S/N, Col. Lucio Blanco, Matamoros, Tamaulipas, México, 87444, entre Km. 32', 25.9543622, -97.7686236, NULL),
(520, 3, '50T77', 'Inteva Maf', 'Avenida Michigan, #100 A, Col. Parque Industrial Finsa Del Norte, Heroica Matamoros, Tamaulipas, México, 87316, entre ', 25.8829600, -97.5470270, NULL),
(521, 3, '50TBO', 'Tres Moras Maf', 'Carretera Sendero Nacional, #S/N, Col. Los Arados, Matamoros, Tamaulipas, México, 87560, entre Km. 6.5', 25.8623141, -97.5870360, NULL),
(522, 3, '50WKI', 'Los Presidentes Maf', 'Avenida Los Presidentes, #1, Col. Los Presidentes, Matamoros, Tamaulipas, México, 87413, entre Esq. Virgilio Garza', 25.8582205, -97.5836204, NULL),
(523, 3, '50XFN', 'Las Brisas Ii Maf', 'Calle Laguna De Las Brisas, #43, Col. Paseo De Las Brisas, Matamoros, Tamaulipas, México, 87313, entre Lag. De San Jorge Y Lag. De San Hipolito', 25.8581656, -97.5594262, NULL),
(524, 3, '50YHF', 'Empalme Maf', 'Carretera Matamoros-Rio Bravo, #S/N, Col. Empalme, Valle Hermoso, Tamaulipas, México, 87511, entre Km. 42', 25.9054743, -97.8430336, NULL),
(525, 3, '50060', 'Delphi Maf', 'Avenida Michigan, #S/N, Col. Del Norte, Matamoros, Tamaulipas, México, 87316, entre Av. Ohio Y Prolongacion Uniones', 25.8844850, -97.5529020, NULL),
(526, 3, '50423', 'El Caracol Maf', 'Avenida Caracol, #1, Col. El Caracol, Matamoros, Tamaulipas, México, 87313, entre Esquina Caracol De Luna', 25.8701168, -97.5657097, NULL),
(527, 3, '50A35', 'Santa Maria Maf', 'Carretera Matamoros-Reynosa Km. 3, #3001-A, Col. Del Valle, Matamoros, Tamaulipas, México, 87320, entre Interior Gasolinera', 25.8931190, -97.5327148, NULL),
(528, 3, '50BBH', 'Villa Del Parque Mam', 'Avenida Constituyentes, #58, Col. Villa Del Parque, Matamoros, Tamaulipas, México, 87315, entre Esq. Con Villa Esmeralda', 25.8786955, -97.5564572, NULL),
(529, 3, '50BIY', 'Ejido Los Arados Mam', 'Carretera Sendero Nacional, #km 2.0, Col. Los Arados, Matamoros, Tamaulipas, México, 87560, entre Siglo Xxi Y Las Brisas', 25.8687895, -97.5575422, NULL),
(530, 3, '50EBA', 'El Ebanito Maf', 'Carretera Matamoros Reynosa, #S/N, Col. El Ebanito, Matamoros, Tamaulipas, México, 87557, entre Km. 12.5', 25.9388959, -97.6200036, NULL),
(531, 3, '50EKE', 'Del Valle Maf', 'Calle Constituyentes, #64, Col. Recidencial Del Valle, Matamoros, Tamaulipas, México, 87415, entre Esq. Con Av. Las Palmas', 25.8733763, -97.5515080, NULL),
(532, 3, '50IBF', 'Uniones Maf', 'Avenida Uniones, #807, Col. Esperanza, Matamoros, Tamaulipas, México, 87310, entre Esq. Con Aguascalientes', 25.8870743, -97.5441336, NULL),
(533, 3, '50SFY', 'Sendero Ii Maf', 'Carretera Sendero Nacional, #S/N, Col. Los Arados, Matamoros, Tamaulipas, México, 87560, entre Km. 5', 25.8656493, -97.5721929, NULL),
(534, 3, '50SYN', 'Sendero I Maf', 'Calle Sendero Nacional, #234, Col. Los Arados, Matamoros, Tamaulipas, México, 87560, entre Esq. Con Niños Heroes', 25.8702000, -97.5521000, NULL),
(535, 3, '50UJD', 'Industrial Maf', 'Avenida De La Industria, #111, Col. Industrial Del Norte, Matamoros, Tamaulipas, México, 87316, entre Esq. Con Rigo Tovar', 25.8777303, -97.5284113, NULL),
(536, 3, '50XLF', 'Las Fuentes Maf', 'Calle Empleado Postal, #2, Col. Las Fuentes, Matamoros, Tamaulipas, México, 87317, entre Esq. Con San Pedro', 25.8890703, -97.5389486, NULL),
(537, 3, '50GGG', 'Brisas Del Valle Maf', 'Avenida Brisas Del Valle, #S/N, Col. Fracc. Palmares De Las Brisas, Matamoros, Tamaulipas, México, 87313, entre Esq. Con Puerto De Loreto', 25.8509000, -97.5621000, NULL),
(538, 3, '506GX', 'Diego Rivera Maf', 'Calle Diego Rivera, #2, Col. Fraccionamiento Lomas De San Juan, Matamoros, Tamaulipas, México, 87455, entre Esquina Con Celsa Cortez', 25.8233074, -97.4943356, NULL),
(539, 3, '50CAU', 'Curacao Maf', 'Avenida Marte R. Gomez, #S/N, Col. Expofiesta Oriente, Matamoros, Tamaulipas, México, 87398, entre Esq. Con Curacao', 25.8240191, -97.5060443, NULL),
(540, 3, '50GPL', 'Nicolas Guerra Maf', 'Calle Tercera, #6, Col. Melchor Ocampo, Matamoros, Tamaulipas, México, 87399, entre Esq. Con Nicolas Guerra', 25.8400810, -97.5011867, NULL),
(541, 3, '50II0', 'Jardines De San Juan Maf', 'Calle San Carlos, #4, Col. Jardines De San Juan, Matamoros, Tamaulipas, México, 87455, entre Esquina Con Calle San Juan Poniente', 25.8259000, -97.4829000, NULL),
(542, 3, '50IUX', 'El Saucito Mam', 'Calle Ignacio Zaragoza, #149, Col. El Saucito, Matamoros, Tamaulipas, México, 87453, entre Esq. Con Benito Juarez', 25.8377802, -97.4891973, NULL),
(543, 3, '50JD7', 'Expofiesta Oriente Maf', 'Calle San Fernando, #43, Col. Expofiesta Oriente, Matamoros, Tamaulipas, México, 87398, entre Esquina Con Plaza Sur', 25.8279375, -97.5050085, NULL),
(544, 3, '50JZD', 'Juarez Ii Maf', 'Calle Placido Domingo, #69, Col. Santa Cecilia, Matamoros, Tamaulipas, México, 87456, entre Esq. Con Emiliano Zapata', 25.8421445, -97.4901690, NULL),
(545, 3, '50JZH', 'San Miguel Maf', 'Avenida San Miguel, #41, Col. San Miguel, Matamoros, Tamaulipas, México, 87453, entre Santa Martha Y Santa Lucia', 25.8288729, -97.4814801, NULL),
(546, 3, '50LTR', 'Las Torres Maf', 'Calle Tercera, #S/N, Col. Villa Las Torres, Matamoros, Tamaulipas, México, 87398, entre Esq. Con Torre De Pisa', 25.8215993, -97.5053833, NULL),
(547, 3, '50MJN', 'San Juan Maf', 'Avenida Diego Rivera, #71, Col. San Juan, Matamoros, Tamaulipas, México, 87446, entre Esq. Con Loma Prieta', 25.8241887, -97.4900686, NULL),
(548, 3, '50NDN', 'Del Nino Maf', 'Avenida Del Ninio, #2011, Col. Veinte De Noviembre, Matamoros, Tamaulipas, México, 87390, entre Heroes Del 47 Y Jesus Mejia', 25.8363471, -97.4979733, NULL),
(549, 3, '50SFN', 'San Fernando Maf', 'Avenida Del Ninio, #2, Col. Veinte De Noviembre, Matamoros, Tamaulipas, México, 87390, entre Esq. Con Lauro Rangel', 25.8336445, -97.4990391, NULL),
(550, 3, '50SJP', 'Solidaridad Ii Maf', 'Boulevard Emilio Portes Gil, #3, Col. Periodistas, Matamoros, Tamaulipas, México, 87457, entre Esq. Con Solidaridad', 25.8453096, -97.4921666, NULL),
(551, 3, '50SLD', 'Solidaridad Maf', 'Avenida Solidaridad, #1, Col. Los Angeles, Matamoros, Tamaulipas, México, 87496, entre Angeles Y Serafines', 25.8484100, -97.4832260, NULL),
(552, 3, '50UBJ', 'Benito Juarez Maf', 'Calle Benito Juarez, #S/N, Col. San Juan, Matamoros, Tamaulipas, México, 87446, entre Esq. Con San Isidro', 25.8290533, -97.4878264, NULL),
(553, 3, '50UXJ', 'Lomas De San Juan Maf', 'Calle Benito Juarez, #S/N, Col. Fraccionamiento Lomas De San Juan, Matamoros, Tamaulipas, México, 87455, entre Esq. Francisco Zarco', 25.8301144, -97.4875399, NULL),
(554, 3, '50VVN', '20 Noviembre Maf', 'Calle Emiliano Zapata, #S/N, Col. Veinte De Noviembre, Matamoros, Tamaulipas, México, 87390, entre Esq. Con Natividad Lara', 25.8347045, -97.5031990, NULL),
(555, 3, '50WPR', 'Tampico Maf', 'Avenida Solidaridad, #4, Col. Tampico, Matamoros, Tamaulipas, México, 87457, entre Esq Con Calle Cd. Mante', 25.8443396, -97.4966665, NULL),
(556, 3, '50F4I', 'Nogalar Maf', 'Calle Rio Plata, #9, Col. Ampliacion Solidaridad, Matamoros, Tamaulipas, México, 87453, entre Rio Ramos', 25.8401416, -97.4818287, NULL),
(557, 3, '5003W', 'Tercera Maf', 'Calle Tercera, #1, Col. Satelite, Matamoros, Tamaulipas, México, 87458, entre Esquina Con Calle Virgo', 25.8494224, -97.5008485, NULL),
(558, 3, '50KJB', 'Satelite Maf', 'Calle Leo, #1, Col. Satelite, Matamoros, Tamaulipas, México, 87458, entre Av. Universidad Esquina', 25.8506462, -97.4960710, NULL),
(559, 3, '50UML', 'Longoria Maf', 'Avenida Longoria, #S/N, Col. Victoria, Matamoros, Tamaulipas, México, 87390, entre Esq. Con Tercera', 25.8478360, -97.5011535, NULL),
(560, 3, '5055Q', 'Benjamin Gaona Maf', 'Calle Jesus Ramirez, #30, Col. Esperanza Y Reforma, Matamoros, Tamaulipas, México, 87394, entre Esq Benjamin Gaona', 25.8062911, -97.5102308, NULL),
(561, 3, '50OSU', 'Suriname Maf', 'Avenida Del Niño, #S/N, Col. Azteca, Matamoros, Tamaulipas, México, 87398, entre Esq. Con Suriname', 25.8172354, -97.5052259, NULL),
(562, 3, '50ZMI', 'La Amistad Maf', 'Avenida Emilio Portes Gil, #S/N, Col. Luis Donaldo Colosio, Matamoros, Tamaulipas, México, 87394, entre Esq. Con Benjamin Gaona', 25.8117633, -97.5102396, NULL),
(563, 3, '50Z8B', 'Tianguis del Niño Maf', 'Calle Ignacio Zaragoza, #S/N, Col. San Fernando, Heroica Matamoros, Tamaulipas, México, 87456, entre Esq. Voluntad y Trabajo y Lib. Emilio Portes Gil', 25.8370527, -97.4954504, NULL),
(564, 3, '508DX', 'Electricistas Maf', ' , #, Col. , , , , , entre ', 25.8268948, -97.5006529, NULL),
(565, 3, '50182', 'Guadalupe Mainero Maf', 'Avenida Guadalupe Mainero, #37, Col. Revolucion Verde, Matamoros, Tamaulipas, México, 87445, entre Esq. Av. Gral. Lauro Villar (Matamoros - Playa Bagdad) y Vicente Barrera', 25.8529509, -97.4641130, 132),
(566, 3, '50ABD', 'Arboledas Maf', 'Boulevard Internacional, #201, Col. Las Arboledas, Matamoros, Tamaulipas, México, 87448, entre Esq. Con Encino', 25.8674941, -97.4720013, 132),
(567, 3, '50AQ1', 'Mainero Maf', 'Calle Guadalupe Mainero, #46, Col. Revolucion Verde, Matamoros, Tamaulipas, México, 87445, entre Genovevo De La O', 25.8542219, -97.4624098, 132),
(568, 3, '50AXJ', 'Alianza Maf', 'Avenida Canales, #1200, Col. Alianza, Matamoros, Tamaulipas, México, 87410, entre Es. Con Av. Del Maestro', 25.8658145, -97.4885009, 132),
(569, 3, '50CRE', 'Central Maf', 'Calle Canales, #S/N, Col. Modelo, Matamoros, Tamaulipas, México, 87360, entre Esq. Con Primera', 25.8709207, -97.4993979, 132),
(570, 3, '50IDZ', 'Alvaro Obregon Maf', 'Avenida Alvaro Obregon, #20, Col. Jardin, Matamoros, Tamaulipas, México, 87330, entre Esq. Ave De Las Rosas', 25.8904414, -97.5026883, 132),
(571, 3, '50JS8', 'El Laguito Maf', 'Avenida Universidad, #4, Col. Unidad Hogar, Matamoros, Tamaulipas, México, 87360, entre Esq. Con Jonh F Keneddy', 25.8650948, -97.4945081, 132),
(572, 3, '50MPO', 'Ocampo Maf', 'Calle Roberto F. Garcia, #S/N, Col. Lazaro Cardenas, Matamoros, Tamaulipas, México, 87360, entre Esq. Con Ocampo', 25.8714000, -97.4943731, 132),
(573, 3, '50NSF', 'Pumarejo Maf', 'Calle Canales, #1113, Col. Lazaro Cardenas, Matamoros, Tamaulipas, México, 87360, entre Esq. Con Roberto F. García', 25.8697065, -97.4958859, 132),
(574, 3, '50OEM', 'El Moro Maf', 'Calle Primera, #97, Col. Modelo, Matamoros, Tamaulipas, México, 87360, entre Esq. Con Pedernal', 25.8785551, -97.4995021, 132),
(575, 3, '50P8O', 'Del Cambio Maf', 'Calle Francisco Villa, #S/N, Col. Alianza, Matamoros, Tamaulipas, México, 87410, entre Esq. Calle Mercurio', 25.8648706, -97.4845455, 132),
(576, 3, '50PMA', 'Primera Maf', 'Calle Primera, #S/N, Col. Matamoros Centro, Matamoros, Tamaulipas, México, 87300, entre Esq. Con Gonzalez', 25.8813878, -97.4991900, 132),
(577, 3, '50SQC', 'San Carlos Maf', 'Avenida Lauro Villar, #S/N, Col. Alianza, Matamoros, Tamaulipas, México, 87410, entre Esq. San Carlos', 25.8677649, -97.4853679, 132),
(578, 3, '50UDN', 'Division Del Norte Maf', 'Avenida Division Del Norte, #S/N, Col. Ampliacion Guillermo Guajardo, Matamoros, Tamaulipas, México, 87447, entre Esq. Con 22 De Julio', 25.8628409, -97.4718844, 132),
(579, 3, '50UGO', 'Gobernacion Maf', 'Avenida Division Del Norte, #S/N, Col. Las Palmas, Matamoros, Tamaulipas, México, 87420, entre Esq. Con Gobernación', 25.8708876, -97.4866349, 132),
(580, 3, '50UOJ', 'Jardin Maf', 'Avenida De Las Rosas, #61, Col. Jardin, Matamoros, Tamaulipas, México, 87330, entre Esq. Con Primera', 25.8936686, -97.4991829, 132),
(581, 3, '50UOL', 'Lauro Villar Maf', 'Calle Lauro Villar, #S/N, Col. Popular, Matamoros, Tamaulipas, México, 87460, entre Esq. Con Marte R.Gomez', 25.8625951, -97.4784878, 132),
(582, 3, '50UOR', 'Rio Maf', 'Calle Rep. De Cuba, #1, Col. Rio, Matamoros, Tamaulipas, México, 87360, entre Esq. Con Acapulco', 25.8788409, -97.4939856, 132),
(583, 3, '50URR', 'Arrese Maf', 'Calle Lauro Villar, #S/N, Col. Delicias, Matamoros, Tamaulipas, México, 87360, entre Esq. Con Jose Arrese', 25.8716804, -97.4898841, 132),
(584, 3, '50VPA', 'Las Palmas Maf', 'Avenida Division Del Norte, #S/N, Col. Doctores, Matamoros, Tamaulipas, México, 87448, entre Esq. Con Prol. Fco. Villa', 25.8686324, -97.4812072, 132),
(585, 3, '50XWF', 'Imss Maf', 'Avenida Lauro Villar, #S/N, Col. Puertas Verdes, Matamoros, Tamaulipas, México, 87449, entre Esq. Con Efrain Ruiz', 25.8608945, -97.4750444, 132),
(586, 3, '50A2A', 'Molino Del Rey 2 Maf', 'Boulevard Molino Del Rey, #53, Col. Molino Del Rey, Matamoros, Tamaulipas, México, 87343, entre Esq Calle 7', 25.8501000, -97.5865000, 132),
(587, 3, '50A4S', 'Arecas Maf', 'Calle Paseo Arecas, #177, Col. Arecas, Matamoros, Tamaulipas, México, 87413, entre Lavanda', 25.8436912, -97.5930637, 132),
(588, 3, '50JZK', 'Molino Del Rey Maf', 'Avenida Reyes Catolicos, #S/N, Col. Molino Del Rey, Matamoros, Tamaulipas, México, 87343, entre Esquina Con Carlos V', 25.8459892, -97.5849913, 132),
(589, 3, '50WPP', 'Pueblitos Maf', 'Boulevard Pueblitos, #1, Col. Pueblitos, Matamoros, Tamaulipas, México, 87350, entre Esq. Con Zacatecas', 25.8224103, -97.5813562, 132),
(590, 3, '50T5W', 'Washington Maf', 'Calle Washington, #S/N, Col. Modelo, Heroica Matamoros, Tamaulipas, México, 87360, entre Esq. Costa Rica', 25.8746620, -97.4959934, 132),
(591, 3, '506ZG', 'Nuevo Milenio Maf', 'Calle Universidad Autonoma De Nuevo Leon, #35, Col. Nuevo Milenio, Matamoros, Tamaulipas, México, 87347, entre Esq Colegio De Ingenieros Municipales', 25.8555361, -97.5424015, NULL),
(592, 3, '509CO', 'Porfirio Diaz Maf', 'Calle Adolfo Ruiz Cortinez, #100, Col. Emilio Portes Gil, Matamoros, Tamaulipas, México, 87340, entre Esquina Con Porfirio Diaz', 25.8670000, -97.5278000, NULL),
(593, 3, '50ACI', 'Acuario Maf', 'Calle Leyes De Reforma, #S/N, Col. Acuario 2001, Matamoros, Tamaulipas, México, 87344, entre Esq. Con Calle 31', 25.8625932, -97.5288622, NULL),
(594, 3, '50COW', 'Constituyentes Maf', 'Avenida Constituyentes, #213, Col. Casa Blanca, Matamoros, Tamaulipas, México, 87345, entre Marruecos Y Pakistan', 25.8626046, -97.5421662, NULL),
(595, 3, '50CSA', 'Casa Blanca Maf', 'Calle Gilbraltar, #S/N, Col. Casa Blanca, Matamoros, Tamaulipas, México, 87345, entre Esq. Con Marruecos', 25.8613689, -97.5408033, NULL),
(596, 3, '50DQY', 'Mexicali Maf', 'Avenida Mexicali, #13, Col. Paseo Residencial , Matamoros, Tamaulipas, México, 87380, entre Esq. Con Paseo Naranjo', 25.8497545, -97.5205418, NULL),
(597, 3, '50F3Z', 'Rigo Tovar Maf', 'Avenida Rigo Tovar, #187, Col. Francisco Villa Sur, Matamoros, Tamaulipas, México, 87349, entre Las Palmas Y Canada', 25.8748053, -97.5307469, NULL),
(598, 3, '50JYE', 'Villa Azteca Maf', 'Calle Mariano Matamoros, #S/N, Col. Villa Azteca , Matamoros, Tamaulipas, México, 87383, entre Izcoatl Y Tepochcalli', 25.8453120, -97.5210421, NULL),
(599, 3, '50LXF', 'Leyes De Reforma Maf', 'Calle Leyes De Reforma, #S/N, Col. Santa Elena, Matamoros, Tamaulipas, México, 87340, entre Esq. Calle 27', 25.8624528, -97.5233816, NULL),
(600, 3, '50MFU', 'Magisterio Maf', 'Avenida 12 De Marzo, #S/N, Col. Paseo Del Magisterio 3 , Matamoros, Tamaulipas, México, 87344, entre Pedro De Alvarado Y Hernan Cortes', 25.8568356, -97.5302717, NULL),
(601, 3, '50MYV', '12 De Marzo Maf', 'Avenida 12 De Marzo, #S/N, Col. Jose Lopez Portillo, Matamoros, Tamaulipas, México, 87348, entre Sendero Nacional Y Barcelona', 25.8699663, -97.5373839, NULL),
(602, 3, '50OEG', 'Egipto Maf', 'Calle Mohamed, #S/N, Col. Casa Blanca, Matamoros, Tamaulipas, México, 87345, entre Libano Y Egipto', 25.8642923, -97.5447542, NULL),
(603, 3, '50QEN', 'Quinta Real Maf', 'Avenida 12 De Marzo, #S/N, Col. Quinta Real., Matamoros, Tamaulipas, México, 87345, entre Esq. Boulevard Casablanca', 25.8584111, -97.5305841, NULL),
(604, 3, '50SFW', 'San Felipe Maf', 'Avenida Villarreal, #S/N, Col. Jardines De San Felipe, Matamoros, Tamaulipas, México, 87347, entre Doña Alicia Y Don Felix', 25.8512689, -97.5399623, NULL),
(605, 3, '50UOP', 'Puerto Rico Maf', 'Calle Puertorico, #S/N, Col. Puerto Rico, Matamoros, Tamaulipas, México, 87344, entre Esq. Con Principe De Asturias', 25.8523929, -97.5285052, NULL),
(606, 3, '50URF', 'San Rafael Maf', 'Calle Albino Hernandez, #S/N, Col. San Rafael, Matamoros, Tamaulipas, México, 87340, entre Manuel Cavazos Lerma Y Leyes De Reforma', 25.8697046, -97.5228201, NULL),
(607, 3, '50VWR', 'Valle Real Maf', 'Avenida Constituyentes, #S/N, Col. Valle Real, Matamoros, Tamaulipas, México, 87345, entre Esq. Con Av. Valle Real', 25.8530343, -97.5335801, NULL),
(608, 3, '50ZDK', 'Quinta Real 2 Maf', 'Avenida Casa Blanca, #202, Col. Quinta Real., Matamoros, Tamaulipas, México, 87345, entre Esq. Con Reyes Catolicos', 25.8585590, -97.5354061, NULL),
(609, 3, '505YL', 'Crucero Sendero Maf', 'Avenida Constituyentes, #2976, Col. Ignacio Zaragoza, Matamoros, Tamaulipas, México, 87314, entre esq. C. Sendero y C. 1', 25.8708135, -97.5492455, NULL),
(610, 3, '50MSI', 'Santa Anita Maf', 'Calle Santa Elena, #S/N, Col. Puerto Rico, Matamoros, Tamaulipas, México, 87344, entre Esq. Con Puerto De Alvarado', 25.8453974, -97.5350302, NULL),
(611, 3, '50QQM', 'Bagdad Maf', 'Calle Victoria, #62, Col. Bagdad, Matamoros, Tamaulipas, México, 87369, entre Esq. Con Constitución Del 57', 25.8418613, -97.5276694, NULL),
(612, 3, '50X92', 'Puerto Rico 2 Maf', 'Calle Calle San Juan, #S/N, Col. Puerto Rico, Heroica Matamoros, Tamaulipas, México, 87344, entre Esq. Avenida Viejo San Juan y Borinquen', 25.8502849, -97.5319727, NULL),
(613, 3, '501DD', 'Bella Vista Sur', 'Calle Mariano Abasolo, #416, Col. Bellavista Sur, San Fernando, Tamaulipas, México, 87604, entre Esq. Calle Adolfo Lopez Mateos', 24.8423235, -98.1459179, NULL),
(614, 3, '503D1', 'Libramiento San Fer Maf', 'Carretera Victoria Matamoros Km 16, #835, Col. La Valentina, San Fernando, Tamaulipas, México, 87602, entre Na', 24.8468955, -98.1082557, NULL),
(615, 3, '505DK', 'Loma Alta Maf', 'Calle Simon Bolivar, #1357, Col. Loma Alta, San Fernando, Tamaulipas, México, 87605, entre Esq Con Calle Porfirio Diaz', 24.8556414, -98.1573260, NULL),
(616, 3, '505UT', 'Las Yescas Maf', 'Carretera 120, #100A, Col. Ejido El Llano, Valle Hermoso, Tamaulipas, México, 87500, entre Esq. Con Brecha 88', 25.6120010, -97.8165991, NULL),
(617, 3, '506VP', 'Padre Mier Maf', 'Calle Padre Mier, #402, Col. Bellavista Norte, San Fernando, Tamaulipas, México, 87602, entre Esq. Adolfo Lopez Mateos', 24.8502398, -98.1457973, NULL),
(618, 3, '50E7Y', 'Ignacio Allende Maf', 'Carretera a la Laguna, #S/N, Col. Tamaulipas, San Fernando, Tamaulipas, México, 87604, entre ', 24.8416660, -98.1321530, NULL),
(619, 3, '50I03', 'San German Maf', 'Carretera San Fernando - Matamoros, #S/N, Col. San German, San Fernando, Tamaulipas, México, 87610, entre Sc', 25.2048404, -97.9332291, NULL),
(620, 3, '50JZN', 'Moquetito Maf', 'Carretera Victoria - Matamoros, #S/N, Col. El Moquetito, Matamoros, Tamaulipas, México, 87580, entre Km 265', 25.5147110, -97.7329200, NULL),
(621, 3, '50MWZ', 'Bella Vista Maf', 'Carretera A La Laguna Madre, #1802, Col. Bellavista Norte, San Fernando, Tamaulipas, México, 87602, entre Esq. 250 Aniversario', 24.8444524, -98.1388264, NULL),
(622, 3, '50NRW', 'Las Norias Maf', 'Carretera Matamoros-Victoria, #S/N, Col. Las Norias, San Fernando, Tamaulipas, México, 87622, entre Km. 141+500', 24.6994295, -98.2632958, NULL),
(623, 3, '50NXE', 'Ruiz Cortinez Maf', 'Calle Ruiz Cortinez, #401, Col. San Fernando Centro, San Fernando, Tamaulipas, México, 87600, entre Esq. Padre Mier', 24.8508859, -98.1534792, NULL),
(624, 3, '50QKJ', 'Plaza Maf', 'Calle Escandon, #201, Col. San Fernando Centro, San Fernando, Tamaulipas, México, 87600, entre Esq. Allende', 24.8475708, -98.1601975, NULL),
(625, 3, '50QW7', 'Carretera San Fernando Maf', 'Carretera Victoria-Matamoros, #1101, Col. Loma Alta, San Fernando, Tamaulipas, México, 87605, entre Esq Calle Pemex', 24.8593651, -98.1418532, NULL),
(626, 3, '50RJO', 'Rancho Viejo Maf', 'Carretera Victoria-Matamoros, #S/N, Col. La Loma, San Fernando, Tamaulipas, México, 87610, entre Km. 202', 25.0661093, -98.0700480, NULL),
(627, 3, '50RYI', '2Do Centenario Maf', 'Avenida Segundo Centenario, #602, Col. San Fernando Centro, San Fernando, Tamaulipas, México, 87600, entre Esq. Genaro Cortinas', 24.8527741, -98.1556531, NULL),
(628, 3, '50TUU', 'Ruiz Cortinez Ii Maf', 'Avenida Ruiz Cortinez, #101, Col. San Fernando Centro, San Fernando, Tamaulipas, México, 87600, entre Esq, Con Hidalgo', 24.8477478, -98.1540175, NULL),
(629, 3, '50XLJ', 'Loma Colorada Maf', 'Carretera San Fernando-Playa Carbonera, #3304, Col. Tamaulipas, San Fernando, Tamaulipas, México, 87604, entre Tula Y Xicotencatl', 24.8380492, -98.1237541, NULL),
(630, 3, '50YNO', 'Pino Suarez Maf', 'Avenida Ignacio Allende, #502, Col. San Fernando Centro, San Fernando, Tamaulipas, México, 87600, entre Esq. Con Pino Suarez', 24.8474780, -98.1516211, NULL),
(631, 3, '506BY', 'Ignacio Allende 2 Maf', 'Calle Ignacio Allende, #874, Col. Bellavista Sur, San Fernando, Tamaulipas, México, 87604, entre Gomez Farias y Adolfo Lopez Mateos', 24.8467618, -98.1462925, NULL),
(632, 3, '50R1K', 'Juan de la Barrera Maf', 'Calle Juan de la Barrera, #S/N, Col. Bella Vista Sur, San Fernando, Tamaulipas, Mexico, 87604, entre Esq. Calle Adolfo Lopez Mateos', 24.8371240, -98.1463320, NULL),
(633, 3, '5017X', 'Las Culturas Maf', 'Avenida Las Culturas, #S/N, Col. Las Culturas, Matamoros, Tamaulipas, México, 87490, entre Esq. Calle Tarahumara', 25.8439650, -97.4554360, 132),
(634, 3, '503JN', 'Vancouver Maf', 'Calle Vancouver, #100, Col. Fraccionamiento Canada, Matamoros, Tamaulipas, México, 87493, entre Niagara Del Oeste', 25.8298000, -97.4248000, 132),
(635, 3, '50DCW', 'Canada Maf', 'Boulevard Niagara, #S/N, Col. Fraccionamiento Canada, Matamoros, Tamaulipas, México, 87493, entre Esq. Con Calle Otawa', 25.8340244, -97.4231346, 132),
(636, 3, '50ESC', 'Escandon Maf', 'Avenida Lauro Villar, #S/N, Col. Ciudad Industrial, Matamoros, Tamaulipas, México, 87494, entre Esq. Con Jose De Escandon', 25.8369178, -97.4369488, 132),
(637, 3, '50EUQ', 'Campestre Del Lago Maf', 'Avenida Lauro Villar, #S/N, Col. Villas Del Lago, Matamoros, Tamaulipas, México, 87444, entre Esq. Con Lago De Texcoco', 25.8427663, -97.4500007, 132),
(638, 3, '50FIW', 'Finsa Maf', 'Avenida Lauro Villar, #S/N, Col. Ciudad Industrial, Matamoros, Tamaulipas, México, 87499, entre Esq. Con Av. Las Lomas', 25.8359302, -97.4299393, 132),
(639, 3, '50FUI', 'Fue. Industrialesmaf', 'Avenida Lauro Villar, #S/N, Col. Fuentes Industriales, Matamoros, Tamaulipas, México, 87496, entre Esq. Con Av. Patriotismo', 25.8377665, -97.4433630, 132),
(640, 3, '50GV9', 'Ciudad Industrial Maf', 'Calle Lorenzo De La Garza, #38, Col. Ciudad Industrial, Matamoros, Tamaulipas, México, 87494, entre Esq. Con Oriente 2', 25.8392000, -97.4307000, 132),
(641, 3, '50IFX', 'Palmas De Mar Maf', 'Calle Camino Real, #120, Col. Palmas Del Mar, Matamoros, Tamaulipas, México, 87497, entre Palmares Y Costa Azul', 25.8228378, -97.4576106, 132),
(642, 3, '50MHX', 'Camino Real Maf', 'Avenida Camino Real, #65, Col. Las Americas, Matamoros, Tamaulipas, México, 87497, entre Sierra Ermitas Y Sierra Miquihuana', 25.8429566, -97.4580562, 132),
(643, 3, '50NU8', 'Fundadores Maf', 'Calle Teotihuacan, #201, Col. Fundadores, Matamoros, Tamaulipas, México, 87496, entre Esq. Con Dr. Miguel Barragan', 25.8351632, -97.4521290, 132),
(644, 3, '50SJW', 'San Jeronimo 2 Maf', 'Avenida Constitucion, #136, Col. San Jeronimo Residencial, Matamoros, Tamaulipas, México, 87493, entre Plan De Texcoco Y Batallon De San Patricio', 25.8286417, -97.4368724, 132),
(645, 3, '50SJX', 'San Jeronimo Maf', 'Avenida Hidalgo, #128, Col. Cima Iii, Matamoros, Tamaulipas, México, 87351, entre Esq. Fco Javier Mina', 25.8281214, -97.4344354, 132),
(646, 3, '50TEH', 'Teotihuacan Maf', 'Calle Teotihuacan, #108, Col. Tecnologico, Matamoros, Tamaulipas, México, 87490, entre Esq. Con Peten', 25.8307640, -97.4526476, 132),
(647, 3, '50UOY', 'Playa Maf', 'Avenida Lauro Villar, #S/N, Col. Las Culturas, Matamoros, Tamaulipas, México, 87490, entre Esq. Con Camino Real', 25.8467902, -97.4570711, 132),
(648, 3, '50UPV', 'Palo Verde Maf', 'Calle Camino Real, #S/N, Col. Las Culturas, Matamoros, Tamaulipas, México, 87490, entre Esq. Con Cerro Del Bernal', 25.8411107, -97.4577804, 132),
(649, 3, '50XCI', 'La Cima Maf', 'Calle Circuito Insurgentes, #S/N, Col. Hacienda La Cima, Matamoros, Tamaulipas, México, 87496, entre Esq. Con Plan De Iguala', 25.8332368, -97.4445116, 132),
(650, 3, '50XGZ', 'Magnolias Maf', 'Avenida Lauro Villar, #4435, Col. Privada Magnolias, Matamoros, Tamaulipas, México, 87445, entre Esq. Diego Rivera', 25.8496751, -97.4596750, 132),
(651, 3, '50YDK', 'Longoreno Maf', 'Carretera A La Playa, #S/N, Col. Longoreño, Matamoros, Tamaulipas, México, 87540, entre Km. 14.6 Predio San Juan O Chapeño', 25.8325859, -97.3735251, 132),
(652, 3, '50Z6S', 'Taxquena Maf', 'Calle Camino Real, #3, Col. Mexico, Matamoros, Tamaulipas, México, 87497, entre Esquina Calle Taxqueña', 25.8285000, -97.4575000, 132),
(653, 3, '50AZP', 'Realdelas Palmas Maf', 'Calle Paseo De Los Palmares, #98, Col. Palmares, Matamoros, Tamaulipas, México, 87313, entre Esq Con Real De Las Palmas', 25.8417824, -97.5542694, 132),
(654, 3, '50G9W', 'Palmares Norte Maf', 'Calle Real De Las Palmas, #79, Col. Los Palmares, Matamoros, Tamaulipas, México, 87347, entre Calle Aleutianas Y Calle Islas Virgenes', 25.8481334, -97.5539455, 132),
(655, 3, '50J3M', 'Tianguis Palmares Maf', 'Avenida Paseo De Las Palmas, #117A, Col. Ejido Cabras Pintas, Heroica Matamoros, Tamaulipas, México, 87343, entre ', 25.8369900, -97.5430900, 132),
(656, 3, '50LXP', 'Los Palmares Maf', 'Avenida Paseo Los Palmares, #S/N, Col. Los Palmares, Matamoros, Tamaulipas, México, 87347, entre Palma Sola Y Palma Divina', 25.8398115, -97.5478595, 132),
(657, 3, '50NE6', 'Paseo De Los Palmares Maf', 'Avenida Paseo De Los Palmares, #123, Col. Los Palmares, Matamoros, Tamaulipas, México, 87347, entre Esq. Con Sendero De Las Palmas', 25.8435188, -97.5595464, 132),
(658, 3, '508QZ', 'Popular Maf', 'Calle Fidencio Trejo, #S/N, Col. Popular, Heroica Matamoros, Tamaulipas, México, 87460, entre Antonio Martinez y Bernardo Gutierrez de Lara', 25.8511393, -97.4800842, 132),
(659, 3, '50YXC', 'Mexico Maf', 'Calle Reforma Sur, #8, Col. Mexico, Matamoros, Tamaulipas, México, 87497, entre Naucalpan Esquina', 25.8349909, -97.4618113, 132),
(660, 3, '50AIE', 'Emiliano Zapata Maf', 'Calle Emiliano Zapata, #75, Col. Benito Juarez, Matamoros, Tamaulipas, México, 87469, entre Esquina Francisco I Madero', 25.8439873, -97.4802976, 132),
(661, 3, '50AKV', 'Accion Civica Maf', 'Avenida Accion Civica, #S/N, Col. Nuevo Renacimiento, Matamoros, Tamaulipas, México, 87430, entre Lauro Villar Y Canales', 25.8630614, -97.4805664, 132),
(662, 3, '50AWC', 'Avellano Maf', 'Avenida Manuel Cavazos Lerma, #185, Col. Enrique Cardenas, Matamoros, Tamaulipas, México, 87450, entre Francisco Villa Y Av. Del Maestro', 25.8574158, -97.4896494, 132),
(663, 3, '50D8C', 'Alamo Maf', 'Calle Oceano Pacifico, #205, Col. El Saucito, Heroica Matamoros, Tamaulipas, México, 87453, entre ', 25.8341900, -97.4877200, 132),
(664, 3, '50EUV', 'Trevino Zapata Maf', 'Avenida Prolongacion Canales, #S/N, Col. Norberto Treviño Zapata, Matamoros, Tamaulipas, México, 87450, entre Esq. Con Accion Civica', 25.8618212, -97.4806404, 132),
(665, 3, '50KXW', 'Paraiso Maf', 'Avenida Tarahumara, #S/N, Col. Paraiso, Matamoros, Tamaulipas, México, 87475, entre Esq. Tratado De Libre Comercio', 25.8427154, -97.4705126, 132),
(666, 3, '50M5R', 'Republica de Argentina Maf', 'Calle Republica De Argentina, #124, Col. Vista Del Sol, Matamoros, Tamaulipas, México, 87497, entre Esq. Calle Costa De Marfil', 25.8371594, -97.4657845, 132),
(667, 3, '50MCF', 'Cantinflas Maf', 'Calle Mario Moreno Cantinflas, #S/N, Col. Norberto Treviño Zapata, Matamoros, Tamaulipas, México, 87450, entre Esq. Con Prolongacion Canales', 25.8599725, -97.4766154, 132),
(668, 3, '50MPP', 'Durazno Maf', 'Calle Durazno, #16, Col. La Amistad, Matamoros, Tamaulipas, México, 87475, entre Esq El Paseo', 25.8360098, -97.4703018, 132),
(669, 3, '50O0A', 'Oceano Pacifico Sur Maf', 'Avenida Oceano Pacifico, #S/N, Col. Solidaridad, Voluntad y Trabajo, Matamoros, Tamaulipas, México, 87456, entre entre Golfo de Mexico y Francisco Carbajal', 25.8349092, -97.4828988, 132),
(670, 3, '50OBR', 'Valle Verde Maf', 'Calle Declaracion De Principios, #25, Col. Valle Verde, Matamoros, Tamaulipas, México, 87477, entre Esq. Con Calle Cardenal', 25.8383686, -97.4780041, 132),
(671, 3, '50OL6', 'El Porvenir Maf', 'Calle Diagonal La Amistad, #11, Col. El Porvenir, Matamoros, Tamaulipas, México, 87477, entre Esquina Con Ebano', 25.8282000, -97.4755000, 132),
(672, 3, '50Q0N', 'Jilgueros Maf', 'Calle Jilgueros, #150, Col. 27 De Febrero, Matamoros, Tamaulipas, México, 87477, entre Esq. Con Aguila Real', 25.8347130, -97.4777331, 132),
(673, 3, '50SOY', 'Playa Sol Maf', 'Avenida Roberto Guerra, #128, Col. Playa Sol, Matamoros, Tamaulipas, México, 87470, entre Esq. Con Playa Mocambo', 25.8539599, -97.4750105, 132),
(674, 3, '50UOG', 'Guerra I Maf', 'Calle Roberto Guerra, #S/N, Col. Popular, Matamoros, Tamaulipas, México, 87460, entre Francisco Villa Y Callejon 6', 25.8608408, -97.4865622, 132),
(675, 3, '50UTR', 'Tarahumara Maf', 'Avenida Mario Moreno \"Cantinflas\", #S/N, Col. Praderas, Matamoros, Tamaulipas, México, 87470, entre Esq. Con Av. Tarahumara', 25.8485350, -97.4645443, 132),
(676, 3, '50WK3', 'Democracia Social Maf', 'Calle Democracia Social, #155, Col. Independencia, Heroica Matamoros, Tamaulipas, México, 87477, entre ', 25.8448867, -97.4759711, 132),
(677, 3, '50XTF', 'Roberto Guerra Maf', 'Avenida Roberto Guerra, #S/N, Col. Popular, Matamoros, Tamaulipas, México, 87460, entre Esq. Con Callejón 9', 25.8570171, -97.4792955, 132),
(678, 3, '50YZT', 'Playa Hornos Maf', 'Calle Playa Hornos, #24, Col. Lauro Villar, Matamoros, Tamaulipas, México, 87480, entre Esq Sierra Madre', 25.8475690, -97.4714162, 132),
(679, 3, '507UH', 'Las Palmitas Maf', ' , #, Col. , , , , , entre ', 25.8310511, -97.4690937, 132),
(680, 3, '50B9K', 'Portillo Maf', ' , #, Col. , , , , , entre ', 25.8718610, -97.5423800, 132),
(681, 3, '501XK', 'Mariano Matamoros Maf', 'Calle Abedul, #127, Col. Mariano Matamoros, Matamoros, Tamaulipas, México, 87380, entre Esquina Calle Cedro', 25.8535838, -97.5171595, 132),
(682, 3, '50AWW', 'Espana Maf', 'Calle España, #127, Col. Buenavista, Matamoros, Tamaulipas, México, 87350, entre Esq. Con Calle 14', 25.8625345, -97.5099804, 132),
(683, 3, '50DQE', '18 Y Espana Maf', 'Avenida España, #501, Col. Buenavista, Matamoros, Tamaulipas, México, 87350, entre Esq. Con Calle 18', 25.8627532, -97.5152991, 132),
(684, 3, '50DQQ', 'El Roble Maf', 'Avenida Manuel Cavazos Lerma, #6, Col. Mariano Matamoros, Matamoros, Tamaulipas, México, 87380, entre Esq. Con Calle El Roble', 25.8568059, -97.5131070, 132),
(685, 3, '50FD8', 'Carlos Salazar Maf', 'Calle Carlos Salazar, #S/N, Col. Victoria, Matamoros, Tamaulipas, México, 87390, entre Esq. Durango', 25.8522982, -97.5099409, 132),
(686, 3, '50FYT', 'Nafarrete Maf', 'Calle Sexta, #1301, Col. Euzkadi, Matamoros, Tamaulipas, México, 87370, entre Esq. Con Nafarrete', 25.8589764, -97.5042257, 132),
(687, 3, '50LPW', 'La Salle Maf', 'Calle Juventino Rosas, #39, Col. Vista Hermosa, Matamoros, Tamaulipas, México, 87370, entre Plan De Ayutla Y Calle 12', 25.8589181, -97.5074387, 132),
(688, 3, '50LTO', 'Valle Alto Maf', 'Calle Carlos Salazar, #2, Col. Valle Alto, Matamoros, Tamaulipas, México, 87380, entre Esq. Con Valle De Anahuac', 25.8481306, -97.5121054, 132),
(689, 3, '50Q9L', 'Carmen Serdan Maf', 'Calle Carmen Serdan, #2, Col. Jose Maria Morelos Y Pavon, Matamoros, Tamaulipas, México, 87459, entre Entre Calle Pisicis Y Calle Mar Caribe', 25.8533637, -97.4886076, 132),
(690, 3, '50QLC', 'Tlaxcala Maf', 'Calle Tercera, #311, Col. Moderno, Matamoros, Tamaulipas, México, 87380, entre Esq. Con Tlaxcala', 25.8543441, -97.5011843, 132),
(691, 3, '50RUO', 'La Aurora Maf', 'Calle Tercera, #7, Col. Aurora, Matamoros, Tamaulipas, México, 87370, entre Esq. Con Francisco I. Madero', 25.8593638, -97.5009491, 132),
(692, 3, '50SQW', 'Solernau Maf', 'Calle Solernau, #1000, Col. Aurora, Matamoros, Tamaulipas, México, 87370, entre Esq. Con Candido Aguilar', 25.8594860, -97.4949175, 132),
(693, 3, '50UVI', 'Vizcaya Maf', 'Calle Primera, #S/N, Col. Unidad Hogar, Matamoros, Tamaulipas, México, 87360, entre Esq. Con Vizcaya', 25.8649723, -97.4985405, 132),
(694, 3, '50XAD', 'Paseoresidencial Maf', 'Boulevard Manuel Cavazos Lerma, #71-A, Col. Paseo Residencial , Matamoros, Tamaulipas, México, 87380, entre Esquina Con Naranjo', 25.8587621, -97.5165153, 132),
(695, 3, '50XER', 'Periferico Maf', 'Boulevard Manuel C. Lerma, #S/N, Col. Veinte De Noviembre, Matamoros, Tamaulipas, México, 87450, entre Esq. Con Av.Del Maestro', 25.8566109, -97.4918255, 132),
(696, 3, '50XYV', 'Virgo Maf', 'Avenida Del Niño, #S/N, Col. Satelite, Matamoros, Tamaulipas, México, 87458, entre Esq. Con Virgo', 25.8506182, -97.4915524, 132),
(697, 3, '50Y52', 'Mediterraneo Maf', 'Boulevard Manuel Cavazos Lerma, #S/N, Col. Enrique Cardenas, Matamoros, Tamaulipas, México, 87450, entre Entre Mar Mediterraneo Y Leona Vicario', 25.8573751, -97.4853534, 132),
(698, 3, '501UA', 'Seccion 16 Maf', 'Calle Francisco Vaca, #43, Col. Seccion 16, Matamoros, Tamaulipas, México, 87390, entre Esq. Con Ponciano Arriaga', 25.8343732, -97.5194861, 132),
(699, 3, '50DQG', 'Agapito Gonzalez Maf', 'Avenida Agapito Gonzalez, #S/N, Col. Villa Esmeralda, Matamoros, Tamaulipas, México, 87396, entre Esq. Con Calle Agua Marina', 25.8340752, -97.5178910, 132),
(700, 3, '50FVN', 'Valle Dorado Maf', 'Avenida Carlos Salazar, #S/N, Col. Valle Dorado, Matamoros, Tamaulipas, México, 87382, entre Esq. Con Av. Del Trabajo', 25.8395689, -97.5127494, 132),
(701, 3, '50I79', 'Pedro Cardenas Maf', 'Avenida Sexta, #106, Col. Villa Madrid, Heroica Matamoros, Tamaulipas, México, 87390, entre ', 25.8403510, -97.5082130, NULL),
(702, 3, '50QFA', 'Santa Cecilia Maf', 'Avenida Pedro Cardenas, #3995, Col. Buenavista, Matamoros, Tamaulipas, México, 87390, entre Esq. Con Agapito Gonzalez', 25.8349051, -97.5100059, NULL),
(703, 3, '50UGI', 'Gimnasio Maf', 'Avenida Pedro Cardenas, #12, Col. Azteca, Matamoros, Tamaulipas, México, 87398, entre Esq. Con Ahuizotl', 25.8257958, -97.5130588, NULL),
(704, 3, '50UMN', 'Mundo Nuevo Maf', 'Avenida Pedro Cardenas, #S/N, Col. Azteca, Matamoros, Tamaulipas, México, 87398, entre Esq. Con Prolongacion Tercera', 25.8286254, -97.5117446, NULL),
(705, 3, '50UMZ', 'Mezquital Maf', 'Carretera Matamoros-Cd. Victoria, #S/N, Col. El Galaneño, Matamoros, Tamaulipas, México, 87560, entre Km. 18', 25.7159462, -97.5718876, NULL),
(706, 3, '50UOO', 'Rago Maf', 'Calle Pedro Cardenas, #S/N, Col. Las Granjas, Matamoros, Tamaulipas, México, 87390, entre Esq. Con 5 De Febrero', 25.8440681, -97.5077475, NULL),
(707, 3, '50WQX', 'Portes Gil  Maf', 'Avenida Pedro Cardenas, #S/N, Col. Ampliacion Buena Vista, Matamoros, Tamaulipas, México, 87394, entre Esq. Con Av. Emilio Portes Gil', 25.8109229, -97.5192036, NULL),
(708, 3, '50YJL', 'Misiones Maf', 'Avenida Marte R. Gomez, #S/N, Col. Hacienda Misiones, Matamoros, Tamaulipas, México, 87343, entre Esq. Con Canek', 25.8263878, -97.5416951, NULL),
(709, 3, '5006I', 'El Galañero Maf', 'Carretera a Cd Victoria Km 12, #12000, Col. El Galaneño, Heroica Matamoros, Tamaulipas, México, 87560, entre ', 25.7603619, -97.5451446, NULL),
(710, 3, '50AWU', 'Expo Fiesta Maf', 'Avenida Marte R. Gomez, #99, Col. Expofiesta Norte, Matamoros, Tamaulipas, México, 87396, entre Gloria Marin Y Tucan', 25.8267698, -97.5200817, NULL),
(711, 3, '50BAG', 'Voluntad y trabajo Mam', 'Calle Voluntad Y Trabajo, #40, Col. Voluntad Y Trabajo, Matamoros, Tamaulipas, México, 87390, entre Leon Guzman', 25.8328641, -97.5282452, NULL),
(712, 3, '50FBV', 'Fco I. Madero Maf', 'Calle Fco I. Madero, #24, Col. Francisco I Madero , Matamoros, Tamaulipas, México, 87395, entre Esq. Con Miguel Hidalgo', 25.8253578, -97.5268295, NULL),
(713, 3, '50HGQ', 'Marte R. Gomez Maf', 'Avenida Marte R. Gomez, #S/N, Col. Cabras Pintas, Matamoros, Tamaulipas, México, 87395, entre Esq. Con Luis Caballero', 25.8275596, -97.5315278, NULL),
(714, 3, '50IG0', 'Joaquin Pardave Maf', 'Calle Joaquin Pardave, #S/N, Col. Villa Coapa, Matamoros, Tamaulipas, México, 87395, entre Esq. Peter Ilich Tchaikovsky', 25.8238242, -97.5233188, NULL),
(715, 3, '50UMA', 'Aeropuerto Maf', 'Carretera A Cd. Victoria, #S/N, Col. Pdte Cardenas, Matamoros, Tamaulipas, México, 87550, entre Km. 7.5', 25.7822485, -97.5329835, NULL),
(716, 3, '50UOZ', 'Ragoz Maf', 'Carretera A Cd. Victoria, #S/N, Col. Expofiesta Sur, Matamoros, Tamaulipas, México, 87396, entre Km. 3.6', 25.8184326, -97.5172559, NULL),
(717, 3, '50XRT', 'Las Flores Maf', 'Calle Jose Luis Munguia, #48, Col. Las Flores, Matamoros, Tamaulipas, México, 87395, entre Esq. Con Fernando Montemayor', 25.8157007, -97.5237789, NULL),
(718, 3, '5025A', 'Virgilio Garza Maf', 'Calle Virgilio Garza, #48, Col. Voluntad Y Trabajo, Matamoros, Tamaulipas, México, 87390, entre Esq Calle 9A', 25.8331990, -97.5348540, NULL),
(719, 3, '50MJW', 'Misiones 2 Maf', 'Calle Cuba, #S/N, Col. Hacienda Misiones Ii, Matamoros, Tamaulipas, México, 87390, entre Marte R. Gomez Y Mexico', 25.8264500, -97.5562400, NULL),
(720, 3, '50WHT', 'Martha Rita Maf', 'Calle Profr. Fco. Montelongo Hernandez, #S/N, Col. Hacienda Misiones, Matamoros, Tamaulipas, México, 87343, entre Esq. Con Profra. Rosalia Sanchez C.', 25.8200437, -97.5471306, NULL),
(721, 3, '50YJG', '12 De Marzo 2 Maf', 'Avenida Marte R. Gomez, #S/N, Col. Hacienda Misiones, Matamoros, Tamaulipas, México, 87343, entre Esq. 12 De Marzo', 25.8271638, -97.5457944, NULL),
(722, 3, '50C4W', 'Aguas Subterraneas Maf', 'Avenida Solidaridad, #S/N, Col. Las Norias, Heroica Matamoros, Tamaulipas, México, 87390, entre ', 25.8438830, -97.5047266, NULL),
(723, 4, '506NE', 'Centenario Tam', 'Avenida Alvaro Obregon, #1200, Col. Obrera, Ciudad Madero, Tamaulipas, México, 89490, entre Esquina Independencia Y Centenario', 22.2400918, -97.8414735, NULL),
(724, 4, '50APH', 'Imss Tam', 'Boulevard Adolfo Lopez Mateos, #1000, Col. Esfuerzo Nacional, Ciudad Madero, Tamaulipas, México, 89470, entre Libertad Y Centenario', 22.2474150, -97.8548590, NULL),
(725, 4, '50CHT', 'Cuauhtemoc Tam', 'Avenida Cuauhtemoc, #2333, Col. Francisco Javier Mina, Tampico, Tamaulipas, México, 89110, entre Humbolt E Igualdad', 22.2402554, -97.8636529, NULL),
(726, 4, '50FGM', 'Frente Democratico Tam', 'Calle Rosalio Bustamante, #58, Col. Frente Democratico, Tampico, Tamaulipas, México, 89160, entre Educacion Y Triunfo', 22.2446823, -97.8579525, NULL),
(727, 4, '50HVH', 'Santo Nino Tam', 'Calle 16 De Septiembre Poniente, #1529, Col. Francisco I Madero, Ciudad Madero, Tamaulipas, México, 89480, entre Adolfo Lopez Mateos Y Sor Juana Ines De La Cruz', 22.2453497, -97.8551292, NULL),
(728, 4, '50QVW', 'Colonias Tam', 'Avenida Cuauhtemoc, #3001, Col. Primavera, Tampico, Tamaulipas, México, 89130, entre Guadalupe Mainero Y Pedro J. Mendez', 22.2453815, -97.8636680, NULL),
(729, 4, '50SIT', 'Central Tam', 'Calle Rosalio Bustamante, #206 SUR, Col. Esfuerzo Nacional, Ciudad Madero, Tamaulipas, México, 89470, entre Prolongacion Zapotal Y Jalisco', 22.2494830, -97.8579179, NULL),
(730, 4, '50TRO', 'Rosalio Tam', 'Calle Rosalio Bustamante, #116, Col. Esfuerzo Nacional, Ciudad Madero, Tamaulipas, México, 89470, entre Ej. Mexicano Y Prolong. Jalisco', 22.2521513, -97.8580968, NULL),
(731, 4, '50VR7', 'Zapotal Tam', 'Boulevard Adolfo Lopez Mateos, #801 SUR, Col. Esfuerzo Nacional, Ciudad Madero, Tamaulipas, México, 89470, entre Esq. Calle Zapotal Y Segunda Avenida', 22.2500977, -97.8551043, NULL),
(732, 4, '50NPC', 'Servando Canales Tam', 'Calle Salvador Diaz Miron, #512 OTE, Col. Tinaco, Ciudad Madero, Tamaulipas, México, 89590, entre Servando Canales Y Chihuahua', 22.2461520, -97.8324409, NULL),
(733, 4, '5072G', 'Victoria Tam', 'Boulevard Adolfo Lopez Mateos, #1301, Col. Guadalupe Mainero, Tampico, Tamaulipas, México, 89070, entre Esq. Victoria Y R. Bustamante', 22.2244000, -97.8493000, NULL),
(734, 4, '50AJH', 'Alameda Tam', 'Calle Heroes De Chapultepec, #1411, Col. Tamaulipas, Tampico, Tamaulipas, México, 89060, entre Laredo Y Bustamante', 22.2241485, -97.8445084, NULL),
(735, 4, '50ASA', 'Tula Tam', 'Calle Heroes De Chapultepec, #2114, Col. Tamaulipas, Tampico, Tamaulipas, México, 89060, entre Tula Y Felix U. Gomez', 22.2296865, -97.8419041, NULL),
(736, 4, '50AYN', 'Ayuntamiento Tam', 'Avenida Ayuntamiento, #507, Col. Americana, Tampico, Tamaulipas, México, 89190, entre Tercera Avenida Y Cuarta Avenida', 22.2319097, -97.8647640, NULL),
(737, 4, '50FH3', 'Simon Bolivar', 'Calle Heroes De Chapultepec, #2507, Col. Tamaulipas, Tampico, Tamaulipas, México, 89060, entre Esq. Aldama Y Abasolo', 22.2325060, -97.8401124, NULL),
(738, 4, '50GKT', 'Canseco Tam', 'Calle Dr Carlos Canseco, #801, Col. Del Pueblo, Tampico, Tamaulipas, México, 89190, entre Belisario Dominguez Y Jesus Elias Piña', 22.2235566, -97.8585613, NULL),
(739, 4, '50IMW', 'Volantin Tam', 'Calle Belisario Dominguez, #1001, Col. Del Pueblo, Tampico, Tamaulipas, México, 89190, entre Rosalio Bustamante Y Jesus Elias Piña', 22.2254171, -97.8629873, NULL),
(740, 4, '50VJP', 'Torreon Tam', 'Avenida Hidalgo, #612, Col. Cambell, Tampico, Tamaulipas, México, 89260, entre Torreon Y Calle Tampico', 22.2266188, -97.8648780, NULL),
(741, 4, '50Y5Z', 'Tampico Tam', 'Avenida Emilio Portes Gil, #1713, Col. Tamaulipas, Tampico, Tamaulipas, México, 89060, entre Esq. Camargo Y Xicotencatl', 22.2278275, -97.8462807, NULL),
(742, 4, '50YE9', 'Bella Vista Tam', 'Calle Lopez, #300, Col. Cambell, Tampico, Tamaulipas, México, 89260, entre Bella Vista Y Morelos', 22.2234953, -97.8649930, NULL),
(743, 4, '50ZMW', 'Metropolitano Tam', 'Boulevard Fidel Velazquez, #S/N, Col. Anahuac, Tampico, Tamaulipas, México, 89180, entre Azteca Y Ejido', 22.2293202, -97.8595322, NULL),
(744, 4, '5023U', 'Reforma Tam', 'Calle Ramos Arizpe, #708, Col. Obrera, Tampico, Tamaulipas, México, 89050, entre Esq. 16 De Septiembre Y Privada 5 De Febrero', 22.2427848, -97.8504512, NULL),
(745, 4, '50BTC', 'Tolteca Tam', 'Calle Zaragoza, #1607, Col. Tolteca, Tampico, Tamaulipas, México, 89160, entre Rosalio Bustamante Y Neptuno', 22.2361586, -97.8602541, NULL),
(746, 4, '50ENP', 'Rio Verde Tam', 'Boulevard Adolfo Lopez Mateos, #2601, Col. Obrera, Tampico, Tamaulipas, México, 89050, entre Emiliano Zapata Y Queretaro', 22.2376532, -97.8510503, NULL),
(747, 4, '50YZD', 'Obrera Tam', 'Calle Reforma, #507, Col. Obrera, Tampico, Tamaulipas, México, 89050, entre Sebastian Lerdo De Tejada Y Matamoros', 22.2391905, -97.8471824, NULL),
(748, 4, '50ELO', 'Leones Tam', 'Calle De Los Leones, #1121, Col. Colinas De Universidad, Tampico, Tamaulipas, México, 89138, entre Esquina Rosalio Bustamante', 22.2573028, -97.8570304, NULL),
(749, 4, '50GIC', 'Tecnologico Tam', 'Avenida 1Ro. De Mayo, #1610, Col. Ricardo Flores Magon, Ciudad Madero, Tamaulipas, México, 89460, entre Miguel Angel Y Justo Sierra', 22.2540458, -97.8489830, NULL),
(750, 4, '50OGO', 'Obregon Tam', 'Calle Francisco I Madero, #5118 sur, Col. Primero De Mayo, Ciudad Madero, Tamaulipas, México, 89450, entre Haiti Y Guayaquil', 22.2440902, -97.8388836, NULL),
(751, 4, '50PHW', 'Pachuca Tam', 'Calle Revolucion, #606, Col. Primero De Mayo, Ciudad Madero, Tamaulipas, México, 89450, entre Pachuca Y 18 De Marzo', 22.2465428, -97.8454973, NULL),
(752, 4, '50WPU', 'Libertad Tam', 'Calle Libertad, #102 OTE, Col. Arbol Grande, Ciudad Madero, Tamaulipas, México, 89490, entre Belisario Dominguez E Independencia', 22.2402058, -97.8400217, NULL),
(753, 4, '50WXC', 'Canaco Tam', 'Calle Durango, #415-C SUR, Col. Arbol Grande, Ciudad Madero, Tamaulipas, México, 89490, entre 20 De Noviembre Y Pedro J. Mendez', 22.2428598, -97.8363107, NULL),
(754, 4, '50ZJG', 'Los Mangos Tam', 'Calle Primero De Mayo, #1719, Col. Los Mangos, Ciudad Madero, Tamaulipas, México, 89440, entre Juventino Rosas Y Blvd Lopezmateos', 22.2551655, -97.8508869, NULL),
(755, 4, '505P0', 'Mercado Madero Tam', 'Calle Francisco I. Madero, #300, Col. Ciudad Madero Centro, Ciudad Madero, Tamaulipas, México, 89400, entre Ave. Monterrey Y Niños Heroes', 22.2490590, -97.8354170, NULL),
(756, 4, '509SJ', 'Via Monterrey', 'Calle Brasil, #107, Col. Vicente Guerrero, Ciudad Madero, Tamaulipas, México, 89580, entre Allende Y Alvaro Obregon', 22.2504311, -97.8353690, NULL),
(757, 4, '50A5F', 'Talleres Tam', 'Calle Servando Canales, #1310, Col. Benito Juarez Sur, Ciudad Madero, Tamaulipas, México, 89580, entre Honduras Y Canales', 22.2505723, -97.8272410, NULL),
(758, 4, '50ARV', 'Quintero Tam', 'Calle Necaxa, #300, Col. Lopez Portillo, Ciudad Madero, Tamaulipas, México, 89560, entre Quintero Y Ocotlan', 22.2612383, -97.8288592, NULL),
(759, 4, '50CMW', 'Civil Madero Tam', 'Calle Prolongacion Servando Canales, #2003, Col. Hidalgo Oriente, Ciudad Madero, Tamaulipas, México, 89570, entre Baja California', 22.2540943, -97.8216828, NULL),
(760, 4, '50DAY', '5 De Mayo Tam', 'Avenida Primero De Mayo, #316, Col. Ciudad Madero Centro, Ciudad Madero, Tamaulipas, México, 89400, entre 5 De Mayo Y Benito Juarez', 22.2486941, -97.8389068, NULL),
(761, 4, '50FIJ', 'Fraile Tam', 'Calle Ecatepec, #207, Col. Ciudad Madero Centro, Ciudad Madero, Tamaulipas, México, 89400, entre Esq.Francisco Sarabia', 22.2451753, -97.8359134, NULL),
(762, 4, '50GTE', 'Guatemala Tam', 'Calle Francisco I Madero, #1101, Col. Benito Juarez Sur, Ciudad Madero, Tamaulipas, México, 89580, entre Guatemala Y Honduras', 22.2530627, -97.8307192, NULL),
(763, 4, '50IKY', 'Leon Tam', 'Calle Francisco I Madero, #1407 NTE, Col. Hidalgo Poniente, Ciudad Madero, Tamaulipas, México, 89570, entre Leon Y Jaumave', 22.2554012, -97.8286744, NULL),
(764, 4, '50POM', '1o. De Mayo Tam', 'Calle Primero De Mayo, #1100, Col. Primero De Mayo, Ciudad Madero, Tamaulipas, México, 89450, entre Ramos Arizpe Y Saltillo', 22.2512252, -97.8436461, NULL),
(765, 4, '50SBA', 'Sarabia Tam', 'Calle Republica De Cuba, #201, Col. Primero De Mayo, Ciudad Madero, Tamaulipas, México, 89450, entre Sarabia Y Carranza', 22.2516958, -97.8474805, NULL),
(766, 4, '50TJB', 'Auditorio Tam', 'Calle Francisco Sarabia, #307 PTE., Col. Primero De Mayo, Ciudad Madero, Tamaulipas, México, 89450, entre 5 De Mayo Y Juarez', 22.2472613, -97.8398047, NULL),
(767, 4, '50XTN', 'Necaxa Tam', 'Calle Necaxa, #304, Col. Felipe Carrillo Puerto, Ciudad Madero, Tamaulipas, México, 89430, entre Bolivia Y Charro', 22.2516404, -97.8404364, NULL),
(768, 4, '50ZAX', 'Plaza Madero Tam', 'Avenida Primero De Mayo, #S/N, Col. Ciudad Madero Centro, Ciudad Madero, Tamaulipas, México, 89400, entre Allende Y Juarez', 22.2480483, -97.8374402, NULL),
(769, 4, '50DM3', 'Gas Sunoco Tam', 'Avenida Tamaulipas, #307 A-1 OTE , Col. Ampliacion Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre Esq. Insurgentes Y Alvaro Obregon', 22.2770598, -97.8416000, NULL),
(770, 4, '50HHJ', 'Ocampo Tam', 'Avenida Tamaulipas, #704 NTE, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre Melchor Ocampo Y Mariano Matamoros', 22.2770121, -97.8395734, NULL),
(771, 4, '50IQD', 'Insurgentes Tam', 'Avenida Cuauhtemoc, #600 OTE, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre Insurgentes Y Matamoros', 22.2754165, -97.8416257, NULL),
(772, 4, '50RIM', 'Miramar Tam', 'Avenida Tamaulipas, #S/N, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre Emilio Zapata E Insurgentes', 22.2767315, -97.8413156, NULL),
(773, 4, '50Y6Q', 'Brasil Maf', ' , #, Col. , , , , , entre ', 22.2527230, -97.8366264, NULL),
(774, 4, '50EM0', 'Kehoe Tam', 'Calle 13, #538, Col. Heriberto Kehoe, Ciudad Madero, Tamaulipas, México, 89510, entre Esquina Con Calle 34 Y Serapio Venegas', 22.2867000, -97.8363000, NULL),
(775, 4, '50YPV', 'Sahop Tam', 'Calle Adolfo Lopez Mateos, #400, Col. Candelario Garza, Ciudad Madero, Tamaulipas, México, 89500, entre Patrocinio Huerta Y Lauro Aguirre', 22.2814155, -97.8291812, NULL),
(776, 4, '508CF', 'Pakistan Tam', 'Calle Pakistan, #906, Col. Solidaridad, Voluntad Y Trabajo, Tampico, Tamaulipas, México, 89317, entre Japon Y Manuel Palafox', 22.3212131, -97.8553975, NULL),
(777, 4, '50HHP', 'Palafox Tam', 'Calle Palafox, #100, Col. Simon Rivera, Ciudad Madero, Tamaulipas, México, 89519, entre Calle Sin Nombre Y Cartamo', 22.3005726, -97.8441667, NULL),
(778, 4, '50I2V', 'Calle 7 Tam', 'Calle 7, #606 C, Col. Enrique Cardenas Gonzalez, Tampico, Tamaulipas, México, 89309, entre Calle F Y Calle E', 22.3036250, -97.8511802, NULL),
(779, 4, '50IKW', 'Borreguera Tam', 'Calle Ghana, #229, Col. Solidaridad, Voluntad Y Trabajo, Tampico, Tamaulipas, México, 89317, entre Camboya Y Afganistan', 22.3164998, -97.8592618, NULL),
(780, 4, '50RAK', 'Cardenas Tam', 'Calle 7, #1006, Col. Enrique Cardenas Gonzalez, Tampico, Tamaulipas, México, 89309, entre Novena Y Avenida', 22.3082190, -97.8494846, NULL),
(781, 4, '50TA9', 'Australia Tam', 'Calle Australia, #801, Col. Solidaridad, Voluntad Y Trabajo, Tampico, Tamaulipas, México, 89317, entre Esq. Calle India Y Manuel Palafox', 22.3115968, -97.8534100, NULL),
(782, 4, '50TH1', 'Juan Pablo II Tam', 'Calle Primavera, #308, Col. Enrique Cardenas Gonzalez, Tampico, Tamaulipas, México, 89309, entre Calle Cero Y Calle Dos', 22.3078944, -97.8560616, NULL),
(783, 4, '502MB', 'Burgos Tam', 'Calle David Manzanares, #101, Col. 18 De Marzo, Ciudad Madero, Tamaulipas, México, 89515, entre Campo San Andres Y Palafox', 22.2942939, -97.8514960, NULL),
(784, 4, '502YC', 'Nicolas Bravo Tam', 'Calle 5 De Mayo, #901 PTE, Col. Ampliacion Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre Esq. Nicolas Bravo Y Sor Juana Ines De La Cruz', 22.2863517, -97.8480276, NULL),
(785, 4, '504EC', 'Bujanos Tam', 'Calle Simon Castro, #601, Col. Luna Luna, Ciudad Madero, Tamaulipas, México, 89514, entre S Gutierez Y S. Castro', 22.2948053, -97.8454010, NULL),
(786, 4, '504KG', 'Las Chacas Tam', 'Avenida Monterrey, #1602, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre Camino Al Arenal Y Ave Monterrey', 22.2921267, -97.8529840, NULL);
INSERT INTO `tienda` (`id`, `plaza_id`, `codigo`, `nombre`, `direccion`, `latitud`, `longitud`, `asesor_ti_usuario_id`) VALUES
(787, 4, '50IKH', 'Lopez Portillo Tam', 'Calle Emiliano Zapata, #301, Col. Jose Lopez Portillo, Tampico, Tamaulipas, México, 89338, entre Felipe Angeles Y Felipe Angeles', 22.2944825, -97.8555456, NULL),
(788, 4, '50LUL', 'Luna Luna Tam', 'Calle Angel Gomez, #200, Col. Manuel R Diaz, Ciudad Madero, Tamaulipas, México, 89515, entre Ave. Monterrey Alberto Flores', 22.2901142, -97.8514780, NULL),
(789, 4, '50N7U', 'Lucio Blanco Tam', 'Calle Segunda, #636, Col. Blanco Sector Benito Juarez, Ciudad Madero, Tamaulipas, México, 89550, entre Calle 14 Y Calle 16', 22.2648740, -97.8340256, NULL),
(790, 4, '50OOT', 'Ampliacion II Tam', 'Calle Benito Juarez, #300, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre 5 De Mayo Y 1Ro. De Septiembre', 22.2850275, -97.8437371, NULL),
(791, 4, '50THR', 'Pescador Tam', 'Calle Felipe Pescador, #142 OTE, Col. Delfino Resendiz, Ciudad Madero, Tamaulipas, México, 89556, entre Urbano Juarez Y Primera', 22.2662122, -97.8369960, NULL),
(792, 4, '50WYR', 'Flores Tam', 'Calle Brigido Villasana, #402, Col. Manuel R Diaz, Ciudad Madero, Tamaulipas, México, 89515, entre Alberto Flores Y Serapio Venegas', 22.2906205, -97.8466264, NULL),
(793, 4, '50YNB', 'Campo Faja De Oro Tam', 'Calle Campo Arenque, #701, Col. 18 De Marzo, Ciudad Madero, Tamaulipas, México, 89515, entre Campo Viento Suave Y Campo Francita', 22.2989154, -97.8487652, NULL),
(794, 4, '501O5', 'La Perla Maf', 'Avenida Manuel Palafox, #312, Col. Solaridad, Voluntad y Trabajo, Tampico, Tamaulipas, México, 89317, entre esq. Colombia y Ceilan', 22.3147055, -97.8517789, NULL),
(795, 4, '5071I', 'Isauro Alfaro Tam', 'Calle Isauro Alfaro, #110, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Diaz Mirón Y Cesar Lopez De Lara', 22.2136982, -97.8541681, 133),
(796, 4, '50AMH', 'Isleta Tam', 'Calle Emilio Carrranza, #1201, Col. Tampico Centro, Tampico, Tamaulipas, México, 89000, entre Ignacio Zaragoza Y Altamira', 22.2122033, -97.8485310, 133),
(797, 4, '50EDK', 'Carranza Tam', 'Calle Emiliano Carranza, #316-A, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Benito Juarez Y Aduana', 22.2152704, -97.8557611, 133),
(798, 4, '50ENT', 'Centro Tam', 'Calle Salvador Diaz Miron, #1110, Col. Tampico Centro, Tampico, Tamaulipas, México, 89000, entre F.Andres De Olmos Y C. Colon', 22.2152705, -97.8580172, 133),
(799, 4, '50FV5', 'General San Martin Maf', 'Calle Gral. San Martín, #110, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre ', 22.2142575, -97.8519707, 133),
(800, 4, '50JWE', 'Zona Centro Tam', 'Calle Altamira, #118, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Colon Y 20 De Noviembre', 22.2173204, -97.8581850, 133),
(801, 4, '50KFI', 'Fiscal Tam', 'Calle Emilio Carranza, #619, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Aquiles Serdan E Isauro Alfaro', 22.2141516, -97.8529402, 133),
(802, 4, '50LAO', 'Centralita Tam', 'Calle Francisco I. Madero, #120 PTE, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre 20 De Noviembre Y Colon', 22.2150503, -97.8596108, 133),
(803, 4, '50N4D', 'Pedro J. Mendez Tam', 'Calle Pedro J. Mendez, #101, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Colon Y Fray Andres De Olmos', 22.2133113, -97.8584535, 133),
(804, 4, '50O4H', 'Aquiles Tam', 'Calle Alvaro Obregon, #700, Col. Tampico Centro, Tampico, Tamaulipas, México, 89000, entre Gral. San Martin Y Aquiles Serdán', 22.2155732, -97.8520500, 133),
(805, 4, '50OPW', 'El Chorro Tam', 'Calle Sor Juana Ines De La Cruz, #402 SUR, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre La Paz Y Pedro J. Mendez', 22.2146085, -97.8609575, 133),
(806, 4, '50TTI', 'Imperial Tam', 'Calle Cesar Lopez De Lara, #S/N, Col. Tampico Centro, Tampico, Tamaulipas, México, 89000, entre Diaz Miron Y E. Carranza', 22.2147545, -97.8545713, 133),
(807, 4, '50VWI', 'Diaz Miron Tam', 'Calle Salvador Diaz Miron, #402, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Aduana Y Cesar Lopez De Lara', 22.2141740, -97.8555030, 133),
(808, 4, '50XOP', 'Plaza Tam', 'Calle Aduana, #401-A, Col. Tampico Centro, Tampico, Tamaulipas, México, 89000, entre Heroes Del Cañonero Y Heroes De Nacozari', 22.2128017, -97.8567828, 133),
(809, 4, '50CYH', '2 De Enero Tam', 'Calle 2 De Enero, #400, Col. Tamaulipas, Tampico, Tamaulipas, México, 89060, entre Tamaulipas Y Heroes De Chapultepec', 22.2150315, -97.8482360, 133),
(810, 4, '50ESN', 'Escandon Tam', 'Calle Jose De Escandon, #614, Col. Del Pueblo, Tampico, Tamaulipas, México, 89190, entre Benito Juarez Y Fray Andres De Olmos', 22.2196332, -97.8542045, 133),
(811, 4, '50JKJ', 'Mainero Tam', 'Calle Emilio Portes Gil, #716, Col. Guadalupe Mainero, Tampico, Tamaulipas, México, 89070, entre Esq.Belisario Dominguez', 22.2195772, -97.8495296, 133),
(812, 4, '50OOG', 'Golfo Tam', 'Boulevard Portes Gil, #903, Col. Tamaulipas, Tampico, Tamaulipas, México, 89060, entre Jesus Elias Piña Y Volantin', 22.2204626, -97.8489580, 133),
(813, 4, '50SIW', 'Nautica Tam', 'Calle Adolfo Lopez Mateos, #901, Col. Guadalupe Mainero, Tampico, Tamaulipas, México, 89070, entre Jesus Elias Piña Y Volantin', 22.2212619, -97.8508814, 133),
(814, 4, '50UUV', 'Plaza Golfo Tam', 'Calle Jesus Elias Piña, #1301, Col. Guadalupe Victoria, Tampico, Tamaulipas, México, 89080, entre Aguascalientes Y Benito Juarez', 22.2179618, -97.8434409, 133),
(815, 4, '5058M', 'Alvaro Tam', 'Avenida Francisco I. Madero (Antes Alvaro Obregón), #2500, Col. Hipodromo, Ciudad Madero, Tamaulipas, México, 89560, entre Jimenez Y Mariano Matamoros', 22.2617348, -97.8209610, NULL),
(816, 4, '505Y9', 'Corredor Urbano Tam', 'Calle Corredor Urbano Luis Donaldo Colosio, #3000A, Col. Miramar, Ciudad Madero, Tamaulipas, México, 89540, entre Corredor Urbano Con Calle Tamaulipas', 22.2888478, -97.8140310, NULL),
(817, 4, '508R4', 'Jimenez Tam', 'Calle Jimenez, #201 Sur, Col. Adolfo Lopez Mateos, Ciudad Madero, Tamaulipas, México, 89520, entre Esq.Calle 10 Y Privada 10', 22.2753000, -97.8338000, NULL),
(818, 4, '50AEV', 'Maeva Tam', 'Calle Lote 10 Desarrollo Turistico Miramar, #S/N, Col. Miramar, Ciudad Madero, Tamaulipas, México, 89540, entre Plaza Gobernadores Fronterizos Y Terreno', 22.2868238, -97.8032004, NULL),
(819, 4, '50BEH', 'Real Del Mar Tam', 'Avenida Tamaulipas, #S/N, Col. Miramar, Ciudad Madero, Tamaulipas, México, 89540, entre Bolulevard Costero Y Callejon De Barriles', 22.2906150, -97.8095636, NULL),
(820, 4, '50EZL', 'Escolleras Tam', 'Boulevard Costero, #S/N, Col. La Barra, Ciudad Madero, Tamaulipas, México, 89540, entre Escolleas', 22.2640751, -97.7866984, NULL),
(821, 4, '50GZP', 'Nardos Tam', 'Avenida De Los Nardos, #819, Col. Las Flores, Ciudad Madero, Tamaulipas, México, 89510, entre Azucenas Y M. Montemayor', 22.2917995, -97.8368210, NULL),
(822, 4, '50HGM', 'Calle 15 Tam', 'Calle 15, #303, Col. Los Pinos, Ciudad Madero, Tamaulipas, México, 89513, entre Obras Sociales Y Calle 32', 22.2824745, -97.8348060, NULL),
(823, 4, '50HOO', 'Hipodromo Tam', 'Calle Jimenez, #700, Col. Hipodromo, Ciudad Madero, Tamaulipas, México, 89560, entre Necaxa', 22.2653073, -97.8246947, NULL),
(824, 4, '50ILQ', 'Barriles Tam', 'Calle Alvaro Obregon, #178, Col. Emilio Carranza, Ciudad Madero, Tamaulipas, México, 89540, entre Callejon De Barriles Y 16 De Septiembre', 22.2726202, -97.8040488, NULL),
(825, 4, '50LGS', '8 Leguas Tam', 'Avenida Tamaulipas, #400, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre Tercera Y Cuarta', 22.2768057, -97.8366885, NULL),
(826, 4, '50MAK', 'Miramapolis Tam', 'Calle Laguna Del Carpintero, #102, Col. Miramapolis, Ciudad Madero, Tamaulipas, México, 89506, entre Circuito Tamaulipeco Y Andador Jaiba I', 22.2935145, -97.8201829, NULL),
(827, 4, '50MWF', 'Mirador Tam', 'Calle Lote Num. 19, #406, Col. Miramar, Ciudad Madero, Tamaulipas, México, 89540, entre Zona De Miramar', 22.2698285, -97.7903473, NULL),
(828, 4, '50OUC', 'Tercera Avenida Tam', 'Calle Tercera Avenida, #1003, Col. Sahop, Ciudad Madero, Tamaulipas, México, 89506, entre Calle Primera Y Calle Segunda', 22.2855971, -97.8215139, NULL),
(829, 4, '50QX2', 'Francisco Villa Tam', 'Calle 21, #505, Col. Heroe De Nacozari, Ciudad Madero, Tamaulipas, México, 89520, entre Calle 50 Y Pedro J. Mendez', 22.2726238, -97.8275480, NULL),
(830, 4, '50RFI', 'Refineria Tam', 'Calle Francisco I Medero (Antes Alvaro Obregon), #1916 Nte, Col. Hidalgo Oriente, Ciudad Madero, Tamaulipas, México, 89570, entre Rhin Y Abasolo', 22.2583543, -97.8244919, NULL),
(831, 4, '50RTV', 'Recreativo II Tam', 'Calle Corredor Urbano Madero Altamira, #KM 3 + 750, Col. Corredor Urbano, Ciudad Madero, Tamaulipas, México, 89540, entre Dentro Gasolinera Servicio Libramiento', 22.3017841, -97.8166165, NULL),
(832, 4, '50RXA', 'Mar Tam', 'Boulevard Costero, #S/N, Col. Miramar, Ciudad Madero, Tamaulipas, México, 89540, entre Calle 2 Y Zona Forestada', 22.2797729, -97.7977554, NULL),
(833, 4, '50SRW', 'Sirenas Tam', 'Calle Alvaro Obregon, #100, Col. Miramar, Ciudad Madero, Tamaulipas, México, 89540, entre Boulevard Costero', 22.2753292, -97.7943555, NULL),
(834, 4, '50V3Z', 'Vela Maria Tam', 'Calle Corredor Urbano Madero Altamira Km 3.8 E,/ Corchos, #S/N, Col. Miramar, Ciudad Madero, Tamaulipas, México, 89540, entre A Un Costado De Gasolinera', 22.3037888, -97.8178030, NULL),
(835, 4, '50BXI', 'Arenal Tam', 'Calle Emiliano Zapata, #325, Col. Arenal, Tampico, Tamaulipas, México, 89344, entre Niños Heroes Y Privada Miguel Hidalgo', 22.2928132, -97.8773818, NULL),
(836, 4, '505ER', 'Torres Norte Tam', 'Avenida Las Torres Norte, #202, Col. Del Bosque, Tampico, Tamaulipas, México, 89318, entre Esq. Ebano Y Privada Naranjo', 22.3178000, -97.8764000, NULL),
(837, 4, '50AIC', 'Revolucion Verde Tam', 'Calle Sebastian Lerdo De Tejada, #318, Col. Revolucion Verde, Ciudad Madero, Tamaulipas, México, 89518, entre Independencia Y Margarita Maza De Juarez', 22.3176917, -97.8513481, NULL),
(838, 4, '50BKE', 'Del Bosque Tam', 'Calle Hidalgo, #2509, Col. Villa Hermosa, Tampico, Tamaulipas, México, 89319, entre Privada Villahermosa Y Divisoria', 22.3233451, -97.8762085, NULL),
(839, 4, '50DNY', 'Germinal Tam', 'Avenida Monterrey, #742, Col. Nuevo Rastro Municipal , Tampico, Tamaulipas, México, 89314, entre Ave Tamaulipas Y Nuevo Rastro Municipal', 22.3048498, -97.8584468, NULL),
(840, 4, '50DOQ', 'Pino Tam', 'Calle Ave Hidalgo, #1711, Col. Del Bosque, Tampico, Tamaulipas, México, 89318, entre Pino Y Privada Almendro', 22.3142830, -97.8790809, NULL),
(841, 4, '50GVI', 'Villahermosa Tam', 'Calle Sexta Avenida, #302, Col. Villa Hermosa, Tampico, Tamaulipas, México, 89319, entre Ave. Villahermosa Y Divisoria', 22.3216790, -97.8696383, NULL),
(842, 4, '50JFT', 'Josefa Ortiz Tam', 'Calle Josefa Ortiz, #611, Col. Laguna De La Puerta, Tampico, Tamaulipas, México, 89310, entre Sexta Avenida Y Calle 5Ta.', 22.3106220, -97.8690780, NULL),
(843, 4, '50KGA', 'Del Valle Tam', 'Calle Rio Panuco, #308, Col. Unidad Del Valle, Tampico, Tamaulipas, México, 89314, entre Rio Mante Y Francisco I Madero', 22.3073675, -97.8631365, NULL),
(844, 4, '50KSX', 'Sexta Avenida Tam', 'Calle Sexta Avenida, #217, Col. Emilio Portes Gil, Tampico, Tamaulipas, México, 89316, entre Rio Panuco Y Andador 1', 22.3072336, -97.8688548, NULL),
(845, 4, '50QOU', 'Nuevo Progreso Tam', 'Calle Josefa Ortiz De Dominguez, #104, Col. Laguna De La Puerta, Tampico, Tamaulipas, México, 89310, entre Calle Primera Avdenida Y Comonfort', 22.3109750, -97.8737853, NULL),
(846, 4, '50RZR', 'Laguna Puerta Tam', 'Avenida Las Torres, #401, Col. Laguna De La Puerta, Tampico, Tamaulipas, México, 89310, entre Tercera Avenida Y Cuarta Avenida', 22.3170829, -97.8714447, NULL),
(847, 4, '50SKS', 'Enrique Cardenas Tam', 'Avenida Monterrey, #501, Col. Enrique Cardenas Gonzalez, Tampico, Tamaulipas, México, 89309, entre Calle 8 Y Calle 7', 22.3002373, -97.8555718, NULL),
(848, 4, '50TMC', 'Curva Texas Tam', 'Avenida Hidalgo, #1303, Col. Nuevo Progreso, Tampico, Tamaulipas, México, 89318, entre Josefa Ortiz Y Sor Juana Ines', 22.3097673, -97.8807121, NULL),
(849, 4, '50K0A', 'Bravos Maf', 'Calle Benito Juarez, #502, Col. Nuevo Progreso, Tampico, Tamaulipas, México, 89310, entre Esq.Nicolas Bravo', 22.3071407, -97.8737006, NULL),
(850, 4, '505MR', 'Colegio Militar Tam', 'Calle Colegio Militar, #1102, Col. Niños Heroes, Tampico, Tamaulipas, México, 89359, entre Esq. Tancol Y Guayalejo', 22.3188924, -97.8869930, NULL),
(851, 4, '505XR', 'Chairel Tam', 'Calle 4 De Abril, #201, Col. Tancol, Tampico, Tamaulipas, México, 89320, entre Esq. Laguna De Champayan Y Laguna Del Chairel', 22.2987000, -97.8985120, NULL),
(852, 4, '50893', 'Petroquimicas Tam', 'Calle Honduras, #116, Col. Petroquímicas, Tampico, Tamaulipas, México, 89328, entre Esq. Hermenegildo J.Aldana Y Petroquimicas', 22.3093200, -97.8907200, NULL),
(853, 4, '50AER', 'Las Americas Tam', 'Avenida Hidalgo, #101, Col. Las Americas, Tampico, Tamaulipas, México, 89329, entre Ecuador Y Bolivia', 22.3086400, -97.8812706, NULL),
(854, 4, '50BMS', 'Colombia Tam', 'Calle Colombia, #501, Col. Las Americas, Tampico, Tamaulipas, México, 89329, entre Lima Y Puerto Rico', 22.3072687, -97.8858332, NULL),
(855, 4, '50CWO', 'Chapultepec Tam', 'Calle Castillo De Chapultepc, #516, Col. Niños Heroes, Tampico, Tamaulipas, México, 89359, entre Dr. Burton Grossman', 22.3228792, -97.8827834, NULL),
(856, 4, '50HX3', 'Colosio II', 'Calle Revolucion Verde, #201, Col. Luis Donaldo Colosio, Tampico, Tamaulipas, México, 89358, entre Unidad Modelo Y Universidad', 22.3232773, -97.8957475, NULL),
(857, 4, '50IJL', 'Campanula Tam', 'Calle Campanula, #201, Col. Jardines De Champayan, Tampico, Tamaulipas, México, 89358, entre Del Mar Y Maxilibramiento Tampico', 22.3164763, -97.8906667, NULL),
(858, 4, '50IKL', 'La Paz Ii Tam', 'Calle 4 De Abril, #111, Col. La Paz, Tampico, Tamaulipas, México, 89326, entre Aristeo Orta Y Lopez Mateos', 22.3044610, -97.8931802, NULL),
(859, 4, '50SHY', 'Champayan Tam', 'Calle Rivera De Champayan, #401, Col. El Naranjal, Tampico, Tamaulipas, México, 89349, entre Otilio Alvarez Y Alvaro Flores Montante', 22.2996490, -97.8938403, NULL),
(860, 4, '50TFX', 'Las Torres Tam', 'Avenida Las Torres, #102, Col. Pedro J Mendez, Tampico, Tamaulipas, México, 89328, entre Ecuador Y Costa Rica', 22.3099869, -97.8876883, NULL),
(861, 4, '50ULW', 'Colosio Tam', 'Calle Violeta, #700, Col. Luis Donaldo Colosio, Tampico, Tamaulipas, México, 89358, entre Mexico Y Ave. Alvaro Garza Cantu', 22.3197576, -97.8957361, NULL),
(862, 4, '50XO5', 'Canada Tam', 'Calle Canada, #219, Col. Roma, Tampico, Tamaulipas, México, 89350, entre Esq. Haiti Y Apulia', 22.3121000, -97.8822000, NULL),
(863, 4, '50XPT', 'San Pedro Tam', 'Carretera Tampico Mante, #203, Col. Francisco Javier Mina, Tampico, Tamaulipas, México, 89110, entre Tuxpan Y Guadalajara', 22.3013441, -97.8795111, NULL),
(864, 4, '50YOK', 'Haiti Tam', 'Calle Haiti, #516, Col. Magdaleno Aguilar, Tampico, Tamaulipas, México, 89355, entre Division Del Norte Y Emiliano Zapata', 22.3162052, -97.8825028, NULL),
(865, 4, '50WU4', 'Jaibos Maf', ' , #, Col. , , , , , entre ', 22.3079596, -97.8790628, NULL),
(866, 4, '507HY', 'El Navegante Maf', ' , #, Col. , , , , , entre ', 22.3026576, -97.8638509, NULL),
(867, 4, '502UP', 'San Antonio Tam', 'Calle Iztaccihuatl, #201, Col. San Antonio, Tampico, Tamaulipas, México, 89347, entre Cofre De Perote Y Nevado De Toluca', 22.2991778, -97.8862780, 133),
(868, 4, '50AET', 'Aeropuerto Tam', 'Boulevard Adolfo Lopez Mateos, #514, Col. Nuevo Aeropuerto, Tampico, Tamaulipas, México, 89337, entre Fco. Sarabia Y Gral. Lazaro Cardenas', 22.2870284, -97.8691055, 133),
(869, 4, '50TNK', 'Tancol Tam', 'Avenida Rivera De Champayan, #203, Col. La Arboleda, Tampico, Tamaulipas, México, 89345, entre Circuito Alejandra', 22.2951037, -97.8816731, 133),
(870, 4, '50TXP', 'Palmas Tam', 'Avenida Hidalgo, #6505, Col. Nuevo Aeropuerto, Tampico, Tamaulipas, México, 89337, entre Felix C. Vera Y Felipe Pescador', 22.2866126, -97.8730844, 133),
(871, 4, '501LU', 'Sierra Morena Tam', 'Avenida Hidalgo, #3905, Col. Guadalupe, Tampico, Tamaulipas, México, 89120, entre Zacatecas Y Mexico', 22.2529434, -97.8756376, 133),
(872, 4, '503HL', 'Hydros Tam', 'Avenida Hydros, #101, Col. Villas Laguna, Tampico, Tamaulipas, México, 89367, entre Camino Viejo A Tancol Y Maxilibramiento Tampico', 22.2905255, -97.8942460, 133),
(873, 4, '506OI', 'Vista Bella Tam', 'Avenida 14 De Febrero, #907, Col. Unidad Modelo, Tampico, Tamaulipas, México, 89367, entre Esq. Avenida Administradores Y Los Ejidatarios', 22.2869255, -97.8907975, 133),
(874, 4, '50AGW', 'Agua Dulce Tam', 'Calle Agua Dulce, #103, Col. La Florida, Tampico, Tamaulipas, México, 89118, entre Tampico Y Agua Dulce', 22.2571835, -97.8740895, 133),
(875, 4, '50BTM', 'Bolitam Tam', 'Boulevard LomaReal, #307, Col. Lomas Del Chairel, Tampico, Tamaulipas, México, 89360, entre Segunda Y Tercera', 22.2765973, -97.8775987, 133),
(876, 4, '50GRD', 'San Gerardo Tam', 'Avenida Administradores, #200, Col. Jesus Elias Piña, Tampico, Tamaulipas, México, 89365, entre Administradores Y Mante', 22.2862714, -97.8872238, 133),
(877, 4, '50H7X', 'Flamingo Maf', 'Avenida Hidalgo, #3501-S, Col. Guadalupe, Tampico, Tamaulipas, México, 89120, entre Esq. Nayarit y Morelos', 22.2490269, -97.8743295, 133),
(878, 4, '50ITV', 'Infonavit Tam', 'Calle Bolulevard Japon, #58, Col. Arenal, Tampico, Tamaulipas, México, 89344, entre Liberia Y Andador Brasil', 22.2835539, -97.8829214, 133),
(879, 4, '50KCH', 'Charro Tam', 'Avenida Hidalgo, #7102, Col. El Charro, Tampico, Tamaulipas, México, 89364, entre Ave. Del Charro Y Priv.Hidalgo', 22.2710456, -97.8754042, 133),
(880, 4, '50LLR', 'Lomas Tam', 'Calle Paseo Lomas De Rosales, #225, Col. Loma De Rosales, Tampico, Tamaulipas, México, 89100, entre Lomas De Chapultepec Y Belin', 22.2677664, -97.8648438, 133),
(881, 4, '50N0O', 'Jaguar Tam', 'Avenida Miguel Hidalgo Y Costilla, #S/N, Col. Nuevo Aeropuerto, Tampico, Tamaulipas, México, 89337, entre Sin Entre Calle', 22.2822140, -97.8726301, 133),
(882, 4, '50OFO', 'Faja De Oro Tam', 'Calle Faja De Oro, #S/N, Col. Petrolera, Tampico, Tamaulipas, México, 89110, entre Nanchital Y Agua Dulce', 22.2567939, -97.8682677, 133),
(883, 4, '50OFY', 'Flamboyanes Tam', 'Calle Valles, #210, Col. Flamboyanes, Tampico, Tamaulipas, México, 89330, entre Abedules Y Fresno', 22.2752003, -97.8732835, 133),
(884, 4, '50RAE', 'Rosales Tam', 'Calle Paseo Lomas De Rosales, #89100, Col. Loma De Rosales, Tampico, Tamaulipas, México, 89100, entre Prolong. Ave. Hidalgo Y Loma Bonita', 22.2653271, -97.8728566, 133),
(885, 4, '50SFV', 'Wisconsin Tam', 'Calle Universidad De Wisconsin, #514, Col. Universidad Sur, Tampico, Tamaulipas, México, 89109, entre Universidad De Oxford Y Universidad De Tamaulipas', 22.2703964, -97.8631066, 133),
(886, 4, '50TPI', 'Unidad Modelo Tam', 'Avenida De Los Medicos, #803, Col. Unidad Modelo, Tampico, Tamaulipas, México, 89367, entre Los Mangos Y Trabajo Social', 22.2814131, -97.8868729, 133),
(887, 4, '50TQP', 'Herradura Tam', 'Avenida Hidalgo, #5510, Col. Lomas Del Chairel, Tampico, Tamaulipas, México, 89360, entre Marquez De Guadalupe Y Boulevard Loma Real', 22.2721756, -97.8749586, 133),
(888, 4, '50VS6', 'Calle A Tam', 'Calle A, #100, Col. San Pedro Fernando, Tampico, Tamaulipas, México, 89215, entre Camino Viejo A Tancol Y Ave.Las Torres', 22.2794000, -97.8916000, 133),
(889, 4, '50ZDA', 'Calzada Tam', 'Calle Calzada San Fernando, #302, Col. Villa San Pedro, Tampico, Tamaulipas, México, 89369, entre Paseo Real Y Tunez', 22.2863379, -97.8772486, 133),
(890, 4, '50ZGP', 'Guadalupe Tam', 'Calle Mexico, #401, Col. Guadalupe, Tampico, Tamaulipas, México, 89120, entre Privada Zacatecas Y Tampico', 22.2530798, -97.8727749, 133),
(891, 4, '5012S', 'Cultural Tam', 'Avenida Universidad, #908, Col. Gustavo Diaz Ordaz, Tampico, Tamaulipas, México, 89108, entre Esq. Prolongación Calle 10 Ignacio Morones Prieto', 22.2665000, -97.8597000, 133),
(892, 4, '50ARO', 'Oro Tam', 'Calle Prolongacion Faja De Oro, #704, Col. Universidad Poniente, Tampico, Tamaulipas, México, 89336, entre Universidad De Yucatan Y Universidad De Queretaro', 22.2795199, -97.8683851, 133),
(893, 4, '50KDB', 'Dos Bocas Tam', 'Avenida Universidad, #207, Col. Petrolera, Tampico, Tamaulipas, México, 89110, entre Dos Bocas Y Ojo De Agua', 22.2565182, -97.8641066, 133),
(894, 4, '50PTB', 'Uni. Poniente Tam', 'Boulevard Adolfo Lopez Mateos, #4104, Col. Universidad Poniente, Tampico, Tamaulipas, México, 89336, entre Universidad De Mexico Y Universidad Veracruz', 22.2821350, -97.8639651, 133),
(895, 4, '50UDI', 'Universidad Tam', 'Avenida Universidad, #101, Col. Los Picos, Tampico, Tamaulipas, México, 89139, entre Calle Quinta Y Cuarta', 22.2632846, -97.8605539, 133),
(896, 4, '503RS', 'Plaza Dorada Maf', 'Avenida Miguel Hidalgo Y Costilla, #S/N, Col. Lomas Del Naranjal, Tampico, Tamaulipas, México, 89106, entre ', 22.2603664, -97.8752090, 133),
(897, 4, '508OK', 'El Dorado Tam', 'Avenida Rivera De Champayan, #117, Col. Tancol, Tampico, Tamaulipas, México, 89320, entre Avenida Hidalgo Y Circuito Alejandra', 22.2954365, -97.8793838, 133),
(898, 4, '50839', 'Grecia Maf', ' , #, Col. , , , , , entre ', 22.2835625, -97.8807179, 133),
(899, 4, '50BDK', 'San Luis Tam', 'Calle Oaxaca, #201, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89410, entre San Luis Y Morelos', 22.2676613, -97.8493339, 133),
(900, 4, '50DUI', 'Dona Cecilia Tam', 'Calle Republica De Cuba, #600, Col. Lazaro Cardenas, Ciudad Madero, Tamaulipas, México, 89430, entre Doña Cecilia Y Diaz Miron', 22.2566257, -97.8438156, 133),
(901, 4, '50ESO', 'Estadio Tam', 'Calle Jalisco, #S/N, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89410, entre Boulevard Lopez Mateos Y Puebla', 22.2728819, -97.8519400, 133),
(902, 4, '50FEG', 'Regional Tam', 'Calle 5Ta. Avenida, #1005, Col. Jardin Veinte De Noviembre, Ciudad Madero, Tamaulipas, México, 89440, entre 10 Y 11', 22.2662101, -97.8558350, 133),
(903, 4, '50GRF', 'Grafer Tam', 'Boulevard Adolfo Lopez Mateos, #606, Col. Los Mangos, Ciudad Madero, Tamaulipas, México, 89440, entre Manuel Acuña Y Antonio Plaza', 22.2616169, -97.8503733, 133),
(904, 4, '50KC4', 'Calle 9 Tam', 'Boulevard Adolfo López Mateos, #1001, Col. Jardin Veinte De Noviembre, Ciudad Madero, Tamaulipas, México, 89440, entre Esquina Calle 9', 22.2629370, -97.8503016, 133),
(905, 4, '50KMA', 'Madero Tam', 'Calle Morelos, #100, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89410, entre Madero Y Queretaro', 22.2711918, -97.8488342, 133),
(906, 4, '50NYR', 'Nayarit Tam', 'Calle Nayarit, #305, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89410, entre Durango Y Michoacan', 22.2634899, -97.8470432, 133),
(907, 4, '50PXQ', 'Monteverde Tam', 'Avenida Universidad, #407, Col. Monteverde, Ciudad Madero, Tamaulipas, México, 89420, entre Calle 15 Y Calle 14', 22.2703896, -97.8582233, 133),
(908, 4, '50VNV', '20 De Noviembre Tam', 'Calle 4Ta. Avenida, #607, Col. Jardin Veinte De Noviembre, Ciudad Madero, Tamaulipas, México, 89440, entre Calle Quinta Y Calle Cuarta', 22.2616543, -97.8558571, 133),
(909, 4, '50YVY', 'Lopez Mateos Tam', 'Boulevard Adolfo Lopez Mateos, #209-A, Col. Jardin Veinte De Noviembre, Ciudad Madero, Tamaulipas, México, 89440, entre Primera Y Prol.Primero De Mayo', 22.2573853, -97.8523001, 133),
(910, 4, '50ZNL', 'Sinaloa Tam', 'Calle Sinaloa, #101 Sur, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89410, entre Ave. Madero Y Puebla', 22.2717000, -97.8499960, 133),
(911, 4, '5072E', 'Sonora Tam', 'Avenida Rodolfo Torre Cantu, #301, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89410, entre Sonora Y Ave. Monterrey', 22.2738511, -97.8459941, 133),
(912, 4, '50AUN', 'Ampliacion Tam', 'Calle Felipe Carrillo Pto., #120  NTE., Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre 120 Nte.', 22.2825666, -97.8429225, 133),
(913, 4, '50QDS', 'Oma Tam', 'Boulevard Adolfo Lopez Mateos, #1003, Col. Nuevo Aeropuerto, Tampico, Tamaulipas, México, 89337, entre Faja De Oro Y Ave Jalisco', 22.2835587, -97.8645661, 133),
(914, 4, '50TOC', 'Cedros Tam', 'Avenida Monterrey, #100, Col. Los Cedros, Ciudad Madero, Tamaulipas, México, 89515, entre Manzanillo Y And. Soto La Marina', 22.2837719, -97.8496313, 133),
(915, 4, '50TTJ', 'Jalisco Tam', 'Calle Jalisco, #300, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89410, entre Veracruz Y Zacatecas', 22.2769187, -97.8506785, 133),
(916, 4, '50UNA', 'Unidad Nacional Tam', 'Avenida Madero Ote., #404, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89410, entre Chiuahua Y Chiapas', 22.2669954, -97.8444785, 133),
(917, 4, '50ZZM', 'Monterrey Ii Tam', 'Calle Juarez, #213 SUR, Col. Unidad Nacional, Ciudad Madero, Tamaulipas, México, 89510, entre Monterrey Y 5 De Febrero', 22.2779789, -97.8465168, 133),
(918, 4, '50IIL', 'Saltillo Ii Tam', 'Calle Guatemala, #1500, Col. Vicente Guerrero, Ciudad Madero, Tamaulipas, México, 89580, entre Sor Juana Ines Y Ave. Monterrey', 22.2620564, -97.8399369, 133),
(919, 4, '50SFR', 'Honduras Tam', 'Calle Honduras, #1006, Col. Camichines, Ciudad Madero, Tamaulipas, México, 89553, entre Ramos Arizpe Y Privada Honduras', 22.2598010, -97.8361634, 133),
(920, 4, '50IOY', 'Movil Tam', 'Calle Emilano Zapata, #325, Col. Presas Del Arenal, Tampico, Tamaulipas, México, 89344, entre Niños Heroes', 22.2926000, -97.8770000, 133),
(921, 4, '5038G', 'Campbell Tam', 'Calle Tancol, #901, Col. Cambell, Tampico, Tamaulipas, México, 89260, entre Torreon Y Panuco', 22.2243607, -97.8692900, 133),
(922, 4, '5055S', 'Calzada Blanca Maf', 'Calle Calzada Blanca, #1516, Col. Morelos, Tampico, Tamaulipas, México, 89290, entre Esq. C12 y Jesus Garcia', 22.2234478, -97.8877076, 133),
(923, 4, '507KD', 'Plaza Altavista Maf', 'Calle Francisco Nicodemo, #152, Col. Smith, Tampico, Tamaulipas, México, 89140, entre Av. Miguel Hidalgo y 1a. Avenida (Plaza Altavista)', 22.2398917, -97.8694066, 133),
(924, 4, '507VU', 'Petrolera Tam', 'Avenida Ayuntamiento, #3408, Col. Minerva, Tampico, Tamaulipas, México, 89120, entre Esq. Durango Y Nayarit', 22.2518963, -97.8664832, 133),
(925, 4, '50ALC', 'Alarcon Tam', 'Calle Alvaro Obregon, #601, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Alarcon Y Dr. Gochicoa', 22.2199227, -97.8614848, 133),
(926, 4, '50EJE', 'Ejercito Tam', 'Avenida Ejercito Mexicano, #601, Col. Minerva, Tampico, Tamaulipas, México, 89120, entre Faja De Oro Y Ayuntamiento', 22.2490924, -97.8679941, 133),
(927, 4, '50HDL', 'Hidalgo Tam', 'Avenida Hidalgo, #2400, Col. Altavista, Tampico, Tamaulipas, México, 89240, entre Eucalipto Y Nogal', 22.2388190, -97.8697954, 133),
(928, 4, '50I2L', 'Gaona Tam', 'Avenida Hidalgo, #1607, Col. Trueba, Tampico, Tamaulipas, México, 89170, entre Esq. Topiltzin Y Nafarrete', 22.2333259, -97.8671494, 133),
(929, 4, '50KHI', 'Avenida Hidalgo Tam', 'Avenida Hidalgo, #3101, Col. Guadalupe, Tampico, Tamaulipas, México, 89120, entre Samuel Pegueros Y Ejercito Mexicano', 22.2459905, -97.8726474, 133),
(930, 4, '50LIG', 'Aguila Tam', 'Avenida Hidalgo, #3202, Col. Aguila, Tampico, Tamaulipas, México, 89230, entre Alamo Y Zapote', 22.2430801, -97.8716188, 133),
(931, 4, '50LRH', 'Moscu Tam', 'Carretera Tampico Valles, #401, Col. Vicente Guerrero, Tampico, Tamaulipas, México, 89298, entre Prolongacion Calle Tul Y Sol', 22.2268884, -97.8947511, 133),
(932, 4, '50LRV', 'Lauro Aguirre Tam', 'Avenida Ayuntamiento, #2802, Col. Lauro Aguirre, Tampico, Tamaulipas, México, 89140, entre Avenida Mayor Y De Las Artes', 22.2476048, -97.8676397, 133),
(933, 4, '50M1V', 'Smith Tam', 'Avenida Ayuntamiento, #1604, Col. Smith, Tampico, Tamaulipas, México, 89140, entre Juan M. Correa Y V. Inguanzo', 22.2422973, -97.8670517, 133),
(934, 4, '50MEV', 'Morelos Tam', 'Calle Vicente Guerrero, #1000 A, Col. Morelos, Tampico, Tamaulipas, México, 89290, entre Vicente Guerrero Y E. Zapata', 22.2200541, -97.8773910, 133),
(935, 4, '50N0P', 'La Isla Tam', 'Avenida Heriberto Jara, #1503-A, Col. Vicente Guerrero, Tampico, Tamaulipas, México, 89298, entre Entre Lirio Y Ricardo Ortiz Hernandez', 22.2249016, -97.8933985, 133),
(936, 4, '50QVO', 'Camelia Tam', 'Avenida Hidalgo, #3502, Col. Flores, Tampico, Tamaulipas, México, 89220, entre Camelia Y Gardenia', 22.2467148, -97.8734627, 133),
(937, 4, '50RGN', 'Alijadores Tam', 'Avenida Chairel, #300, Col. Ex Contry Club, Tampico, Tamaulipas, México, 89250, entre Privada Chairel Y Nobleza', 22.2297008, -97.8705262, 133),
(938, 4, '50WAY', 'Alemanes Tam', 'Calle Prolongacion Francita, #1011, Col. Petrolera, Tampico, Tamaulipas, México, 89110, entre Diagonal Norte Sur Y Cuarta Avenida', 22.2552657, -97.8615773, 133),
(939, 4, '50WMZ', 'Morelos Ii Tam', 'Calle Vicente Guerrero, #1000 A, Col. Morelos, Tampico, Tamaulipas, México, 89290, entre Vicente Guerrero Y E. Zapata', 22.2217362, -97.8812974, 133),
(940, 4, '50YWJ', 'Cascajal Tam', 'Calle Salvador Diaz Miron, #816, Col. Cascajal, Tampico, Tamaulipas, México, 89280, entre Medina Cedillo Y Constitucion', 22.2186000, -97.8651000, 133),
(941, 4, '50YZF', 'Otomi Tam', 'Avenida Ayuntamiento, #1209, Col. Benito Juarez, Tampico, Tamaulipas, México, 89150, entre Ignacio Ramirez Y Nicolas Bravo', 22.2368149, -97.8662184, 133),
(942, 4, '506QT', 'Matienzo Tam', 'Calle Altamira, #322, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Sorjuna Ines De La Cruz Y Dr Carlos Canseco', 22.2182443, -97.8601070, 133),
(943, 4, '50CJN', 'Colon Tam', 'Calle Colon, #221, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Obregon Y Altamira', 22.2179068, -97.8572504, 133),
(944, 4, '50KJU', 'Juarez Tam', 'Calle Alvaro Obregon, #305, Col. Tampico Centro, Tampico, Tamaulipas, México, 89000, entre Juarez Y Aduana', 22.2171709, -97.8553287, 133),
(945, 4, '50QLJ', 'Sor Juana Tam', 'Calle Tamaulipas, #219, Col. Zona Centro, Tampico, Tamaulipas, México, 89000, entre Sor Juana Y 20 De Noviembre', 22.2196154, -97.8585277, 133),
(946, 4, '50U6I', 'Plaza Covadonga Maf', 'Avenida Universidad, #801, Col. Tampico, Tampico, Tamaulipas, México, 89137, entre Privada Estadio y Calle Estadio', 22.2519280, -97.8636320, 133),
(947, 4, '504NY', 'Movil 2 Tam', 'Calle Emilano Zapata, #325, Col. Presas Del Arenal, Tampico, Tamaulipas, México, 89344, entre Niños Heroes', 22.2926000, -97.8770000, NULL),
(948, 4, '5049H', 'Movil 3 Tam', 'Calle Emilano Zapata, #325, Col. Presas Del Arenal, Tampico, Tamaulipas, México, 89344, entre Niños Heroes', 22.2926000, -97.8770000, 133),
(949, 4, '50T0S', 'Campeche Maf', NULL, 22.2652400, -97.8419519, NULL),
(950, 3, '50IB3', 'Trejo Maf', NULL, 25.8582751, -97.4748732, NULL),
(951, 3, '50JG1', 'Jesus Vega Maf', NULL, 25.8235594, -97.5395027, NULL),
(952, 3, '500MJ', 'Diez y Victoria Maf', NULL, 25.8764214, -97.5071980, NULL),
(953, 1, '50T2U', 'Punto Novel Maf', NULL, 21.9797182, -99.0050707, NULL),
(954, 2, '503X5', 'El Campanario Maf', NULL, 23.7394379, -99.0939446, NULL),
(955, 3, '50II4', 'Villa Española Maf', NULL, 25.8572694, -97.5269290, NULL),
(956, 3, '50F3C', 'Alhelies Maf', NULL, 25.8873538, -97.4993750, NULL),
(957, 1, '501GV', 'Agencia Matlapa Maf', NULL, 21.3459203, -98.8320258, NULL),
(958, 1, '50J9T', 'La Queretana Maf', NULL, 21.9989530, -99.0137710, NULL),
(959, 1, '50H44', 'Canoas Maf', NULL, 22.1575735, -98.1521056, NULL),
(960, 4, '50F26', 'El Puerto Maf', NULL, 22.2220512, -97.8436689, NULL),
(961, 2, '50P02', 'Loma Prieta Maf', NULL, 23.7681400, -99.1477150, NULL),
(962, 4, '501SI', 'Alfa Maf', NULL, 22.2636749, -97.8415570, NULL),
(963, 1, '50T91', 'Tec Tamazunchale Maf', NULL, 21.2690185, -98.7422912, NULL),
(964, 1, '50M0W', 'Tipzen Maf', NULL, 21.9799925, -98.9999850, NULL),
(965, 4, '50639', 'El Jardin Maf', NULL, 22.2618808, -97.8540251, NULL),
(966, 4, '5064O', 'El Maderense Maf', NULL, 22.2818211, -97.8472827, NULL),
(967, 1, '50SQ7', 'Valles Tampico Maf', NULL, 21.9768142, -98.9798186, NULL),
(968, 1, '50HE3', 'Palacio Municipal Maf', NULL, 22.9972375, -98.9452279, NULL),
(969, 2, '506S5', 'La Tamaulipeca Maf', NULL, 23.7479788, -99.1629726, NULL),
(970, 2, '500D5', '22 Mina Maf', NULL, 23.7412276, -99.1562453, NULL),
(971, 2, '509BC', 'Victoria Centro Maf', NULL, 23.7339591, -99.1557045, NULL),
(972, 2, '507IG', 'Espejo Maf', NULL, 22.4715473, -97.9446841, NULL),
(973, 3, '50M7I', 'Parker Maf', NULL, 25.8437790, -97.4378770, NULL),
(974, 2, '503SN', 'Boulevard Echeverria Maf', NULL, 23.7249300, -99.1497390, NULL),
(975, 3, '509T4', 'Paseo de la Castellana Maf', NULL, 25.8628683, -97.5311974, NULL),
(976, 4, '50V06', 'Loma Chairel Maf', NULL, 22.2762169, -97.8803379, NULL),
(977, 3, '50800', 'Callejon 5 MAF', NULL, 25.8582385, -97.4826698, NULL),
(978, 1, '50JE2', 'Las Golondrinas MAF', NULL, 21.6232604, -99.0155783, NULL),
(979, 3, '506KM', 'Malinalco MAF', NULL, 25.8351147, -97.4573598, NULL),
(980, 4, '508Q8', 'Plaza del Parque MAF', NULL, 22.2652012, -97.8528989, NULL),
(981, 2, '50EK7', 'El Cielo MAF', NULL, 23.7572410, -99.1194160, NULL),
(982, 4, '503IA', 'Marquez de Guadalupe MAF', NULL, 22.2734767, -97.8817728, NULL),
(983, 1, '500WR', 'Central Valles MAF', NULL, 21.9688138, -98.9974508, NULL),
(984, 3, '50U6N', 'Villa Hermosa MAF', NULL, 25.8785888, -97.5475586, NULL),
(985, 3, '503X6', 'Inteva Alianza Maf', NULL, 25.8669355, -97.5745657, NULL),
(986, 3, '50LP8', 'La Modelo MAF', NULL, 25.8740341, -97.4926919, NULL),
(987, 2, '50T7W', '40 Juarez MAF', NULL, 23.7300340, -99.1768950, NULL),
(988, 4, '50C3Q', 'Madero Centro MAF', NULL, 22.2455755, -97.8376317, NULL),
(989, 2, '503EO', 'Victoria Norte MAF', NULL, 23.7763480, -99.1372240, NULL),
(990, 2, '508X8', 'Plaza Morelos MAF', NULL, 23.7357490, -99.1456790, NULL),
(991, 3, '506ZB', 'Primera y Teran MAF', NULL, 25.8748690, -97.4996830, NULL),
(992, 3, '506U9', 'Playa Encantada MAF', NULL, 25.8528060, -97.4723980, NULL),
(993, 3, '50GZ1', 'Abelardo de la Torre MAF', NULL, 25.8336970, -97.4921140, NULL),
(994, 2, '501GM', 'Gladiolas MAF', NULL, 22.3704057, -97.9026253, NULL),
(995, 1, '50G0V', 'Hospital Mante MAF', NULL, 22.7266670, -98.9693020, NULL),
(996, 1, '50S6R', 'IMSS Mante MAF', NULL, 22.7468470, -98.9653000, NULL),
(997, 1, '508N9', 'Diaz Ordaz MAF', NULL, 22.0072750, -99.0177160, NULL),
(998, 3, '50X2S', 'Bustamante MAF', NULL, 25.8821960, -97.5128980, NULL),
(999, 2, '50SC4', 'Puerto Industrial II MAF', NULL, NULL, NULL, NULL),
(1000, 1, '50ON7', 'Movil Tamasopo MAF', NULL, 21.9977619, -99.0105536, NULL),
(1001, 1, '50OW7', 'Turistico 2 MAF', NULL, 21.9976162, -99.0103065, NULL),
(1002, 4, '506VF', 'Plaza Rondinela MAF', NULL, 22.2637530, -97.8610250, NULL),
(1003, 4, '509A5', 'Bucareli MAF', NULL, 22.2287670, -97.8644290, NULL),
(1004, 3, '506I1', 'La Valentina MAF', NULL, 24.8524210, -98.1267900, NULL),
(1005, 3, '500TP', 'Casillas MAF', NULL, 25.6669770, -97.8328270, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `token_acceso`
--

CREATE TABLE `token_acceso` (
  `token` char(64) NOT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_expiracion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `token_acceso`
--

INSERT INTO `token_acceso` (`token`, `usuario_id`, `fecha_creacion`, `fecha_expiracion`) VALUES
('0a8b630f86fb9474b783799fe06d7ccd3db711b0fb12163c357745c3a5d2952f', 1, '2026-08-25 09:43:35', '2026-09-24 09:43:35'),
('2dcdc07fbf7565bfda9ffab0725c91a07538263a3e6a3ebe04e7607dadf9e607', 128, '2026-08-25 06:28:30', '2026-09-24 06:28:30'),
('74a7db9eae1a50d38fa6b4fe95ffc8ff307486bf7a2a76abb55234d1c575d45a', 101, '2026-08-25 06:44:11', '2026-09-24 06:44:11');

-- --------------------------------------------------------

--
-- Table structure for table `usuario`
--

CREATE TABLE `usuario` (
  `id` int(10) UNSIGNED NOT NULL,
  `rol_id` int(10) UNSIGNED NOT NULL,
  `plaza_id` int(10) UNSIGNED DEFAULT NULL,
  `correo` varchar(150) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `nombre_completo` varchar(150) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `debe_cambiar_password` tinyint(1) NOT NULL DEFAULT 0,
  `foto_perfil` varchar(255) DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `usuario`
--

INSERT INTO `usuario` (`id`, `rol_id`, `plaza_id`, `correo`, `telefono`, `nombre_completo`, `password_hash`, `debe_cambiar_password`, `foto_perfil`, `fecha_registro`) VALUES
(1, 2, 1, 'raul.huerta@getic.com.mx', '8118237745', 'Raul Huerta Aguilar', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 0, 'uploads/perfiles/03f796f0196c44d233aad4e5f5750d5f.png', '2026-07-10 19:08:00'),
(100, 3, 1, 'roberto.patino@getic.com.mx', '8116892099', 'Roberto Carlos Patiño Martinez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/bdcadf0ef6011f0faa9d45a628156df4.png', '2026-08-25 04:35:19'),
(101, 3, 1, 'jose.arcos@getic.com.mx', '8116560669', 'José Miguel Arcos Soto', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 0, 'uploads/perfiles/4c4df7baa11ff7aa996413f9fe11a09b.png', '2026-08-25 04:35:19'),
(102, 3, 1, 'jose.flores@getic.com.mx', '8117805989', 'Jose Alfredo Flores Zuñiga', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/6c5770d6ce3a52da145e55dd03a4eb4a.png', '2026-08-25 04:35:19'),
(103, 3, 1, 'erik.cruz@getic.com.mx', '8117456169', 'Erik Aquilino Cruz Ramirez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/bf6ccb8b2173c6c3f70692549fd1514b.png', '2026-08-25 04:35:19'),
(104, 3, 1, 'oscar.duenez@getic.com.mx', '8118256264', 'Oscar Giovanni Dueñez Lopez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/b0a9252eedf8189c5cbfec7dd6fef9ad.png', '2026-08-25 04:35:19'),
(105, 3, 2, 'julio.ramos@getic.com.mx', '8116593229', 'Julio Cesar Ramos Ramírez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/8cf4f8fdbaca15085233aede1cf7ddda.png', '2026-08-25 04:35:19'),
(106, 3, 2, 'carlos.rosales@getic.com.mx', '8125772469', 'Carlos Alberto Rosales Prianti', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/01533a2bdc8b71eaf77dc3717b794f20.png', '2026-08-25 04:35:19'),
(107, 3, 2, 'axel.alvarado@getic.com.mx', '8116625324', 'Axel Alejandro Alvarado Yepez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/bddecf53a8e6ea3b9f0c9263393bac3d.png', '2026-08-25 04:35:19'),
(108, 3, 2, 'jesus.contreras@getic.com.mx', '8117996983', 'Jesus Contreras Perez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/945a12da7a6a55e478ef9fa877626207.png', '2026-08-25 04:35:19'),
(109, 3, 2, 'jose.rendon@getic.com.mx', '8125723640', 'Jose Eduardo Rendon Rodriguez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/01187b49af7b42ebf727fa9c1cdf7183.png', '2026-08-25 04:35:19'),
(110, 3, 3, 'uriel.vega@getic.com.mx', '8117868369', 'Uriel Antonio Vega Jerez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/8a9c4377037666c2c1c05122d566c409.png', '2026-08-25 04:35:19'),
(111, 3, 3, 'luis.salazar@getic.com.mx', '8117948413', 'Luis Felipe Salazar Sanchez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/02f572feeb64b12d8b9f3609d5a3ca67.png', '2026-08-25 04:35:19'),
(112, 3, 3, 'jose.leal@getic.com.mx', '8120310570', 'Jose Eliot Leal Flores', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/a4fdc363e6bfe919fdbca4d9005ccbb4.png', '2026-08-25 04:35:19'),
(113, 3, 3, 'eder.montiel@getic.com.mx', '8119134519', 'Eder Rodolfo Montiel Alonso', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/7863a45388eee341dc007ca44c940284.png', '2026-08-25 04:35:19'),
(114, 3, 4, 'francisco.saldierna@getic.com.mx', '8110047558', 'Francisco Xavier Saldierna Cabrales', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/35e35ab044a94502e780eb01ac8e9776.png', '2026-08-25 04:35:19'),
(115, 3, 4, 'jose.torres@getic.com.mx', '8126052273', 'Jose Abraham Torres Bonilla', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/96c8b8382b84b4f0ad83dfd7835f8856.png', '2026-08-25 04:35:19'),
(116, 3, 4, 'gustavo.mejia@getic.com.mx', '8116522953', 'Gustavo Antonio Mejia Gonzalez', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/ef3651eab26595c3df03ce3f10891e0a.png', '2026-08-25 04:35:19'),
(117, 3, 4, 'gustavo.hernandez@getic.com.mx', '8116817212', 'Gustavo Manuel Hernández Hernández', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/7671bde819b05f4aa86e123ef0049a5c.png', '2026-08-25 04:35:19'),
(118, 3, 4, 'aldo.delafuente@getic.com.mx', '8117980824', 'Aldo Jesus De La Fuente Pecina', '$2b$12$6lfb7q09dSvuVjtb1yOWW.VxrCya751Eb71sJwBuAQ2qUJ4WH2KEe', 1, 'uploads/perfiles/d8ad51bd773e63e0e894fbd94a1377cb.png', '2026-08-25 04:35:19'),
(128, 1, 1, 'rosa.ramirez@oxxo.com', NULL, 'Rosa Martha Ramirez Castillo', '$2y$12$NocQMNXGZnwS1VSArBVL1ufn97DMMfpfszvPic4ZtVIueE0nhQCPS', 0, 'uploads/perfiles/2913ca82f195888d9aeed482051cac16.jpg', '2026-08-25 05:24:50'),
(129, 1, 1, 'enrique.gil@oxxo.com', NULL, 'Enrique Gil Zarate', '$2y$12$clkmglE0/Hw4YtrMPAqHxO201kKmhXwuk06mJgaiE8ZFh.d.6OjGC', 1, 'uploads/perfiles/3bf4607cfee662b081eec08520a58745.jpg', '2026-08-25 05:24:50'),
(130, 1, 2, 'ramon.morales@oxxo.com', NULL, 'Ramon Arturo Morales', '$2y$12$FibjLIRXPdjDjFzm5VYxneSKSWwysOR0.TDXHyMuWPOnsBrW09DO6', 1, 'uploads/perfiles/c2f87103bf67840f984ffce82091f57f.jpg', '2026-08-25 05:24:50'),
(131, 1, 3, 'erick.martinez@oxxo.com', NULL, 'Erick Alejandro Martinez Nino', '$2y$12$5SpJepqqnbyZQiNRaeXHuuW9ANbvRPYkzI5.66htVR6ML7/IpEoSy', 1, NULL, '2026-08-25 05:24:50'),
(132, 1, 3, 'hugo.perez@oxxo.com', NULL, 'Hugo Perez', '$2y$12$GUWD7nnYMbX4QJV1.M0kAeIJAn9kNHKFTiqT5C/WTBI6agjGh.LaG', 1, 'uploads/perfiles/6a796729bc7ddc622d8fdfc4af7fba8b.jpg', '2026-08-25 05:24:50'),
(133, 1, 4, 'felipe.trejo@oxxo.com', NULL, 'Felipe Trejo', '$2y$12$bjzOzjC8eLVMfpFBws6y9OqeOXtwfB6KaZ/PfwSg2rXB6NWZ68TVa', 1, 'uploads/perfiles/a2001fbccfa8a03e59d37aa961ca3a53.jpg', '2026-08-25 05:24:50'),
(134, 1, 4, 'charlie.ruiz@oxxo.com', NULL, 'Charlie Ruiz', '$2y$12$BeppYBUp2E7QpyVZoWZqXuGDFYmCdbaKWVd9Md2QQNkKI0u3dJUj6', 1, 'uploads/perfiles/b411406011d0b3332931a22dd2412456.jpg', '2026-08-25 05:24:50');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cuestionario`
--
ALTER TABLE `cuestionario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_cuestionario_plaza` (`plaza_id`);

--
-- Indexes for table `encuesta`
--
ALTER TABLE `encuesta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_encuesta_usuario` (`usuario_id`),
  ADD KEY `fk_encuesta_cuestionario` (`cuestionario_id`),
  ADD KEY `idx_encuesta_tienda` (`tienda_id`),
  ADD KEY `idx_encuesta_sincronizado` (`sincronizado`),
  ADD KEY `idx_encuesta_fecha` (`fecha_creacion_local`);

--
-- Indexes for table `negocio`
--
ALTER TABLE `negocio`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_negocio_default` (`es_default`);

--
-- Indexes for table `plaza`
--
ALTER TABLE `plaza`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_plaza_region` (`region_id`),
  ADD KEY `idx_plaza_default` (`es_default`);

--
-- Indexes for table `pregunta`
--
ALTER TABLE `pregunta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pregunta_usuario` (`creado_por_usuario_id`),
  ADD KEY `idx_pregunta_cuestionario_orden` (`cuestionario_id`,`orden`);

--
-- Indexes for table `region`
--
ALTER TABLE `region`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_region_negocio` (`negocio_id`),
  ADD KEY `idx_region_default` (`es_default`);

--
-- Indexes for table `respuesta_detalle`
--
ALTER TABLE `respuesta_detalle`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_respuesta_unica` (`encuesta_id`,`pregunta_id`),
  ADD KEY `fk_respuesta_pregunta` (`pregunta_id`);

--
-- Indexes for table `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indexes for table `tienda`
--
ALTER TABLE `tienda`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_tienda_codigo` (`codigo`),
  ADD KEY `fk_tienda_plaza` (`plaza_id`),
  ADD KEY `idx_tienda_asesor` (`asesor_ti_usuario_id`);

--
-- Indexes for table `token_acceso`
--
ALTER TABLE `token_acceso`
  ADD PRIMARY KEY (`token`),
  ADD KEY `idx_token_usuario` (`usuario_id`);

--
-- Indexes for table `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `correo` (`correo`),
  ADD KEY `fk_usuario_rol` (`rol_id`),
  ADD KEY `fk_usuario_plaza` (`plaza_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cuestionario`
--
ALTER TABLE `cuestionario`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `negocio`
--
ALTER TABLE `negocio`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `plaza`
--
ALTER TABLE `plaza`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `pregunta`
--
ALTER TABLE `pregunta`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `region`
--
ALTER TABLE `region`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `rol`
--
ALTER TABLE `rol`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tienda`
--
ALTER TABLE `tienda`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1006;

--
-- AUTO_INCREMENT for table `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=135;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cuestionario`
--
ALTER TABLE `cuestionario`
  ADD CONSTRAINT `fk_cuestionario_plaza` FOREIGN KEY (`plaza_id`) REFERENCES `plaza` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `encuesta`
--
ALTER TABLE `encuesta`
  ADD CONSTRAINT `fk_encuesta_cuestionario` FOREIGN KEY (`cuestionario_id`) REFERENCES `cuestionario` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_encuesta_tienda` FOREIGN KEY (`tienda_id`) REFERENCES `tienda` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_encuesta_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `plaza`
--
ALTER TABLE `plaza`
  ADD CONSTRAINT `fk_plaza_region` FOREIGN KEY (`region_id`) REFERENCES `region` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `pregunta`
--
ALTER TABLE `pregunta`
  ADD CONSTRAINT `fk_pregunta_cuestionario` FOREIGN KEY (`cuestionario_id`) REFERENCES `cuestionario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pregunta_usuario` FOREIGN KEY (`creado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `region`
--
ALTER TABLE `region`
  ADD CONSTRAINT `fk_region_negocio` FOREIGN KEY (`negocio_id`) REFERENCES `negocio` (`id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
