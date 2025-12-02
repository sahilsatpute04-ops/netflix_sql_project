-- Netflix Project

CREATE TABLE netflix
(
	show_id	 VARCHAR(10),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director	VARCHAR(210),
	castS	VARCHAR(1000),
	country VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(20),
	listed_in	VARCHAR(150),
	description  VARCHAR(300)
)

SELECT * FROM netflix;

SELECT COUNT(*) AS total_count FROM netflix;

SELECT DISTINCT TYPE FROM netflix;



-- 15 Business Problems
-- 1) Count the number of Movies vs TV Shows
SELECT type, COUNT(*) AS total_type_count
FROM netflix
GROUP BY type;

-- 2) Find the most common rating for movies and TV shows
-- using subquery.
SELECT type, rating FROM(
SELECT type,
rating,
count(*) as total_type_rating_count ,
RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
from netflix
group by 1,2
) AS t1
WHERE ranking = 1

-- using cte
with cte AS (
	SELECT type,
	rating,
	count(*) as total_type_rating_count ,
	RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	from netflix
	group by 1,2
)
select type, rating from cte where ranking=1

-- 3. List all movies released in a specific year.(eg: 2020)
SELECT title, release_year FROM netflix
WHERE TYPE='Movie'
and release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix.
-- STRING_TO_ARRAY converts string to array 
-- UNNEST puts every value in array into a new row.
-- We do this here to split multiple countries in a new row
SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
COUNT(show_id) as total_count
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 5. Identify the longest movie.
select * from netflix
where type = 'Movie'
AND
duration = (SELECT MAX(duration) from netflix);

-- 6. Find content added in the last 5 years.
select *
from netflix 
where 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
-- Using wild card to find Rajiv Chilaka in the director
-- Instead of LIKE we use ILIKE which is not case sensitive and works even if rajiv chilaka is also present
select * from netflix
where director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons.
-- Uisng SPLIT_PART function it divides string into array and we can index it based on 1 based indexing.
SELECT * FROM netflix 
WHERE 	
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5;

-- 9.Count the number of content items in each genre.
select 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as each_genre,
count(show_id) as genre_count
from netflix
GROUP BY 1

-- 10. Find each year and the average numbers of content release by India on Netflix.
	-- Return top 5 year with highest avg content release.
select EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
COUNT(*) AS yearly_content,
ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY avg_content_per_year DESC
LIMIT 5;

-- 11. List all the movies that are documentaries.
select title, genre_type from
(
select 
title,
TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre_type
from netflix)as t1
where genre_type = 'Documentaries';

-- 12. Find all content without a director.
select * from netflix
where director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years.
select 
*
from netflix
where casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT individual_actor, COUNT(*) as movie_count FROM(
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS individual_actor
	FROM netflix
	WHERE type = 'Movie'
	AND country = 'India'
)
GROUP BY individual_actor
ORDER BY movie_count DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in
-- the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'.
-- Count how many items fall into each category.
WITH cte AS(
	select *,
	CASE WHEN 
	description ILIKE '%kill%' OR 
	description ILIKE '%violence%' THEN 'Bad_Content'
	ELSE 'Good_Content'
	END category
	from netflix
)
SELECT category, COUNT(*) AS total_content
FROM cte
GROUP BY category;