CREATE DATABASE IF NOT EXISTS Restaurante;

USE Restaurante;
SELECT DATABASE();

-- Crear tabla de ventas
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id CHAR(1) NOT NULL,
    order_date DATE NOT NULL,
    product_id INT NOT NULL
);

-- Tabla menu
CREATE TABLE menu (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    price INT NOT NULL
);

-- Tabla members
CREATE TABLE members (
    customer_id CHAR(1) PRIMARY KEY,
    join_date DATE NOT NULL
);

-- Insertar datos
-- ventas
INSERT INTO sales (customer_id, order_date, product_id)
VALUES
    ('A', '2021-01-01', 1),
    ('A', '2021-01-01', 2),
    ('A', '2021-01-07', 2),
    ('A', '2021-01-10', 3),
    ('A', '2021-01-11', 3),
    ('A', '2021-01-11', 3),
    ('B', '2021-01-01', 2),
    ('B', '2021-01-02', 2),
    ('B', '2021-01-04', 1),
    ('B', '2021-01-11', 1),
    ('B', '2021-01-16', 3),
    ('B', '2021-02-01', 3),
    ('C', '2021-01-01', 3),
    ('C', '2021-01-01', 3),
    ('C', '2021-01-07', 3);
    
    -- menu
    INSERT INTO menu (product_id, product_name, price)
VALUES
    (1, 'sushi', 10),
    (2, 'curry', 15),
    (3, 'ramen', 12);
    
    -- miembros
    INSERT INTO members (customer_id, join_date)
VALUES
    ('A', '2021-01-07'),
    ('B', '2021-01-09');
    
    -- establecer relaciones
    ALTER TABLE sales
ADD CONSTRAINT fk_sales_menu
FOREIGN KEY (product_id)
REFERENCES menu(product_id);

SHOW TABLES;

-- PREGUNTAS
-- 1. ¿Cuál es la cantidad total que gastó cada cliente en el restaurante?
SELECT
    s.customer_id,
    SUM(m.price) AS total_spent
FROM sales AS s
INNER JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 2. ¿Cuántos días ha visitado cada cliente el restaurante?
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id
ORDER BY visit_days DESC;

-- 3. ¿Cuál fue el primer artículo del menú comprado por cada cliente?
WITH first_orders AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date
        ) AS order_rank
    FROM sales AS s
    INNER JOIN menu AS m
        ON s.product_id = m.product_id
)
SELECT DISTINCT
    customer_id,
    product_name
FROM first_orders
WHERE order_rank = 1
ORDER BY customer_id, product_name;

-- 4. ¿Cuál es el artículo más comprado en el menú y cuántas veces lo compraron todos los clientes?
SELECT
	m.product_name,
    COUNT(*) AS nº_veces_comprado
FROM sales AS s
INNER JOIN menu AS m
	ON s.product_id = m.product_id
GROUP BY m.product_id, m.product_name
ORDER BY nº_veces_comprado DESC
LIMIT 1;

-- 5. ¿Qué artículo fue el más popular para cada cliente?
WITH product_counts AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS purchase_count
    FROM sales AS s
    INNER JOIN menu AS m
        ON s.product_id = m.product_id
    GROUP BY
        s.customer_id,
        m.product_id,
        m.product_name
),
ranked_products AS (
    SELECT
        customer_id,
        product_name,
        purchase_count,
        DENSE_RANK() OVER (
            PARTITION BY customer_id
            ORDER BY purchase_count DESC
        ) AS product_rank
    FROM product_counts
)
SELECT
    customer_id,
    product_name,
    purchase_count
FROM ranked_products
WHERE product_rank = 1
ORDER BY customer_id, product_name;

-- 6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
WITH purchases_after_membership AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date
        ) AS purchase_rank
    FROM sales AS s
    INNER JOIN members AS mb
        ON s.customer_id = mb.customer_id
    INNER JOIN menu AS m
        ON s.product_id = m.product_id
    WHERE s.order_date >= mb.join_date
)
SELECT DISTINCT
    customer_id,
    order_date,
    product_name
FROM purchases_after_membership
WHERE purchase_rank = 1
ORDER BY customer_id;

-- 7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
WITH purchases_before_membership AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date DESC
        ) AS purchase_rank
    FROM sales AS s
    INNER JOIN members AS mb
        ON s.customer_id = mb.customer_id
    INNER JOIN menu AS m
        ON s.product_id = m.product_id
    WHERE s.order_date < mb.join_date
)
SELECT DISTINCT
    customer_id,
    order_date,
    product_name
FROM purchases_before_membership
WHERE purchase_rank = 1
ORDER BY customer_id, product_name;

-- 8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
SELECT
    s.customer_id,
    COUNT(*) AS total_items,
    SUM(m.price) AS total_spent
FROM sales AS s
INNER JOIN members AS mb
    ON s.customer_id = mb.customer_id
INNER JOIN menu AS m
    ON s.product_id = m.product_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos 2x, ¿Cuántos puntos tendría cada cliente?
-- Suposición: Solo los clientes que son miembros reciben puntos al comprar artículos, los puntos los reciben en las órdenes iguales o posteriores a la fecha en la que se convierten en miembros.
 SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN m.product_name = 'sushi'
                THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points
FROM sales AS s
INNER JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id; 

-- 10. En la primera semana después de que un cliente se une al programa (incluida la fecha de ingreso), gana el doble de puntos en todos los artículos, no solo en sushi. ¿Cuántos puntos tienen los clientes A y B a fines de enero?
SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN mb.join_date
                                  AND DATE_ADD(mb.join_date, INTERVAL 6 DAY)
                THEN m.price * 20

            WHEN m.product_name = 'sushi'
                THEN m.price * 20

            ELSE m.price * 10
        END
    ) AS total_points
FROM sales AS s
INNER JOIN members AS mb
    ON s.customer_id = mb.customer_id
INNER JOIN menu AS m
    ON s.product_id = m.product_id
WHERE s.order_date >= mb.join_date
  AND s.order_date < '2021-02-01'
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 11. Suposición: Solo los clientes que son miembros reciben puntos al comprar artículos, los puntos los reciben en las órdenes iguales o posteriores a la fecha en la que se convierten en miembros. Solo las órdenes de la primera semana en la que se convierten en miembros suman 20 puntos para todos los artículos.
SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN mb.join_date
                                  AND DATE_ADD(mb.join_date, INTERVAL 6 DAY)
            THEN m.price * 20
            ELSE 0
        END
    ) AS total_points
FROM sales AS s
INNER JOIN members AS mb
    ON s.customer_id = mb.customer_id
INNER JOIN menu AS m
    ON s.product_id = m.product_id
WHERE s.order_date >= mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;


