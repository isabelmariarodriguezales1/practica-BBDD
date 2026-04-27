-- ============================================================
-- CREACIÓN DE LA BASE DE DATOS
-- Base de datos genómica - Klebsiella pneumoniae
-- Grupo 25
-- ============================================================

CREATE DATABASE IF NOT EXISTS bd_genomica_grupo25;
USE bd_genomica_grupo25;

-- ────────────────────────────────────────────────────────────
-- BORRADO DE TABLAS (orden inverso para respetar FKs)
-- ────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS `estudio_entidad_genetica`;
DROP TABLE IF EXISTS `autor_estudio`;
DROP TABLE IF EXISTS `anotacion`;
DROP TABLE IF EXISTS `variante`;
DROP TABLE IF EXISTS `secuencia`;
DROP TABLE IF EXISTS `Gen`;
DROP TABLE IF EXISTS `estudio`;
DROP TABLE IF EXISTS `entidad_genetica`;

-- ============================================================
-- CREACIÓN DE TABLAS
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- Tabla entidad_genetica
-- Superentidad de la jerarquía Gen / Variante
-- ────────────────────────────────────────────────────────────
CREATE TABLE `entidad_genetica` (
    `id_entidad_genetica` INT          NOT NULL AUTO_INCREMENT,
    `fecha_registro`      DATE         NULL,
    `especie`             VARCHAR(100) NULL,
    `version_genoma`      VARCHAR(50)  NULL,

    PRIMARY KEY (`id_entidad_genetica`)
);

-- ────────────────────────────────────────────────────────────
-- Tabla Gen
-- Subtipo de entidad_genetica (herencia 1:1)
-- ────────────────────────────────────────────────────────────
CREATE TABLE `Gen` (
    `id_gen`               INT          NOT NULL AUTO_INCREMENT,
    `id_entidad_genetica`  INT          NOT NULL,
    `nombre`               VARCHAR(100) NOT NULL,
    `descripcion`          TEXT         NOT NULL,
    `posicion_cromosomica` VARCHAR(50)  NULL,
    `orientacion`          CHAR(1)      NULL,

    PRIMARY KEY (`id_gen`),

    CONSTRAINT `gen_nombre_unique`
        UNIQUE (`nombre`),

    -- 1:1 con entidad_genetica: una entidad no puede pertenecer a dos genes
    CONSTRAINT `gen_entidad_unique`
        UNIQUE (`id_entidad_genetica`),

    CONSTRAINT `gen_entidad_fk`
        FOREIGN KEY (`id_entidad_genetica`)
        REFERENCES `entidad_genetica`(`id_entidad_genetica`)
        ON DELETE CASCADE
);

-- ────────────────────────────────────────────────────────────
-- Tabla Secuencia
-- Entidad débil: se identifica por (id_gen, posicion_gen)
-- ────────────────────────────────────────────────────────────
CREATE TABLE `secuencia` (
    `id_gen`      INT          NOT NULL,
    `posicion_gen` INT         NOT NULL,
    `cadena_adn`  VARCHAR(1000) NOT NULL,
    `tipo`        VARCHAR(50)  NULL,

    PRIMARY KEY (`id_gen`, `posicion_gen`),

    CONSTRAINT `secuencia_gen_fk`
        FOREIGN KEY (`id_gen`)
        REFERENCES `Gen`(`id_gen`)
        ON DELETE CASCADE,

    -- posicion_gen debe ser entero positivo
    CONSTRAINT `secuencia_posicion_positiva`
        CHECK (`posicion_gen` > 0),

    -- cadena_adn entre 10 y 1000 caracteres
    CONSTRAINT `secuencia_cadena_longitud`
        CHECK (CHAR_LENGTH(`cadena_adn`) BETWEEN 10 AND 1000)
);

