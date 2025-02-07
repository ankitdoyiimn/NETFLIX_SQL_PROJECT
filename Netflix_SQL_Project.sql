--To create a table netflix 
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

--Verifying the data import into the table
select* from netflix;

--Count the Number of Movies vs TV Shows
select type, count(*) from netflix group by 1;

--Find the Most Common Rating for Movies and TV Shows
SELECT type, rating from
(Select
	type,
	rating,
	count(*),
	RANK () OVER(partition by type order by count(*) desc) as ranking
From netflix
group by 1,2
order by 1,3 desc) as t1
where ranking=1

-- List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix WHERE release_year=2020

-- Count all the movies released in particular year
SELECT release_year, count(*) as total_content from netflix group by 1 order by 2 desc

-- Find the top three years where the most content was realeased on netflix
SELECT release_year, count(*) as total_content, RANK() OVER(order by count(*)desc) as content_rank 
from netflix 
group by 1 order by 3 limit 3;

--Find the Top 5 Countries with the Most Content on Netflix
SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) as countries,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1 ORDER BY 2 DESC LIMIT 5;

--Identify the Longest Movie
SELECT 
title as Movie_Name,
duration
FROM netflix
WHERE type = 'Movie' and duration is not null
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC LIMIT 1 ;

--Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT
title as name
FROM
(SELECT *, 
UNNEST(STRING_TO_ARRAY(director,',')) as director_name
FROM netflix) as t where t.director_name= 'Rajiv Chilaka';

--Count the Number of Content Items in Each Genre
SELECT
UNNEST(STRING_TO_ARRAY(listed_in,',')) as Genre,
count(*) as total_content
FROM netflix
GROUP by 1 ORDER by 2 Desc;

--Average number of content released in India each year and return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--List All Movies that are Documentaries
Select * FROM netflix
where listed_in LIKE '%Documentaries%';
-- incase the case should not be checked
Select * FROM netflix
where listed_in ILIKE '%documentaries%';

--Find All Content Without a Director
Select * FROM netflix
where director ISNULL;

--Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * FROM netflix 
	Where casts ILIKE '%Salman Khan%'AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
	UNNEST(STRING_TO_ARRAY(casts,',')) as Actor,
	Count (*) as total_movies_done
FROM netflix
WHERE country = 'India' AND type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC LIMIT 10;

--Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. 
--Count the number of items in each category.
SELECT 
category,
COUNT(*) FROM
(SELECT 
	CASE 
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'BAD'
		ELSE 'GOOD'
		END as category 
FROM netflix) as categorised_table
GROUP BY 1;
