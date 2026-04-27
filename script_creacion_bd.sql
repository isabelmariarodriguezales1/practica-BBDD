--Creacion base de datos
CREATE DATABASE bd_genomica;
USE bd_genomica;

--Tabla entidad genetica
CREATE TABLE Entidad_Genetica (
    id_entidad_genetica INT AUTO_INCREMENT,
    fecha_registro DATE,
    especie VARCHAR(100),
    version_genoma VARCHAR(50),
    PRIMARY KEY (id_entidad_genetica)
);

--Tabla Gen
CREATE TABLE Gen (
    id_gen INT AUTO_INCREMENT,
    id_entidad_genetica INT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    posicion_cromosomica VARCHAR(50),
    orientacion CHAR(1),

    PRIMARY KEY (id_gen),
    FOREIGN KEY (id_entidad_genetica)
        REFERENCES Entidad_Genetica(id_entidad_genetica)
        ON DELETE CASCADE
);

--Tabla Secuencia
CREATE TABLE Secuencia (
    id_gen INT,
    posicion_gen INT,
    cadena_adn VARCHAR(1000),
    tipo VARCHAR(50),

    PRIMARY KEY (id_gen, posicion_gen),

    FOREIGN KEY (id_gen)
        REFERENCES Gen(id_gen)
        ON DELETE CASCADE,

    CHECK (posicion_gen > 0),
    CHECK (CHAR_LENGTH(cadena_adn) BETWEEN 10 AND 1000)
);

--Tabla Variante
CREATE TABLE Variante (
    id_variante INT AUTO_INCREMENT,
    id_entidad_genetica INT,
    id_gen INT,
    posicion_gen INT,
    posicion_en_gen INT NOT NULL,
    alelo_referencia VARCHAR(10) DEFAULT '-',
    alelo_mutado VARCHAR(10) DEFAULT '-',
    tipo_variante VARCHAR(50),
    frecuencia_alelica DECIMAL(5,4),
    impacto_clinico VARCHAR(100),

    PRIMARY KEY (id_variante),

    FOREIGN KEY (id_entidad_genetica)
        REFERENCES Entidad_Genetica(id_entidad_genetica)
        ON DELETE CASCADE,

    FOREIGN KEY (id_gen, posicion_gen)
        REFERENCES Secuencia(id_gen, posicion_gen)
        ON DELETE CASCADE,

    CHECK (posicion_en_gen > 0)
);

--Tabla Anotacion
CREATE TABLE Anotacion (
    id_anotacion INT AUTO_INCREMENT,
    id_entidad_genetica INT,
    descripcion TEXT,
    tipo VARCHAR(50),

    PRIMARY KEY (id_anotacion),

    FOREIGN KEY (id_entidad_genetica)
        REFERENCES Entidad_Genetica(id_entidad_genetica)
        ON DELETE CASCADE
);

--Tabla Estudio
CREATE TABLE Estudio (
    id_estudio INT AUTO_INCREMENT,
    titulo VARCHAR(255),
    fecha_publicacion DATE,
    referencia VARCHAR(10),
    doi VARCHAR(100),
    revista VARCHAR(100),

    PRIMARY KEY (id_estudio),

    CHECK (referencia REGEXP '^[A-Za-z]{4}/[0-9]{3}$')
);

--Tabla intermedia entre estudio y entidad genetica
CREATE TABLE Estudio_Entidad_Genetica (
    id_estudio INT,
    id_entidad_genetica INT,

    PRIMARY KEY (id_estudio, id_entidad_genetica),

    FOREIGN KEY (id_estudio)
        REFERENCES Estudio(id_estudio)
        ON DELETE CASCADE,

    FOREIGN KEY (id_entidad_genetica)
        REFERENCES Entidad_Genetica(id_entidad_genetica)
        ON DELETE CASCADE
);

--Tabla autor_estudio
CREATE TABLE Autor_Estudio (
    id_estudio INT,
    autor VARCHAR(100),

    PRIMARY KEY (id_estudio, autor),

    FOREIGN KEY (id_estudio)
        REFERENCES Estudio(id_estudio)
        ON DELETE CASCADE
);
