USE prework;
SHOW TABLES;
INSERT INTO rating (id, app_name, app_size, price, total_ratings, genre)
VALUES (281656475, 'PAC-MAN Premium', 100788224, 3.99, 4.5, 'Games');

INSERT INTO rating (id, app_name, app_size, price, total_ratings, genre)
VALUES (32165, 'Centipede', 99632342, 5.99, 3.7, 'Games');

INSERT INTO rating (id, app_name, app_size, price, total_ratings, genre)
VALUES (6549873, 'Dracula', 10243, 1.99, 4.9, 'Books');

TRUNCATE TABLE rating;
SELECT * FROM rating;
INSERT INTO rating (id, app_name, app_size, price, total_ratings, genre)
VALUES (281656475, 'PAC-MAN Premium', 100788224, 3.99, 4.5, 'Games');

INSERT INTO rating (id, app_name, app_size, price, total_ratings, genre)
VALUES (32165, 'Centipede', 99632342, 5.99, 3.7, 'Games');

INSERT INTO rating (id, app_name, app_size, price, total_ratings, genre)
VALUES (6549873, 'Dracula', 10243, 1.99, 4.9, 'Books');
SELECT * FROM rating;

SELECT SUM(price) AS total_price
FROM rating;

SELECT MAX(total_ratings) AS max_rating
FROM rating;

SELECT genre,
       AVG(price) AS average_price
FROM rating
GROUP BY genre;