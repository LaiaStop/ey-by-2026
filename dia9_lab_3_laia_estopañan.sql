-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS ZaraBusiness;
USE ZaraBusiness;

-- Tabla de Clientes
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_cliente VARCHAR(100),
    email_cliente VARCHAR(100),
    ciudad VARCHAR(100),
    pais VARCHAR(100)
);

-- Tabla de Tiendas
CREATE TABLE Tiendas (
    id_tienda INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tienda VARCHAR(100),
    direccion VARCHAR(255),
    ciudad VARCHAR(100),
    pais VARCHAR(100)
);

-- Tabla de Empleados
CREATE TABLE Empleados (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empleado VARCHAR(100),
    puesto VARCHAR(100),
    tienda_id INT,
    fecha_contratacion DATE,
    FOREIGN KEY (tienda_id) REFERENCES Tiendas(id_tienda)
);

-- Tabla de Prendas de Ropa
CREATE TABLE Prendas (
    id_prenda INT AUTO_INCREMENT PRIMARY KEY,
    tipo_prenda VARCHAR(100),
    talla VARCHAR(10),
    color VARCHAR(50),
    precio DECIMAL(10, 2)
);

-- Tabla de Compras
CREATE TABLE Compras (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    fecha_compra DATE,
    monto_total DECIMAL(10, 2),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- Insertar datos en la tabla Clientes
INSERT INTO Clientes (nombre_cliente, email_cliente, ciudad, pais)
VALUES
('Carlos Ramírez', 'carlos.ramirez@email.com', 'Madrid', 'España'),
('Laura González', 'laura.gonzalez@email.com', 'Barcelona', 'España'),
('Andrés García', 'andres.garcia@email.com', 'Valencia', 'España'),
('Lucía Martínez', 'lucia.martinez@email.com', 'Sevilla', 'España'),
('Miguel Torres', 'miguel.torres@email.com', 'Zaragoza', 'España');

-- Insertar datos en la tabla Tiendas
INSERT INTO Tiendas (nombre_tienda, direccion, ciudad, pais)
VALUES
('Zara Gran Vía', 'Calle Gran Vía, 32', 'Madrid', 'España'),
('Zara Portal de l\'Àngel', 'Portal de l\'Àngel, 10', 'Barcelona', 'España'),
('Zara Calle de Colón', 'Calle de Colón, 20', 'Valencia', 'España'),
('Zara Calle Sierpes', 'Calle Sierpes, 40', 'Sevilla', 'España'),
('Zara Paseo de la Independencia', 'Paseo de la Independencia, 5', 'Zaragoza', 'España');

-- Insertar datos en la tabla Empleados
INSERT INTO Empleados (nombre_empleado, puesto, tienda_id, fecha_contratacion)
VALUES
('Juan Pérez', 'Vendedor', 1, '2022-01-10'),
('María López', 'Gerente', 2, '2021-11-15'),
('Carlos Fernández', 'Vendedor', 3, '2023-02-01'),
('Ana García', 'Encargada', 4, '2023-05-25'),
('Luis Martínez', 'Vendedor', 5, '2023-06-10');

-- Insertar datos en la tabla Prendas
INSERT INTO Prendas (tipo_prenda, talla, color, precio)
VALUES
('Camiseta', 'M', 'Negro', 19.99),
('Pantalón', 'L', 'Azul', 39.99),
('Chaqueta', 'S', 'Rojo', 59.99),
('Falda', 'M', 'Verde', 29.99),
('Zapatos', '42', 'Negro', 49.99),
('Vestido', 'L', 'Blanco', 59.99),
('Camisa', 'M', 'Azul', 29.99),
('Abrigo', 'L', 'Gris', 89.99),
('Shorts', 'S', 'Rosa', 24.99),
('Sudadera', 'XL', 'Negro', 34.99);

-- Insertar datos en la tabla Compras
INSERT INTO Compras (id_cliente, fecha_compra, monto_total)
VALUES
(1, '2023-04-01', 100.50),
(2, '2023-05-15', 59.99),
(3, '2023-06-20', 75.00),
(4, '2023-07-18', 120.00),
(5, '2023-08-10', 99.99),
(1, '2023-09-01', 200.00),
(2, '2023-09-10', 150.00),
(3, '2023-09-15', 50.00),
(4, '2023-09-20', 90.00),
(5, '2023-09-25', 30.00);


/* =====================================================================
   EXTENSIÓN DEL ESQUEMA (INICIO)  -  datos inventados, solo para probar
   Necesaria para los puntos 3, 5, 6, 8, 9, 10, 14, 16, 18, 20 y 27.
   Supuestos:
     - Cada compra la gestiona un empleado en una tienda. Se supone que
       cada cliente compra siempre en la tienda cuyo id coincide con el
       suyo (cliente 1 -> tienda 1, ...) y que la atiende el único
       empleado de esa tienda (empleado 1 -> tienda 1, ...).
     - Cada compra incluye una o dos prendas, con su cantidad.
     - Los importes de Detalle_Compras NO coinciden con monto_total (los
       montos originales no se pueden obtener sumando los precios de las
       prendas): monto_total se sigue usando para los ingresos.
   ===================================================================== */

ALTER TABLE Compras
    ADD COLUMN id_empleado INT,
    ADD COLUMN id_tienda   INT,
    ADD FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado),
    ADD FOREIGN KEY (id_tienda)   REFERENCES Tiendas(id_tienda);

