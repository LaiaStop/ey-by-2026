-- EJERCICIO 1

-- Contactos de oficina: Tiene una tabla que contiene los códigos de oficina y sus números de teléfono asociados.
SELECT
    officeCode,
    phone
FROM offices;

-- Detectives de correo electrónico: ¿Puede identificar a los empleados cuyas direcciones de correo electrónico terminan en “.es”?
SELECT
    employeeNumber,
    firstName,
    lastName,
    email
FROM employees
WHERE email LIKE '%.es';

-- Estado de confusión: descubra qué clientes carecen de información estatal en sus registros.
SELECT
    customerNumber,
    customerName,
    city,
    state,
    country
FROM customers
WHERE state IS NULL;

-- Grandes gastadores: busquemos pagos que superen los $20.000.
SELECT
    customerNumber,
    checkNumber,
    paymentDate,
    amount
FROM payments
WHERE amount > 20000
ORDER BY amount DESC;

-- Grandes gastadores de 2005: Ahora, acote la lista aún más y busque los pagos mayores a $20,000 que se realizaron en el año 2005.
SELECT
    customerNumber,
    checkNumber,
    paymentDate,
    amount
FROM payments
WHERE amount > 20000
  AND paymentDate >= '2005-01-01'
  AND paymentDate < '2006-01-01'
ORDER BY amount DESC;

-- Detalles distintos: busque y muestre solo las filas únicas de la tabla “orderdetails” en función de la columna “productcode”.
SELECT DISTINCT
	productCode
FROM orderdetails;

-- Estadísticas globales de compradores: por último, cree una tabla que muestre el recuento de compras realizadas por país.
SELECT
	COUNT(o.orderNumber) AS total_compras,
    c.country
FROM customers AS c
LEFT JOIN orders AS o
	ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY total_compras DESC;

-- EJERCICIO 2
-- Descripción de línea de producto más larga: descubramos qué línea de producto tiene la descripción de texto más larga.
SELECT
	productLine,
    char_length(textDescription) AS longitud_descripcion
FROM productlines
ORDER BY longitud_descripcion
LIMIT 1;

-- Recuento de clientes de oficina: ¿Puede determinar el número de clientes asociados a cada oficina?
SELECT
    o.officeCode,
    o.city,
    COUNT(c.customerNumber) AS total_clientes
FROM offices AS o
LEFT JOIN employees AS e
    ON o.officeCode = e.officeCode
LEFT JOIN customers AS c
    ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY
    o.officeCode,
    o.city
ORDER BY total_clientes DESC;

-- Día de mayores ventas de automóviles: descubra qué día de la semana se registra el mayor número de ventas de automóviles.
SELECT
    DAYNAME(o.orderDate) AS dia_semana,
    SUM(od.quantityOrdered) AS automoviles_vendidos
FROM orders AS o
INNER JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
INNER JOIN products AS p
    ON od.productCode = p.productCode
WHERE p.productLine IN ('Classic Cars', 'Vintage Cars')
GROUP BY
    DAYOFWEEK(o.orderDate),
    DAYNAME(o.orderDate)
ORDER BY automoviles_vendidos DESC
LIMIT 1;

-- Corrección de datos territoriales faltantes: Hay algunos valores faltantes (NA) en la variable " territory " de la tabla " offices ". Podemos usar una instrucción "case when" para corregir estos valores y establecerlos en " USA".
SELECT
    officeCode,
    city,
    country,
    territory,
    CASE
        WHEN territory = 'NA' THEN 'USA'
        ELSE territory
    END AS territory_corregido
FROM offices;

-- Estadísticas de empleados de la familia Patterson: calcule el monto promedio del carrito y el total de artículos, año por mes, para las compras realizadas en los años 2004 y 2005 por clientes asistidos por empleados de la familia Patterson.
SELECT
    YEAR(resumen.orderDate) AS ano,
    MONTH(resumen.orderDate) AS mes_numero,
    MONTHNAME(resumen.orderDate) AS mes,
    ROUND(AVG(resumen.total_carrito), 2) AS promedio_carrito,
    SUM(resumen.total_articulos) AS total_articulos
FROM (
    SELECT
        o.orderNumber,
        o.orderDate,
        SUM(od.quantityOrdered * od.priceEach) AS total_carrito,
        SUM(od.quantityOrdered) AS total_articulos
    FROM employees AS e
    INNER JOIN customers AS c
        ON e.employeeNumber = c.salesRepEmployeeNumber
    INNER JOIN orders AS o
        ON c.customerNumber = o.customerNumber
    INNER JOIN orderdetails AS od
        ON o.orderNumber = od.orderNumber
    WHERE e.lastName = 'Patterson'
      AND o.orderDate >= '2004-01-01'
      AND o.orderDate < '2006-01-01'
    GROUP BY
        o.orderNumber,
        o.orderDate
) AS resumen
GROUP BY
    YEAR(resumen.orderDate),
    MONTH(resumen.orderDate),
    MONTHNAME(resumen.orderDate)
ORDER BY
    ano,
    mes_numero;

-- Ejercicio 3 (Usar subconsultas)
-- Análisis de compras anuales: Analicemos algunos cálculos avanzados mediante subconsultas. Queremos encontrar el importe promedio del carrito y el total de artículos, desglosados por año y mes. Esto se aplica específicamente a las compras realizadas en los años 2004 y 2005, pero nos interesan los clientes atendidos por empleados de la familia Patterson.
SELECT
    resumen.anio,
    resumen.mes_numero,
    resumen.mes,
    ROUND(AVG(resumen.total_carrito), 2) AS promedio_carrito,
    SUM(resumen.total_articulos) AS total_articulos
FROM (
    SELECT
        o.orderNumber,
        YEAR(o.orderDate) AS anio,
        MONTH(o.orderDate) AS mes_numero,
        MONTHNAME(o.orderDate) AS mes,
        SUM(od.quantityOrdered * od.priceEach) AS total_carrito,
        SUM(od.quantityOrdered) AS total_articulos
    FROM orders AS o
    INNER JOIN orderdetails AS od
        ON o.orderNumber = od.orderNumber
    WHERE o.orderDate >= '2004-01-01'
      AND o.orderDate < '2006-01-01'
      AND o.customerNumber IN (
          SELECT c.customerNumber
          FROM customers AS c
          WHERE c.salesRepEmployeeNumber IN (
              SELECT e.employeeNumber
              FROM employees AS e
              WHERE e.lastName = 'Patterson'
          )
      )
    GROUP BY
        o.orderNumber,
        YEAR(o.orderDate),
        MONTH(o.orderDate),
        MONTHNAME(o.orderDate)
) AS resumen
GROUP BY
    resumen.anio,
    resumen.mes_numero,
    resumen.mes
ORDER BY
    resumen.anio,
    resumen.mes_numero;
    
-- Viaje a la oficina: ¡Llegó una misión especial! Visitaremos algunas de nuestras oficinas personalmente. Queremos identificar cuáles tienen empleados que atienden a clientes con información estatal vacía. Visitaremos estas oficinas para charlar y asegurarnos de que todo esté en orden.
SELECT
    officeCode,
    city,
    phone,
    country
FROM offices
WHERE officeCode IN (
    SELECT DISTINCT e.officeCode
    FROM employees AS e
    WHERE e.employeeNumber IN (
        SELECT DISTINCT c.salesRepEmployeeNumber
        FROM customers AS c
        WHERE c.state IS NULL
          AND c.salesRepEmployeeNumber IS NOT NULL
    )
);