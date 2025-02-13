--Observamos el top 15 de videojuegos más vendidos
SELECT * 
FROM game_sales
ORDER BY games_sold DESC
LIMIT 15;

--Creamos índices en las columnas que se usarán para
--optimizar las consultas, ya que se estarán usando repetidamente.
CREATE INDEX idx_game_sales_game ON game_sales(game);
CREATE INDEX idx_game_sales_year ON game_sales(year);
CREATE INDEX idx_game_sales_platform ON game_sales(platform);
CREATE INDEX idx_reviews_game ON reviews(game);
CREATE INDEX idx_reviews_scores ON reviews(critic_score, user_score);

--Investigamos aquellos juegos que no cuentan con reseñas.
SELECT 
    COUNT(DISTINCT gs.game)
FROM game_sales AS gs
LEFT JOIN reviews AS r
    ON gs.game = r.game
WHERE r.critic_score IS NULL
    AND r.user_score IS NULL;

--Creamos una tabla temporal almacenando aquellos juegos.
CREATE TEMP TABLE missing_reviews AS
SELECT 
    DISTINCT gs.game,
	r.critic_score,
	r.user_score
FROM game_sales AS gs
LEFT JOIN reviews AS r
    ON gs.game = r.game
WHERE r.critic_score IS NULL
    AND r.user_score IS NULL;

--Observamos los años en que las reseñas de los críticos sobresalieron
--junto con el número de juegos lanzados.
SELECT
    year,
	COUNT(DISTINCT gs.game) AS num_games,
    ROUND(AVG(r.critic_score), 2) AS avg_critic_score
FROM game_sales AS gs
INNER JOIN reviews AS r
    ON gs.game = r.game
WHERE gs.game NOT IN (SELECT game FROM missing_reviews)
	AND critic_score IS NOT NULL
GROUP BY year
ORDER BY avg_critic_score DESC
LIMIT 15;

--Ahora observamos los años en que las reseñas de los usuarios
--sobresalieron junto con el número de juegos lanzados.
SELECT
    year,
	COUNT(DISTINCT gs.game) AS num_games,
    ROUND(AVG(r.user_score), 2) AS avg_user_score
FROM game_sales AS gs
INNER JOIN reviews AS r
    ON gs.game = r.game
WHERE gs.game NOT IN (SELECT game FROM missing_reviews)
	AND user_score IS NOT NULL
GROUP BY year
ORDER BY avg_user_score DESC
LIMIT 15;

--Consideramos evaluar solo aquellos años donde haya más de 50 juegos
CREATE TEMP TABLE top_critics_reviews AS
SELECT
    year,
	COUNT(DISTINCT gs.game) AS num_games,
    ROUND(AVG(r.critic_score), 2) AS avg_critic_score
FROM game_sales AS gs
INNER JOIN reviews AS r
    ON gs.game = r.game
WHERE gs.game NOT IN (SELECT game FROM missing_reviews)
	AND critic_score IS NOT NULL
GROUP BY year
HAVING COUNT(DISTINCT gs.game) > 50
ORDER BY avg_critic_score DESC
LIMIT 15;

--Ahora observamos, usando el mismo criterio de la cantidad de juegos,
--los años donde las criticas de usuarios sobresalieron
CREATE TEMP TABLE top_users_reviews AS
SELECT
    year,
	COUNT(DISTINCT gs.game) AS num_games,
    ROUND(AVG(r.user_score), 2) AS avg_user_score
FROM game_sales AS gs
INNER JOIN reviews AS r
    ON gs.game = r.game
WHERE gs.game NOT IN (SELECT game FROM missing_reviews)
GROUP BY year
HAVING COUNT(DISTINCT gs.game) > 50
ORDER BY avg_user_score DESC
LIMIT 15;

--Observamos aquellos años en donde las reseñas de los usuarios y de
--los críticos sobresalieron
SELECT year AS top_years
FROM top_critics_reviews
INTERSECT
SELECT year
FROM top_users_reviews
ORDER BY top_years;

--Por último, observamos la cantidad de videojuegos vendidos en esos años
SELECT
	year,
	SUM(games_sold) AS total_sold
FROM game_sales
WHERE year IN (
	SELECT year
	FROM top_critics_reviews
	INTERSECT
	SELECT year
	FROM top_users_reviews
)
GROUP BY year
ORDER BY total_sold DESC;

--Observamos los años donde se vendieron más videojuegos, independientemente
--de las críticas.
SELECT
	year,
	SUM(games_sold) AS total_sold,
	ROUND(AVG(r.critic_score), 2) AS avg_critic_score,
	ROUND(AVG(r.user_score), 2) AS avg_user_score
FROM game_sales AS gs
INNER JOIN (
	SELECT 
		game, 
		AVG(critic_score) AS critic_score, 
		AVG(user_score) AS user_score
    FROM reviews
    GROUP BY game
) AS r ON gs.game = r.game
GROUP BY gs.year
ORDER BY total_sold DESC
LIMIT 8;

--Top 3 plataformas
SELECT
	platform,
	total_sold,
	rank
FROM (
	SELECT
		platform,
		SUM(games_sold) AS total_sold,
		RANK() OVER(ORDER BY SUM(games_sold) DESC)
	FROM game_sales
	GROUP BY platform
) AS sq
WHERE rank IN (1, 2, 3)

--Top 3 plataformas en años con mejores críticas 
SELECT
	platform,
	total_sold,
	rank
FROM (
	SELECT
		platform,
		SUM(games_sold) AS total_sold,
		RANK() OVER(ORDER BY SUM(games_sold) DESC)
	FROM game_sales
	WHERE year IN (
		SELECT year
		FROM top_critics_reviews
		INTERSECT
		SELECT year
		FROM top_users_reviews
	)
	GROUP BY platform
) AS sq
WHERE rank IN (1, 2, 3)