-- ────────────────────────────────────────────────────────────
-- Tabla Variante
-- Subtipo de entidad_genetica (herencia 1:1)
-- Asociada a una secuencia concreta mediante FK compuesta
-- ────────────────────────────────────────────────────────────
CREATE TABLE `variante` (
    `id_variante`         INT            NOT NULL AUTO_INCREMENT,
    `id_entidad_genetica` INT            NOT NULL,
    `id_gen`              INT            NOT NULL,
    `posicion_gen`        INT            NOT NULL,
    `posicion_en_gen`     INT            NOT NULL,
    `alelo_referencia`    VARCHAR(10)    NULL DEFAULT '-',
    `alelo_mutado`        VARCHAR(10)    NULL DEFAULT '-',
    `tipo_variante`       VARCHAR(50)    NULL,
    `frecuencia_alelica`  DECIMAL(5,4)  NULL,
    `impacto_clinico`     VARCHAR(100)   NULL,

    PRIMARY KEY (`id_variante`),

    -- 1:1 con entidad_genetica: una entidad no puede pertenecer a dos variantes
    CONSTRAINT `variante_entidad_unique`
        UNIQUE (`id_entidad_genetica`),

    CONSTRAINT `variante_entidad_fk`
        FOREIGN KEY (`id_entidad_genetica`)
        REFERENCES `entidad_genetica`(`id_entidad_genetica`)
        ON DELETE CASCADE,

    -- FK compuesta hacia secuencia
    CONSTRAINT `variante_secuencia_fk`
        FOREIGN KEY (`id_gen`, `posicion_gen`)
        REFERENCES `secuencia`(`id_gen`, `posicion_gen`)
        ON DELETE CASCADE,

    -- posicion_en_gen debe ser entero positivo
    CONSTRAINT `variante_posicion_positiva`
        CHECK (`posicion_en_gen` > 0)
);

-- ────────────────────────────────────────────────────────────
-- Tabla Anotacion
-- Relacionada con cualquier entidad genética (gen o variante)
-- ────────────────────────────────────────────────────────────
CREATE TABLE `anotacion` (
    `id_anotacion`        INT         NOT NULL AUTO_INCREMENT,
    `id_entidad_genetica` INT         NOT NULL,
    `descripcion`         TEXT        NULL,
    `tipo`                VARCHAR(50) NULL,

    PRIMARY KEY (`id_anotacion`),

    CONSTRAINT `anotacion_entidad_fk`
        FOREIGN KEY (`id_entidad_genetica`)
        REFERENCES `entidad_genetica`(`id_entidad_genetica`)
        ON DELETE CASCADE
);

-- ────────────────────────────────────────────────────────────
-- Tabla Estudio
-- ────────────────────────────────────────────────────────────
CREATE TABLE `estudio` (
    `id_estudio`        INT          NOT NULL AUTO_INCREMENT,
    `titulo`            VARCHAR(255) NULL,
    `fecha_publicacion` DATE         NULL,
    `referencia`        VARCHAR(10)  NULL,
    `doi`               VARCHAR(100) NULL,
    `revista`           VARCHAR(100) NULL,

    PRIMARY KEY (`id_estudio`),

    -- Formato referencia: 4 letras / 3 dígitos  ej: abcd/001
    CONSTRAINT `estudio_referencia_formato`
        CHECK (`referencia` REGEXP '^[A-Za-z]{4}/[0-9]{3}$')
);

-- ────────────────────────────────────────────────────────────
-- Tabla autor_estudio
-- Atributo multivaluado de Estudio
-- ────────────────────────────────────────────────────────────
CREATE TABLE `autor_estudio` (
    `id_estudio` INT          NOT NULL,
    `autor`      VARCHAR(150) NOT NULL,

    PRIMARY KEY (`id_estudio`, `autor`),

    CONSTRAINT `autor_estudio_fk`
        FOREIGN KEY (`id_estudio`)
        REFERENCES `estudio`(`id_estudio`)
        ON DELETE CASCADE
);

-- ────────────────────────────────────────────────────────────
-- Tabla estudio_entidad_genetica
-- Tabla puente N:M entre Estudio y Entidad_Genetica
-- ────────────────────────────────────────────────────────────
CREATE TABLE `estudio_entidad_genetica` (
    `id_estudio`          INT NOT NULL,
    `id_entidad_genetica` INT NOT NULL,

    PRIMARY KEY (`id_estudio`, `id_entidad_genetica`),

    CONSTRAINT `eeg_estudio_fk`
        FOREIGN KEY (`id_estudio`)
        REFERENCES `estudio`(`id_estudio`)
        ON DELETE CASCADE,

    CONSTRAINT `eeg_entidad_fk`
        FOREIGN KEY (`id_entidad_genetica`)
        REFERENCES `entidad_genetica`(`id_entidad_genetica`)
        ON DELETE CASCADE
);

