CREATE TABLE `entidad_genetica`(
    `id_entidad_genetica` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `fecha_registro` DATETIME NULL,
    `especie` VARCHAR(100) NULL,
    `version_genoma` VARCHAR(50) NULL
);
CREATE TABLE `Gen`(
    `id_gen` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `id_entidad_genetica` INT NOT NULL,
    `nombre` VARCHAR(100) NOT NULL,
    `descripcion` TEXT NOT NULL,
    `posicion_cromosomica` VARCHAR(50) NULL,
    `orientacion` CHAR(1) NULL
);
ALTER TABLE
    `Gen` ADD UNIQUE `gen_nombre_unique`(`nombre`);
CREATE TABLE `secuencia`(
    `id_gen` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `posicion_gen` INT NOT NULL,
    `cadena_adn` VARCHAR(1000) NOT NULL,
    `tipo` VARCHAR(50) NULL,
    PRIMARY KEY(`posicion_gen`)
);
CREATE TABLE `variante`(
    `id_variante` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `id_entidad_genetica` INT NOT NULL,
    `id_gen` INT NOT NULL,
    `posicion_gen` INT UNSIGNED NOT NULL,
    `posicion_en_gen` INT NOT NULL,
    `alelo_referencia` VARCHAR(50) NULL,
    `alelo_mutado` VARCHAR(50) NULL,
    `tipo_variante` VARCHAR(50) NULL,
    `frecuencia_alelica` FLOAT(53) NULL,
    `impacto_clinico` VARCHAR(100) NULL
);
CREATE TABLE `anotacion`(
    `id_anotacion` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `id_entidad_genetica` INT NOT NULL,
    `descripcion` TEXT NULL,
    `tipo` VARCHAR(50) NULL
);
CREATE TABLE `estudio`(
    `id_estudio` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `titulo` VARCHAR(200) NULL,
    `fecha_publicacion` DATE NULL,
    `referencia` VARCHAR(20) NULL,
    `doi` VARCHAR(100) NULL,
    `revista` VARCHAR(100) NULL
);
CREATE TABLE `autor_estudio`(
    `id_estudio` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `autor` VARCHAR(150) NOT NULL,
    PRIMARY KEY(`autor`)
);
CREATE TABLE `estudio_entidad_genetica`(
    `id_estudio` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `id_entidad_genetica` INT NOT NULL,
    PRIMARY KEY(`id_entidad_genetica`)
);
ALTER TABLE
    `secuencia` ADD CONSTRAINT `secuencia_id_gen_foreign` FOREIGN KEY(`id_gen`) REFERENCES `Gen`(`id_gen`);
ALTER TABLE
    `estudio` ADD CONSTRAINT `estudio_id_estudio_foreign` FOREIGN KEY(`id_estudio`) REFERENCES `autor_estudio`(`id_estudio`);
ALTER TABLE
    `entidad_genetica` ADD CONSTRAINT `entidad_genetica_id_entidad_genetica_foreign` FOREIGN KEY(`id_entidad_genetica`) REFERENCES `variante`(`id_entidad_genetica`);
ALTER TABLE
    `estudio_entidad_genetica` ADD CONSTRAINT `estudio_entidad_genetica_id_entidad_genetica_foreign` FOREIGN KEY(`id_entidad_genetica`) REFERENCES `entidad_genetica`(`id_entidad_genetica`);
ALTER TABLE
    `variante` ADD CONSTRAINT `variante_id_gen_foreign` FOREIGN KEY(`id_gen`) REFERENCES `secuencia`(`id_gen`);
ALTER TABLE
    `estudio_entidad_genetica` ADD CONSTRAINT `estudio_entidad_genetica_id_estudio_foreign` FOREIGN KEY(`id_estudio`) REFERENCES `estudio`(`id_estudio`);
ALTER TABLE
    `Gen` ADD CONSTRAINT `gen_id_entidad_genetica_foreign` FOREIGN KEY(`id_entidad_genetica`) REFERENCES `entidad_genetica`(`id_entidad_genetica`);
ALTER TABLE
    `variante` ADD CONSTRAINT `variante_posicion_gen_foreign` FOREIGN KEY(`posicion_gen`) REFERENCES `secuencia`(`posicion_gen`);
ALTER TABLE
    `entidad_genetica` ADD CONSTRAINT `entidad_genetica_id_entidad_genetica_foreign` FOREIGN KEY(`id_entidad_genetica`) REFERENCES `anotacion`(`id_entidad_genetica`);