CREATE DATABASE proyecto_musical;
Use proyecto_musical;


-- Tabla de artistas
CREATE TABLE id_artistas (
    id_artista  SMALLINT PRIMARY KEY,
    artista     VARCHAR(100) 
);

-- Tabla de discográficas
CREATE TABLE id_discografica (
    id_discografica SMALLINT PRIMARY KEY,
    discografica    VARCHAR(100) 
);

-- Tabla de géneros
CREATE TABLE id_genero (
    id_genero   SMALLINT PRIMARY KEY,
    genero      VARCHAR(50) 
);

-- Tabla de discos
CREATE TABLE id_disco (
    id_disco   SMALLINT PRIMARY KEY,
    disco      VARCHAR(100) 
);

-- Tabla principal de canciones
CREATE TABLE cancion (
    id_cancion  SMALLINT PRIMARY KEY,
    cancion  VARCHAR(100) ,
    duracion    TIME ,
    coste SMALLINT,
    id_genero   SMALLINT,
    id_disco    SMALLINT,
    id_autor SMALLINT,
    id_discografica SMALLINT,
    FOREIGN KEY (id_genero) REFERENCES id_genero(id_genero),
    FOREIGN KEY (id_autor) REFERENCES id_artistas(id_artista),
    FOREIGN KEY (id_disco)  REFERENCES id_disco(id_disco),
    FOREIGN KEY (id_discografica)  REFERENCES id_discografica(id_discografica)
);

-- Tabla artistas_cancion
CREATE TABLE artistas_cancion (
    id_artista  SMALLINT,
    id_cancion  SMALLINT,
    FOREIGN KEY (id_artista)  REFERENCES id_artistas(id_artista),
    FOREIGN KEY (id_cancion) REFERENCES cancion(id_cancion)
);


-- Tabla de popularidad
CREATE TABLE popularidad (
    id_cancion              SMALLINT,
    dia                     SMALLINT,
    reproducciones          INT,
    FOREIGN KEY (id_cancion) REFERENCES cancion(id_cancion));

-- Tabla de fecha de publicación
CREATE TABLE fecha_publicacion (
    id_cancion      SMALLINT,
    fecha_publicacion DATE,
    FOREIGN KEY (id_cancion) REFERENCES cancion(id_cancion)
);

-- Tabla de canciones en listas
CREATE TABLE listas (
    id_cancion  SMALLINT ,
    lista varchar(50),
    PRIMARY KEY (lista),
    FOREIGN KEY (id_cancion) REFERENCES cancion(id_cancion)
);

-- Tabla de favoritos (usuario + canción)
CREATE TABLE Favoritos (
    usuario  varchar(50),
    id_cancion  SMALLINT ,
    FOREIGN KEY (id_cancion) REFERENCES cancion(id_cancion)
);