/* El WHERE con la clave primaria (id_compra > 0) no cambia el resultado
   (afecta a todas las compras), pero evita el error 1175 del "modo de
   actualización segura" de MySQL Workbench. */
UPDATE Compras
SET id_tienda   = id_cliente,
    id_empleado = id_cliente
WHERE id_compra > 0;

CREATE TABLE Detalle_Compras (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_compra  INT,
    id_prenda  INT,
    cantidad   INT,
    FOREIGN KEY (id_compra) REFERENCES Compras(id_compra),
    FOREIGN KEY (id_prenda) REFERENCES Prendas(id_prenda)
);

INSERT INTO Detalle_Compras (id_compra, id_prenda, cantidad)
VALUES
(1, 3, 1),   -- Chaqueta (Rojo)
(1, 1, 2),   -- Camiseta
(2, 6, 1),   -- Vestido
(3, 2, 1),   -- Pantalón
(3, 7, 1),   -- Camisa
(4, 8, 1),   -- Abrigo
(4, 5, 1),   -- Zapatos
(5, 10, 2),  -- Sudadera
(5, 5, 1),   -- Zapatos
(6, 3, 1),   -- Chaqueta (Rojo)
(6, 8, 1),   -- Abrigo
(7, 4, 2),   -- Falda
(7, 9, 1),   -- Shorts
(8, 1, 1),   -- Camiseta
(8, 5, 1),   -- Zapatos
(9, 3, 1),   -- Chaqueta (Rojo)
(9, 2, 1),   -- Pantalón
(10, 7, 1);  -- Camisa

/* =====================================================================
   EXTENSIÓN DEL ESQUEMA (FIN)
   ===================================================================== */
   
-- 1. Selecciona todos los clientes.
SELECT *
FROM clientes;

-- 2. Selecciona todos los empleados.
SELECT *
FROM empleados;

-- 3. Selecciona todas las tiendas.
SELECT *
FROM tiendas;

-- 4. Selecciona todas las prendas de ropa.
SELECT *
FROM prendas;

-- 5. Busca clientes cuyo nombre comience con la letra "L".
SELECT *
FROM clientes
WHERE nombre_cliente LIKE 'L%';

-- 6. Cuenta cuántos clientes hay en la base de datos.
SELECT COUNT(*) AS total_clientes
FROM clientes;

-- 7. Selecciona las compras realizadas después del 1 de mayo de 2023.
SELECT *
FROM compras
WHERE fecha_compra > '2023-05-01';

-- 8. Actualiza el correo electrónico de un cliente específico.
UPDATE Clientes
SET email_cliente = 'carloa.nuevo.especifico@email.com'
WHERE id_cliente = 1;

SELECT *
FROM Clientes
WHERE id_cliente = 1;


-- 9. Elimina un cliente por su ID.
DELETE FROM clientes
WHERE id_cliente = 5;

-- 10. Selecciona las prendas de color Negro.
SELECT *
FROM prendas
WHERE color = 'Negro';

-- 11. Selecciona todas las tiendas que hay en Madrid.
SELECT *
FROM tiendas
WHERE ciudad = 'Madrid';

-- 12. Cuenta cuántas prendas tienen un precio mayor a 50.
SELECT count(*) AS prendas_mayor_50
FROM PRENDAS
WHERE precio > 50;

-- 13. Selecciona los empleados que trabajan en la tienda con ID 1.
SELECT *
FROM empleados
WHERE id_empleado = 1;

-- 14. Busca clientes cuyo nombre contenga "Andrés".
SELECT *
FROM clientes
WHERE nombre_cliente LIKE '%Andrés%';

-- 15. Selecciona las compras realizadas por el cliente con ID 2.
SELECT *
FROM compras
WHERE id_cliente = 2;

-- 16. Elimina todas las compras cuyo monto sea menor a 30.
SELECT *
FROM Compras
WHERE monto_total < 30;