-- ============================================================
-- INSERCIÓN DE DATOS DE PRUEBA
-- Datos reales de Klebsiella pneumoniae
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. entidad_genetica
-- IDs 1,2,5 → genes | IDs 3,4 → variantes
-- ────────────────────────────────────────────────────────────
INSERT INTO `entidad_genetica` (`fecha_registro`, `especie`, `version_genoma`) VALUES
('2023-03-15', 'Klebsiella pneumoniae', 'GCF_000240185.2'),  -- id 1 → gen blaKPC-2
('2023-03-15', 'Klebsiella pneumoniae', 'GCF_000240185.2'),  -- id 2 → gen ompK35
('2023-06-20', 'Klebsiella pneumoniae', 'GCF_000240185.2'),  -- id 3 → variante SNP blaKPC-2
('2023-06-20', 'Klebsiella pneumoniae', 'GCF_000240185.2'),  -- id 4 → variante deleción ompK35
('2024-01-10', 'Klebsiella pneumoniae', 'GCF_000240185.2');  -- id 5 → gen blaOXA-48

-- ────────────────────────────────────────────────────────────
-- 2. Gen
-- ────────────────────────────────────────────────────────────
INSERT INTO `Gen` (`id_entidad_genetica`, `nombre`, `descripcion`, `posicion_cromosomica`, `orientacion`) VALUES
(1, 'blaKPC-2',  'Beta-lactamasa de clase A que confiere resistencia a carbapenems. Localizada en plásmido conjugativo Tn4401.',                                    'plasmido_pKpQIL:1', '+'),
(2, 'ompK35',    'Porina de membrana externa implicada en la permeabilidad a betalactámicos. Su pérdida aumenta la resistencia a carbapenems.',                     'chr:4521300',       '-'),
(5, 'blaOXA-48', 'Beta-lactamasa de clase D con actividad carbapenemasa débil, frecuentemente asociada a plásmidos IncL/M en enterobacterias clínicas.',            'plasmido_pOXA48:1', '+');

-- ────────────────────────────────────────────────────────────
-- 3. secuencia  (id_gen hace referencia a los IDs de Gen: 1, 2, 3)
-- ────────────────────────────────────────────────────────────
INSERT INTO `secuencia` (`id_gen`, `posicion_gen`, `cadena_adn`, `tipo`) VALUES
(1, 1, 'ATGAGCGCTTTTGTAGTGGCGATAACGGCCTTTTTGCGCTTTTCGCTGACGCTTTTGTGGTGGCGATAACGGCC', 'promotor'),
(1, 2, 'ATGTTCGAATTTTTGGGCGATGCTTTTGCGCTTTTCGCTGACGCTGTTGGTGGCGATGCTTTTGCGCTTTTCGC', 'CDS'),
(2, 1, 'ATGAAGAAGTTTACAATCCTGTTTGCAATGGGCGCATTTTTTGGTGCGGCAGCTGCAGCAGCAGCAGCAGCAGCT', 'CDS'),
(2, 2, 'GCAGTTGAAGGTAAAGCAACAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCA', 'exon'),
(3, 1, 'ATGGAAATAAAAGCACTGTTATTAGCGATTTTTGCGTTATTCGCAGCAGCAGCAGCAGCAGCAGCAGCAGCAGCA', 'CDS');

-- ────────────────────────────────────────────────────────────
-- 4. variante  (id_entidad_genetica 3 y 4, reservados arriba)
-- ────────────────────────────────────────────────────────────
INSERT INTO `variante` (
    `id_entidad_genetica`, `id_gen`, `posicion_gen`, `posicion_en_gen`,
    `alelo_referencia`, `alelo_mutado`, `tipo_variante`,
    `frecuencia_alelica`, `impacto_clinico`
) VALUES
(3, 1, 2, 532, 'G', 'A',  'SNP',      0.8700, 'Patogenica - sustitucion Asp178Asn aumenta actividad hidrolitica sobre imipenem'),
(4, 2, 1, 118, 'C', '-',  'delecion', 0.6300, 'Patogenica - frameshift provoca perdida de funcion de porina OmpK35');

-- ────────────────────────────────────────────────────────────
-- 5. anotacion
-- ────────────────────────────────────────────────────────────
INSERT INTO `anotacion` (`id_entidad_genetica`, `descripcion`, `tipo`) VALUES
(1, 'Gen blaKPC-2 catalogado en CARD con acceso ARO:3000013. Confiere resistencia a imipenem y meropenem.',                                                         'funcional'),
(2, 'Gen ompK35 asociado a reduccion de permeabilidad de membrana en cepas resistentes a carbapenems segun PATRIC.',                                                'funcional'),
(3, 'Variante SNP en posicion 532 de blaKPC-2 identificada en cepas del Hospital Universitario Ramon y Cajal. Impacto confirmado en ensayos de CMI.',               'clinica');

