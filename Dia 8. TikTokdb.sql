CREATE DATABASE TikTokDB;
USE TikTokDB;
SELECT DATABASE();

CREATE TABLE Usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    fecha_registro DATE NOT NULL,
    pais VARCHAR(50) NOT NULL
);
DESCRIBE Usuarios;

CREATE TABLE Videos (
    video_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    fecha_publicacion DATE NOT NULL,
    duracion_segundos INT NOT NULL,
    
    FOREIGN KEY (usuario_id)
    REFERENCES Usuarios(usuario_id)
);

DESCRIBE Videos;

CREATE TABLE Comentarios (
    comentario_id INT AUTO_INCREMENT PRIMARY KEY,
    video_id INT NOT NULL,
    usuario_id INT NOT NULL,
    texto VARCHAR(255) NOT NULL,
    fecha_comentario DATE NOT NULL,
    
    FOREIGN KEY (video_id)
    REFERENCES Videos(video_id),
    
    FOREIGN KEY (usuario_id)
    REFERENCES Usuarios(usuario_id)
);

DESCRIBE Comentarios;

CREATE TABLE Likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    video_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_like DATE NOT NULL,
    
    FOREIGN KEY (video_id)
    REFERENCES Videos(video_id),
    
    FOREIGN KEY (usuario_id)
    REFERENCES Usuarios(usuario_id)
);

CREATE TABLE Seguidores (
    seguidor_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_seguidor_id INT NOT NULL,
    usuario_seguido_id INT NOT NULL,
    fecha_seguimiento DATE NOT NULL,
    
    FOREIGN KEY (usuario_seguidor_id)
    REFERENCES Usuarios(usuario_id),
    
    FOREIGN KEY (usuario_seguido_id)
    REFERENCES Usuarios(usuario_id)
);

SHOW TABLES;

INSERT INTO Usuarios
(nombre_usuario, email, fecha_registro, pais)
VALUES
('laia_data', 'laia@email.com', '2026-09-01', 'España'),
('maria88', 'maria@email.com', '2026-09-02', 'España'),
('john_tiktok', 'john@email.com', '2026-09-03', 'Estados Unidos'),
('pierre75', 'pierre@email.com', '2026-09-04', 'Francia'),
('giulia_roma', 'giulia@email.com', '2026-09-05', 'Italia');

SELECT * FROM Usuarios;

INSERT INTO Videos
(usuario_id, titulo, descripcion, fecha_publicacion, duracion_segundos)
VALUES
(1, 'Aprendiendo SQL', 'Mi primer vídeo sobre SQL', '2026-09-06', 45),
(1, 'Mi dashboard', 'Dashboard creado en Excel', '2026-09-07', 30),
(2, 'Viaje a Barcelona', 'Un día visitando Barcelona', '2026-09-07', 50),
(3, 'Basketball tricks', 'Trucos de baloncesto', '2026-09-08', 25),
(4, 'Paris vlog', 'Visitando París', '2026-09-09', 60);

SELECT * FROM Videos;

INSERT INTO Comentarios
(video_id, usuario_id, texto, fecha_comentario)
VALUES
(1, 2, 'Muy buen vídeo de SQL', '2026-09-07'),
(1, 3, 'Me ha resultado muy útil', '2026-09-07'),
(2, 4, 'Muy buen dashboard', '2026-09-08'),
(3, 1, 'Barcelona es preciosa', '2026-09-08'),
(4, 5, 'Buenísimo el vídeo', '2026-09-09');

SELECT * FROM Comentarios;

INSERT INTO Likes
(video_id, usuario_id, fecha_like)
VALUES
(1, 2, '2026-09-07'),
(1, 3, '2026-09-07'),
(1, 4, '2026-09-08'),
(2, 3, '2026-09-08'),
(2, 5, '2026-09-09'),
(3, 1, '2026-09-09'),
(4, 2, '2026-09-10'),
(5, 1, '2026-09-10');

SELECT * FROM Likes;

INSERT INTO Seguidores
(usuario_seguidor_id, usuario_seguido_id, fecha_seguimiento)
VALUES
(2, 1, '2026-09-07'),
(3, 1, '2026-09-07'),
(4, 1, '2026-09-08'),
(1, 2, '2026-09-08'),
(1, 3, '2026-09-09'),
(5, 1, '2026-09-10');

-- Consultas --

SELECT *
FROM Usuarios;

SELECT *
FROM Videos;

SELECT *
FROM Comentarios;

SELECT *
FROM Likes;

SELECT *
FROM Seguidores;

-- 3 Queries --

-- nº like por video --

SELECT
    Videos.titulo,
    COUNT(Likes.like_id) AS total_likes
FROM Videos
LEFT JOIN Likes
    ON Videos.video_id = Likes.video_id
GROUP BY Videos.video_id, Videos.titulo
ORDER BY total_likes DESC;

-- contar seguidores de cada usuario --

SELECT
    Usuarios.nombre_usuario,
    COUNT(Seguidores.seguidor_id) AS total_seguidores
FROM Usuarios
LEFT JOIN Seguidores
    ON Usuarios.usuario_id = Seguidores.usuario_seguido_id
GROUP BY Usuarios.usuario_id, Usuarios.nombre_usuario
ORDER BY total_seguidores DESC;

-- usuarios españoles --

SELECT
    nombre_usuario,
    email,
    pais
FROM Usuarios
WHERE pais = 'España';

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'TikTokDB'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- comprobar relaciones --

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'TikTokDB'
  AND REFERENCED_TABLE_NAME IS NOT NULL;