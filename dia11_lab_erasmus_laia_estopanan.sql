CREATE DATABASE IF NOT EXISTS erasmus;

USE erasmus;

-- 1.¿Cuál es la edad promedio de los estudiantes que tienen calificaciones sobresalientes? Complete la tabla con EXCELENTE si tienen un 9 o un 10, BUENO si tienen un 7 u 8, APROBADO si tienen un 5 o un 6, y REPROBADO si tienen menos de 5.
-- paso 1: clasificar notas con CASE
SELECT
    CASE
        WHEN g.grades >= 9 THEN 'EXCELENTE'
        WHEN g.grades >= 7 THEN 'BUENO'
        WHEN g.grades >= 5 THEN 'APROBADO'
        ELSE 'REPROBADO'
    END AS Grade_Category,

    ROUND(
        AVG(TIMESTAMPDIFF(YEAR, s.dob, CURDATE())),
        0
    ) AS Average_Age
FROM students AS s
INNER JOIN grades AS g
    ON s.student_id = g.student_id
GROUP BY
    CASE
        WHEN g.grades >= 9 THEN 'EXCELENTE'
        WHEN g.grades >= 7 THEN 'BUENO'
        WHEN g.grades >= 5 THEN 'APROBADO'
        ELSE 'REPROBADO'
    END;
    
-- 2. ¿Cuál es la edad media de los estudiantes por universidad?
SELECT
    u.uni_name AS university_name,
    ROUND(
        AVG(TIMESTAMPDIFF(YEAR, s.dob, CURDATE())),
        0
    ) AS average_age
FROM students AS s
INNER JOIN campus AS c
    ON s.city = c.city
INNER JOIN university AS u
    ON c.university_id = u.university_id
GROUP BY
    u.university_id,
    u.uni_name
ORDER BY average_age DESC;

-- 3. ¿Cuál es la proporción de alumnos que suspendieron cada asignatura? Indique el nombre de la asignatura, el número de alumnos que suspendieron, el número total de alumnos y la proporción de alumnos que suspendieron (en porcentaje) para cada asignatura. Muestre los resultados en orden descendente según la proporción de alumnos que suspendieron.
SELECT
    s.subj_name AS Subject_Name,
    COUNT(
        CASE
            WHEN g.grades < 5 THEN 1
        END
    ) AS Number_of_Failures,
    COUNT(g.student_id) AS Number_of_Students,
    ROUND(
        COUNT(CASE WHEN g.grades < 5 THEN 1 END)
        * 100.0
        / COUNT(g.student_id),
        2
    ) AS Proportion_of_Failures
FROM subjects AS s
INNER JOIN grades AS g
    ON s.subject_id = g.subject_id
GROUP BY
    s.subject_id,
    s.subj_name
ORDER BY
    Proportion_of_Failures DESC;
    
-- 4. ¿Cuál es la nota media de los estudiantes que han realizado un Erasmus en comparación con los que no lo han hecho?
SELECT
    CASE
        WHEN ia.student_id IS NOT NULL THEN 'w_erasmus'
        ELSE 'wo_erasmus'
    END AS Erasmus_Status,

    AVG(g.grades) AS AVG_Grade

FROM students AS s

INNER JOIN grades AS g
    ON s.student_id = g.student_id

LEFT JOIN (
    SELECT DISTINCT student_id
    FROM international_agreement
) AS ia
    ON s.student_id = ia.student_id

GROUP BY
    CASE
        WHEN ia.student_id IS NOT NULL THEN 'w_erasmus'
        ELSE 'wo_erasmus'
    END;

-- 5. Para cada universidad, identifique el número de títulos de licenciatura, maestría y doctorado otorgados. Proporcione la identificación y el nombre de la universidad junto con el recuento de cada tipo de título.
SELECT
    u.university_id,
    u.uni_name,

    COUNT(
        CASE
            WHEN b.bachelor_id LIKE 'B%' THEN 1
        END
    ) AS Bachelor_Count,

    COUNT(
        CASE
            WHEN b.bachelor_id LIKE 'M%' THEN 1
        END
    ) AS Master_Count,

    COUNT(
        CASE
            WHEN b.bachelor_id LIKE 'D%' THEN 1
        END
    ) AS Phd_Count

FROM university AS u

LEFT JOIN bachelor AS b
    ON u.university_id = b.university_id

GROUP BY
    u.university_id,
    u.uni_name

ORDER BY
    u.university_id;
    
-- 6. ¿Cuáles son las 5 universidades con la clasificación media más alta a lo largo de los años? Indique el ID de la universidad, el nombre de la universidad y la clasificación media.
SELECT
    u.university_id AS University_ID,
    u.uni_name AS University_Name,
    ROUND(AVG(r.intl_ranking), 0) AS Average_Ranking

FROM university AS u

INNER JOIN ranking AS r
    ON u.university_id = r.university_id

GROUP BY
    u.university_id,
    u.uni_name

ORDER BY Average_Ranking DESC

LIMIT 5;

-- 7. Proporcione el número de identificación, el nombre, los apellidos, el nombre de la universidad de origen y el correo electrónico de los 10 estudiantes que hayan participado más veces en un acuerdo internacional.
SELECT
    s.student_id,
    s.f_name,
    s.l_name,
    u.uni_name AS Home_University,
    s.email,
    COUNT(ia.agreement_code) AS Agreement_Count

