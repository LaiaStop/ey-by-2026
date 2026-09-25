USE bands;

SHOW TABLES;

-- CONSULTA 1
-- ¿Qué músico ha pertenecido a más bandas?
SELECT
	mn.musician_id,
	mn.musician_name,
    COUNT(DISTINCT bm.band_id) as Total_bandas
FROM musician_name mn
INNER JOIN band_musician bm
	ON mn.musician_id = bm.musician_id
GROUP BY mn.musician_id, mn.musician_name
ORDER BY Total_bandas DESC

-- CONSULTA 2
-- ¿Qué músico ha participado en más albumes?
SELECT
    m.musician_id,
    GROUP_CONCAT(
        DISTINCT mn.musician_name
        SEPARATOR ', '
    ) AS musician_name,
    COUNT(DISTINCT a.album_id) AS total_albums
FROM musician m
INNER JOIN band_musician bm
    ON m.musician_id = bm.musician_id
INNER JOIN album a
    ON bm.band_id = a.band_id
INNER JOIN musician_name mn
    ON m.musician_id = mn.musician_id
GROUP BY m.musician_id
ORDER BY total_albums DESC
LIMIT 10;

-- CONSULTA 3
-- ¿Qué banda ha hecho más discos?
SELECT
    b.band_id,
    b.band_name,
    COUNT(a.album_id) AS total_albums
FROM band b
INNER JOIN album a
    ON b.band_id = a.band_id
GROUP BY b.band_id, b.band_name
ORDER BY total_albums DESC
LIMIT 10;