-- ────────────────────────────────────────────────────────────
-- 6. estudio  (referencia formato: aaaa → 4 letras, 111 → 3 dígitos)
-- ────────────────────────────────────────────────────────────
INSERT INTO `estudio` (`titulo`, `fecha_publicacion`, `referencia`, `doi`, `revista`) VALUES
('Genomic epidemiology of carbapenem-resistant Klebsiella pneumoniae in Spanish ICUs',
 '2022-09-14', 'AACC/001', '10.1128/AAC.00380-22', 'Antimicrobial Agents and Chemotherapy'),
('OmpK35 and OmpK36 porin loss as a mechanism of carbapenem resistance in clinical Klebsiella pneumoniae',
 '2021-04-03', 'IJAA/047', '10.1016/j.ijantimicag.2021.106317', 'International Journal of Antimicrobial Agents'),
('In silico prediction of antibiotic resistance from genomic variants in Klebsiella pneumoniae using machine learning',
 '2024-11-20', 'BIOI/112', '10.1093/bioinformatics/btae589', 'Bioinformatics');

-- ────────────────────────────────────────────────────────────
-- 7. autor_estudio
-- ────────────────────────────────────────────────────────────
INSERT INTO `autor_estudio` (`id_estudio`, `autor`) VALUES
(1, 'Martinez-Garcia L'),
(1, 'Giordano NP'),
(1, 'Canton R'),
(2, 'Domenech-Sanchez A'),
(2, 'Hernandez-Alles S'),
(3, 'Panera-Martinez S'),
(3, 'Garcia-Lopez R');

-- ────────────────────────────────────────────────────────────
-- 8. estudio_entidad_genetica  (tabla puente N:M)
-- ────────────────────────────────────────────────────────────
INSERT INTO `estudio_entidad_genetica` (`id_estudio`, `id_entidad_genetica`) VALUES
(1, 1),  -- estudio 1 → gen blaKPC-2
(1, 3),  -- estudio 1 → variante SNP de blaKPC-2
(2, 2),  -- estudio 2 → gen ompK35
(2, 4),  -- estudio 2 → variante delecion de ompK35
(3, 1),  -- estudio 3 → gen blaKPC-2
(3, 2),  -- estudio 3 → gen ompK35
(3, 5);  -- estudio 3 → entidad_genetica 5 (gen blaOXA-48)

-- ============================================================
-- CONSULTAS DE VERIFICACIÓN
-- ============================================================

-- Genes con su entidad genética
SELECT g.id_gen, g.nombre, g.orientacion, e.especie, e.version_genoma
FROM Gen g
JOIN entidad_genetica e ON g.id_entidad_genetica = e.id_entidad_genetica;

-- Secuencias de cada gen
SELECT g.nombre AS gen, s.posicion_gen, s.tipo,
       LEFT(s.cadena_adn, 30) AS cadena_inicio
FROM secuencia s
JOIN Gen g ON s.id_gen = g.id_gen
ORDER BY g.nombre, s.posicion_gen;

-- Variantes con su gen y secuencia asociada
SELECT g.nombre AS gen, v.posicion_en_gen, v.tipo_variante,
       v.alelo_referencia, v.alelo_mutado,
       v.frecuencia_alelica, v.impacto_clinico
FROM variante v
JOIN secuencia s  ON v.id_gen = s.id_gen AND v.posicion_gen = s.posicion_gen
JOIN Gen g        ON g.id_gen = s.id_gen;

-- Estudios con todos sus autores
SELECT e.titulo,
       GROUP_CONCAT(a.autor ORDER BY a.autor SEPARATOR ', ') AS autores
FROM estudio e
JOIN autor_estudio a ON e.id_estudio = a.id_estudio
GROUP BY e.id_estudio;

-- Entidades genéticas por estudio (solo genes, para nombres legibles)
SELECT e.titulo, g.nombre AS entidad
FROM estudio_entidad_genetica eg
JOIN estudio          e ON eg.id_estudio          = e.id_estudio
JOIN Gen              g ON eg.id_entidad_genetica = g.id_entidad_genetica
ORDER BY e.id_estudio;