FROM students AS s

INNER JOIN international_agreement AS ia
    ON s.student_id = ia.student_id

INNER JOIN university AS u
    ON ia.home_university = u.university_id

GROUP BY
    s.student_id,
    s.f_name,
    s.l_name,
    u.uni_name,
    s.email

ORDER BY Agreement_Count DESC

LIMIT 10;

-- 8. Realice una consulta en la que, modificando el número de acuerdo internacional, pueda identificar el identificador y el nombre del estudiante que realizó el intercambio, el nombre de la universidad de origen y el nombre de la ciudad donde tuvo lugar el intercambio.
SELECT
    ia.agreement_code,
    s.student_id,
    s.f_name AS Student_First_Name,
    s.l_name AS Student_Last_Name,
    u_home.uni_name AS Home_University,
    u_away.uni_name AS Away_University
FROM international_agreement AS ia
INNER JOIN students AS s
    ON ia.student_id = s.student_id
INNER JOIN university AS u_home
    ON ia.home_university = u_home.university_id
INNER JOIN university AS u_away
    ON ia.away_university = u_away.university_id
WHERE ia.agreement_code = 'A2B9C';

-- Bonus: Ahora puede intentar utilizar procedimientos para parametrizar la consulta.
DELIMITER //

CREATE PROCEDURE BuscarAcuerdoErasmus(
    IN p_agreement_code VARCHAR(5)
)
BEGIN
    SELECT
        ia.agreement_code,
        s.student_id,
        s.f_name AS Student_First_Name,
        s.l_name AS Student_Last_Name,
        u_home.uni_name AS Home_University,
        u_away.uni_name AS Away_University
    FROM international_agreement AS ia
    INNER JOIN students AS s
        ON ia.student_id = s.student_id
    INNER JOIN university AS u_home
        ON ia.home_university = u_home.university_id
    INNER JOIN university AS u_away
        ON ia.away_university = u_away.university_id
    WHERE ia.agreement_code = p_agreement_code;
END //

DELIMITER ;

CALL BuscarAcuerdoErasmus('A2B9C');

-- 9. Busque y muestre el número de universidades que ofrecen cada asignatura, junto con la nota media de cada asignatura.
SELECT
    s.subj_name AS Subject,
    ROUND(AVG(g.grades), 0) AS Average_Grade,
    COUNT(DISTINCT us.university_id) AS Num_Universidades
FROM subjects AS s
LEFT JOIN grades AS g
    ON s.subject_id = g.subject_id
LEFT JOIN uni_subj AS us
    ON s.subject_id = us.subject_id
GROUP BY
    s.subject_id,
    s.subj_name
ORDER BY
    s.subj_name;

-- 10. Encuentre las 5 ciudades con el mayor porcentaje de estudiantes con calificaciones sobresalientes (9 o 10). Indique la ciudad, el estado y el porcentaje de estudiantes sobresalientes de cada ciudad.
SELECT
    s.city AS City,
    s.state AS State,
    ROUND(
        COUNT(CASE WHEN g.grades >= 9 THEN 1 END) * 100.0
        / COUNT(g.grades),
        2
    ) AS Percentage_Outstanding
FROM students AS s
INNER JOIN grades AS g
    ON s.student_id = g.student_id
GROUP BY
    s.city,
    s.state
ORDER BY
    Percentage_Outstanding DESC
LIMIT 5;

-- 11. Compara las universidades que envían más estudiantes con las universidades que reciben más estudiantes. Hazlo en dos consultas.
-- Universidades que más estudiantes envían
SELECT
    u.uni_name,
    COUNT(ia.student_id) AS sent_students
FROM university AS u
INNER JOIN international_agreement AS ia
    ON u.university_id = ia.home_university
GROUP BY
    u.university_id,
    u.uni_name
ORDER BY sent_students DESC
LIMIT 5;

-- Universidades que más estudiantes reciben
SELECT
    u.uni_name,
    COUNT(ia.student_id) AS received_students
FROM university AS u
INNER JOIN international_agreement AS ia
    ON u.university_id = ia.away_university
GROUP BY
    u.university_id,
    u.uni_name
ORDER BY received_students DESC
LIMIT 5;

-- Bonus: Ahora puede intentar unir ambas consultas utilizando el operador «UNION ALL».
(
    SELECT
        u.uni_name,
        COUNT(ia.student_id) AS sent_students,
        NULL AS received_students
    FROM university AS u
    INNER JOIN international_agreement AS ia
        ON u.university_id = ia.home_university
    GROUP BY
        u.university_id,
        u.uni_name
    ORDER BY sent_students DESC
    LIMIT 5
)

UNION ALL

(
    SELECT
        u.uni_name,
        NULL AS sent_students,
        COUNT(ia.student_id) AS received_students
    FROM university AS u
    INNER JOIN international_agreement AS ia
        ON u.university_id = ia.away_university
    GROUP BY
        u.university_id,
        u.uni_name
    ORDER BY received_students DESC
    LIMIT 5
);
