-- connect to the database
USE maven_advanced_sql;



-- 1. window function basics

-- to return all row numbers
SELECT	 country, year, happiness_score,
		 ROW_NUMBER() OVER() AS row_num						-- OVER() tells that this is a window function; row_number is the function
FROM	 happiness_scores
ORDER BY country,year;

-- to return all row numbers within each window
SELECT	 country, year, happiness_score,
		 ROW_NUMBER() OVER(PARTITION BY country) AS row_num						
FROM	 happiness_scores
ORDER BY country,year;

-- to return all row numbers within each window
SELECT	 country, year, happiness_score,
		 ROW_NUMBER() OVER(PARTITION BY country) AS row_num						
FROM	 happiness_scores
ORDER BY country,year;

/* to return all row numbers within each window
where the rows are ordered by happiness score */
SELECT	 country, year, happiness_score,
		 ROW_NUMBER() OVER(PARTITION BY country ORDER BY happiness_score) AS row_num						
FROM	 happiness_scores
ORDER BY country, row_num;

/* to return all row numbers within each window
where the rows are ordered by happiness score descending*/
SELECT	 country, year, happiness_score,
		 ROW_NUMBER() OVER(PARTITION BY country ORDER BY happiness_score DESC) AS row_num						
FROM	 happiness_scores
ORDER BY country, row_num;



-- 2. ROW_NUMBER vs RANK vs DENSE_RANK
CREATE TABLE baby_girl_names (
    name VARCHAR(50),
    babies INT);

INSERT INTO baby_girl_names (name, babies) VALUES
	('Olivia', 99),
	('Emma', 80),
	('Charlotte', 80),
	('Amelia', 75),
	('Sophia', 72),
	('Isabella', 70),
	('Ava', 70),
	('Mia', 64);
    
-- view the table
SELECT	* FROM baby_girl_names;

-- compare ROW_NUMBER vs RANK vs DENSE_RANK
SELECT	name, babies,
		ROW_NUMBER() OVER(ORDER BY babies DESC) AS babies_rn,							-- babies row_num
        RANK() OVER(ORDER BY babies DESC) AS babies_rank,								-- babies name rank **takes account for ties
        DENSE_RANK() OVER(ORDER BY babies DESC) AS babies_drank							-- babies name rank (no skipping rank num)
FROM 	baby_girl_names;



-- 3. FIRST_VALUE, LAST_VALUE & NTH_VALUE
CREATE TABLE baby_names (
    gender VARCHAR(10),
    name VARCHAR(50),
    babies INT);

INSERT INTO baby_names (gender, name, babies) VALUES
	('Female', 'Charlotte', 80),
	('Female', 'Emma', 82),
	('Female', 'Olivia', 99),
	('Male', 'James', 85),
	('Male', 'Liam', 110),
	('Male', 'Noah', 95);
    
-- View the table
SELECT * FROM baby_names;

-- return the first name in each window
SELECT 	gender, name, babies,
		FIRST_VALUE(name) OVER(PARTITION BY gender ORDER BY babies desc) AS top_name
FROM 	baby_names;

-- return the top name for each gender
SELECT * FROM

	(SELECT gender, name, babies,
			FIRST_VALUE(name) OVER(PARTITION BY gender ORDER BY babies desc) AS top_name
	FROM 	baby_names) AS top_name

WHERE name = top_name;

-- alternatively, use CTEs
WITH 	top_name AS (SELECT gender, name, babies,
							FIRST_VALUE(name) OVER(PARTITION BY gender ORDER BY babies desc) AS top_name
					 FROM 	baby_names) 
SELECT 	* 
FROM 	top_name
WHERE 	name = top_name;

-- return the second name in each window
SELECT 	gender, name, babies,
		NTH_VALUE(name, 2) OVER(PARTITION BY gender ORDER BY babies desc) AS second_name
FROM 	baby_names;

-- return the 2nd most popular name for each gender
SELECT * FROM 

	(SELECT gender, name, babies,
			NTH_VALUE(name, 2) OVER(PARTITION BY gender ORDER BY babies desc) AS second_name
	 FROM 	baby_names) AS second_name

WHERE name = second_name;


-- alternative: use ROW_NUMBER()

-- return the second name in each window
SELECT 	gender, name, babies,
		ROW_NUMBER() OVER(PARTITION BY gender ORDER BY babies desc) AS popularity
FROM 	baby_names;

-- return the 2nd most popular name for each gender
SELECT * FROM 

	(SELECT gender, name, babies,
			ROW_NUMBER() OVER(PARTITION BY gender ORDER BY babies desc) AS popularity
	 FROM 	baby_names) AS pop

WHERE popularity <= 2;									-- more flexible to analyze e.g. less than or equal



-- 4. LEAD & LAG 

-- return the prior's year happiness score
SELECT 	country, year, happiness_score,
		LAG(happiness_score) OVER(PARTITION BY country ORDER BY year) AS prior_happiness_score
FROM 	happiness_scores;

-- return the difference between yearly scores
WITH 	hs_prior AS (SELECT	country, year, happiness_score,
							LAG(happiness_score) OVER(PARTITION BY country ORDER BY year) 
                            AS prior_happiness_score
					 FROM 	happiness_scores)
SELECT	country, year, happiness_score, prior_happiness_score,
		happiness_score - prior_happiness_score AS hs_change
FROM	hs_prior;



-- 5. NTILE

-- add a percecntile to each row of data
SELECT 	 region, country, happiness_score,
		 NTILE(4) OVER(PARTITION BY region ORDER BY happiness_score DESC) AS hs_percentile
FROM 	 happiness_scores
WHERE	 year = 2023
ORDER BY region, happiness_score DESC;

-- for each region. return the top 25% of countries, in terms of happiness score
WITH hs_pct AS (SELECT   region, country, happiness_score,
						  NTILE(4) OVER(PARTITION BY region ORDER BY happiness_score DESC) 
						  AS hs_percentile
				 FROM 	  happiness_scores
				 WHERE	  year = 2023
				 ORDER BY region, happiness_score DESC)

SELECT 	* 
FROM 	hs_pct
WHERE	hs_percentile = 1;		-- filter by top 25%