DELETE FROM Compras
WHERE monto_total < 30;

-- 17. Selecciona las prendas cuyo precio esté entre 20 y 40.
SELECT *
FROM prendas
WHERE precio BETWEEN 20 AND 40;

-- 18. Busca empleados cuyo nombre contenga la letra "a".
SELECT *
FROM empleados
WHERE nombre_empleado LIKE '%a%';

-- 19. Selecciona las 5 prendas más caras.
SELECT *
FROM prendas
ORDER BY precio DESC
LIMIT 5; 	

-- 20. Selecciona las compras de un cliente con un monto superior a 75.
SELECT *
FROM compras
WHERE id_cliente = 1
	AND monto_total < 75;
    
-- 21. Selecciona las prendas de talla M.
SELECT *
FROM prendas
WHERE talla = 'M';

-- 22. Actualiza la talla de una prenda específica por su ID.
UPDATE Prendas
SET talla = 'L'
WHERE id_prenda = 1;

-- 23. Selecciona todos los empleados contratados después del 1 de enero de 2022.
SELECT *
FROM empleados
WHERE fecha_contratacion > '2022-01-01';

-- 24. Busca tiendas en "Barcelona".
SELECT *
FROM tiendas
WHERE ciudad = 'Barcelona';

-- 25. Elimina un empleado por su ID.
DELETE FROM Empleados
WHERE id_empleado = 5;

-- 26. Selecciona las compras que se realizaron antes del 1 de julio de 2023.
SELECT *
FROM compras
WHERE fecha_compra < '2023-06-01';

-- 27. Busca prendas cuyo nombre termine en "eta".
SELECT *
FROM prendas
WHERE tipo_prenda LIKE '%eta';

-- 28. Selecciona los clientes que no tengan un email registrado con "hotmail".
SELECT *
FROM clientes
WHERE email_cliente NOT LIKE '%hotmail%';

-- 29. Cuenta cuántas compras se realizaron en septiembre de 2023.
SELECT count(*) AS compras_septiembre
FROM compras
WHERE fecha_compra >= '2023-09-01'
		and fecha_compra < '2023-10-01';
        
-- 30. Actualiza la dirección de una tienda por su ID.
UPDATE tiendas
SET direccion = 'Calle Gran Vía, 50'
WHERE id_tienda = 1;

SELECT *
FROM Tiendas
WHERE id_tienda = 1;

-- 31. Selecciona las prendas que sean camisetas.
SELECT *
FROM prendas
WHERE tipo_prenda = 'camiseta';

-- 32. Elimina todas las prendas cuyo precio sea menor a 20.
DELETE FROM prendas
WHERE precio < 20;

-- 33. Selecciona todas las tiendas y ordénalas por ciudad.
SELECT *
FROM tiendas
ORDER BY ciudad ASC;

-- 34. Selecciona los empleados que sean vendedores.
SELECT *
FROM empleados
WHERE puesto = 'vendedor';
-- 35. Cuenta cuántas prendas son de color blanco.
SELECT *
FROM prendas
WHERE color = 'Blanco';

-- 36. Selecciona los clientes que tengan nombres de más de 10 caracteres.
SELECT *
FROM Clientes
WHERE CHAR_LENGTH(nombre_cliente) > 10;

-- 37. Busca compras cuyo monto total esté entre 50 y 100.
SELECT *
FROM compras
WHERE monto_total BETWEEN 50 AND 100;

-- 38. Selecciona las 3 compras más recientes.
SELECT *
FROM compras
ORDER BY fecha_compra DESC
LIMIT 3;

-- 39. Busca cursos cuyo nombre contenga la palabra "Digital".
-- NO SE PUEDE HACER

-- 40. Agrupa las prendas por color y cuenta cuántas hay de cada color.
SELECT color,
count(*) AS cantidad_prendas
FROM prendas
GROUP BY color
ORDER BY cantidad_prendas DESC;

-- 41. Añade dos tiendas más que existan en Madrid y no estén en la base de datos.
INSERT INTO Tiendas
    (nombre_tienda, direccion, ciudad, pais)
VALUES
    ('Zara Preciados', 'Calle Preciados, 18', 'Madrid', 'España'),
    ('Zara Serrano', 'Calle Serrano, 23', 'Madrid', 'España');
    
-- 42. El cliente Miguel Torres se ha hecho trans y ha pedido que le cambien el nombre a Micaela. Actualiza también su e-mail.
UPDATE Clientes
SET nombre_cliente = 'Micaela Torres',
    email_cliente = 'micaela.torres@email.com'
WHERE nombre_cliente = 'Miguel Torres';