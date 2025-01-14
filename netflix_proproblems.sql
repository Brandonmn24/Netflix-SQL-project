--Netflix Project
drop table if exists netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(6),
    type   VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(208),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(15),
    listed_in    VARCHAR(100),
    description  VARCHAR(250)
);


SELECT *FROM netflix;

SELECT
	COUNT(*) as total_content
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;


--Real world Problems
--1. Numbers of Movies vs TV Shows

SELECT 
	type,
	COUNT(*) as total_content
FROM netflix

GROUP BY type

--2. Find most common rating for movies and tv shows
SELECT
	type,
	rating
FROM 
(SELECT
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
from netflix
Group by 1,2) as t1
WHERE 
	ranking = 1
--Order by 1, 3 DESC

--3. List all movies released in 2020

--filter 2020
--movies

SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020
	
--4. Find the top 5 countries with the most content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, --gets rid of all duplicates and separates any entries with multiple countries
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC -- order by second column
LIMIT 5 -- limit the number of columns to 5 to find top 5

--5. Identify the longest Movie?

--Find all movie types that have the longest duration
SELECT *FROM netflix
WHERE 
	type = 'Movie'
	AND --Makes sure both conditions are met
	duration = (SELECT MAX(duration)) FROM netflix --Duration will be equal to the max movie duration from netflix table

--6. Find content added in the last 5 years
SELECT * --TO_DATE(date_added, 'Month DD, YYYY')-- Convert proper date format
FROM netflix
Where
	TO_DATE(date_added, 'Month DD, YYYY')>= CURRENT_DATE- INTERVAL '5 years' --Return 5 years old date

--7. Find all the movies/TV shows by director 'Steven Spielberg'

SELECT *FROM netflix
WHERE 
	director ILIKE '%Steven Spielberg%' -- ILIKE and % help cover cases where there are multiple directors
-- 11 Movies
--With LIKE it is still 11 but will help other cases

--8. List all Tv shows with more than 5 seasons
SELECT 
	* ,SPLIT_PART(duration,' ', 1) as seasons --SPLIT_PART(column, delimiter, where before or after delimiter)
	-- In this example we are selecting from duration column and we want to split at the space
	-- Only want the number so take everything before the first space
FROM netflix

--Answer
SELECT *FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration,' ', 1)::numeric >  5 


--9. Counter the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1


-- 10. Find each year and the average numbers of content release by India on netflix.
-- Return 5 year with highest avg content release

--total content 333/972
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD YYYY')) as year,
	COUNT(*) as yearly_content,
	Round(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix where country = 'India')::numeric *100, 2) as avg_content
	
FROM netflix
WHERE country = 'India'
GROUP BY 1

--11 List all movies that are documentaries
SELECT * FROM netflix
WHERE 
	listed_in ILIKE '%documentaries%'; --finds all instances with documentaries do not need to split listed_in because of ILIKE 

--12 Find all content without a director
SELECT * FROM netflix
WHERE
	director IS NULL;

--13. Find how many movies actor 'Salman Khan' appear in last 10 years
SELECT * FROM netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) -10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in France
SELECT 
--show_id,
--casts,
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%france%'
Group by 1
ORDER BY 2 DESC
LIMIT 10;

--15. Categorize the content based on keywords 'kill' and 'violence' in description field. Label content containing keywords 'Bad' and all other content as 'good' count how many items fall into each category
WITH new_table
AS
(
SELECT 
	*,
	CASE
	WHEN 
		description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
	ELSE 'Good'
	END category
FROM netflix
)
SELECT
	category,
	COUNT(*) as total_content
FROM new_table
GROUP by 1