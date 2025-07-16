-- Connect to database
USE maven_advanced_sql;



-- 1. Numeric functions

-- math and rounding functions
SELECT 	country, population, 
		LOG(population) AS log_pop,						-- LOG base e
		ROUND(LOG(population), 2) AS log_pop2				-- ROUND to 2 dp
FROM	country_stats;

-- pro tip: FLOOR function for binning	
 WITH pm AS (SELECT country, population, 
					FLOOR(population / 1000000) AS pop_m	-- bin the population into millions
			 FROM	country_stats)
             
SELECT 	 pop_m, COUNT(country) AS num_countries 			
FROM	 pm
GROUP BY pop_m
ORDER BY pop_m;


-- max of a column vs max of a row: least & greatest

-- create a miles run table
CREATE TABLE miles_run (
    name VARCHAR(50),
    q1 INT,
    q2 INT,
    q3 INT,
    q4 INT
);

INSERT INTO miles_run (name, q1, q2, q3, q4) VALUES
	('Ali', 100, 200, 150, NULL),
	('Bolt', 350, 400, 380, 300),
	('Jordan', 200, 250, 300, 320);
    
SELECT * FROM miles_run;

-- return the greatest value of each column
SELECT 	MAX(q1), MAX(q2), MAX(q3), MAX(q4)
FROM	miles_run;

-- return the greatest value of each row
SELECT	GREATEST(q1, q2, q3, q4) AS most_miles
FROM	miles_run;

-- Lookahead: Deal with the NULL values
SELECT	GREATEST(q1, q2, q3, COALESCE(q4, 0)) AS most_miles
FROM	miles_run;



-- 2. CAST & CONVERT function

-- Create a sample table
CREATE TABLE sample_table (
    id INT,
    str_value CHAR(50)
);

INSERT INTO sample_table (id, str_value) VALUES
	(1, '100.2'),
	(2, '200.4'),
	(3, '300.6');
    
SELECT * FROM sample_table;

-- try to do a math calculation on the string column
SELECT 	id, str_value*2										-- calculation may not work in diff rdbmses
FROM	sample_table;

-- turn the string to a decimal
SELECT 	id, CAST(str_value AS DECIMAL(5, 2))*2				-- DECIMAL holds 5 digits total with 2 num after dp
FROM	sample_table;

-- turn an integer into a float
SELECT 	country, population / 5.0							-- calculation with .0 turn int to float
FROM	country_stats;



-- 3. DATETIME function

-- get current date & time
SELECT CURRENT_DATE(), CURRENT_TIMESTAMP();

-- Create a my events table
CREATE TABLE my_events (
    event_name VARCHAR(50),
    event_date DATE,
    event_datetime DATETIME,
    event_type VARCHAR(20),
    event_desc TEXT);

INSERT INTO my_events (event_name, event_date, event_datetime, event_type, event_desc) VALUES
('New Year\'s Day', '2025-01-01', '2025-01-01 00:00:00', 'Holiday', 'A global celebration to mark the beginning of the New Year. Festivities often include fireworks, parties, and various cultural traditions as people reflect on the past year and set resolutions for the upcoming one.'),
('Lunar New Year', '2025-01-29', '2025-01-29 10:00:00', 'Holiday', 'A significant cultural event in many Asian countries, the Lunar New Year, also known as the Spring Festival, involves family reunions, feasts, and various rituals to welcome good fortune and happiness for the year ahead.'),
('Persian New Year', '2025-03-20', '2025-03-20 12:00:00', 'Holiday', 'Known as Nowruz, this celebration marks the first day of spring and the beginning of the year in the Persian calendar. It is a time for family gatherings, traditional foods, and cultural rituals to symbolize renewal and rebirth.'),
('Birthday', '2025-05-13', '2025-05-13 18:00:00', ' Personal!', 'A personal celebration marking the anniversary of one\'s birth. This special day often involves gatherings with family and friends, cake, gifts, and reflecting on personal growth and achievements over the past year.'),
('Last Day of School', '2025-06-12', '2025-06-12 15:30:00', ' Personal!', 'The final day of the academic year, celebrated by students and teachers alike. It often includes parties, awards, and a sense of excitement for the upcoming summer break, marking the end of a year of hard work and learning.'),
('Vacation', '2025-08-01', '2025-08-01 08:00:00', ' Personal!', 'A much-anticipated break from daily routines, this vacation period allows individuals and families to relax, travel, and create memories. It is a time for adventure and exploration, often enjoyed with loved ones.'),
('First Day of School', '2025-08-18', '2025-08-18 08:30:00', ' Personal!', 'An exciting and sometimes nerve-wracking day for students, marking the beginning of a new academic year. This day typically involves meeting new teachers, reconnecting with friends, and setting goals for the year ahead.'),
('Halloween', '2025-10-31', '2025-10-31 18:00:00', 'Holiday', 'A festive occasion celebrated with costumes, trick-or-treating, and various spooky activities. Halloween is a time for fun and creativity, where people of all ages dress up and participate in themed events, parties, and community gatherings.'),
('Thanksgiving', '2025-11-27', '2025-11-27 12:00:00', 'Holiday', 'A holiday rooted in gratitude and family, Thanksgiving is celebrated with a large feast that typically includes turkey, stuffing, and various side dishes. It is a time to reflect on the blessings of the year and spend quality time with loved ones.'),
('Christmas', '2025-12-25', '2025-12-25 09:00:00', 'Holiday', 'A major holiday celebrated around the world, Christmas commemorates the birth of Jesus Christ. It is marked by traditions such as gift-giving, festive decorations, and family gatherings, creating a warm and joyous atmosphere during the holiday season.');

SELECT * FROM my_events;

-- extract info about datetime values
SELECT	event_name, event_date, event_datetime, 
		YEAR(event_date) AS event_year,
        MONTH(event_date) AS event_month,
        DAYOFWEEK(event_date) AS event_dow
FROM 	my_events;

-- spell out the full days of the week using CASE statements
WITH dow AS (SELECT	event_name, event_date, event_datetime, 
					YEAR(event_date) AS event_year,
					MONTH(event_date) AS event_month,
					DAYOFWEEK(event_date) AS event_dow
			FROM 	my_events)

SELECT 	*, CASE WHEN event_dow = 1 THEN 'Sunday'
				WHEN event_dow = 2 THEN 'Monday'
                WHEN event_dow = 3 THEN 'Tuesday'
                WHEN event_dow = 4 THEN 'Wednesday'
                WHEN event_dow = 5 THEN 'Thursday'
                WHEN event_dow = 6 THEN 'Friday'
                WHEN event_dow = 7 THEN 'Saturday'
                ELSE 'Unknown' END AS event_dow_name
FROM 	dow;

-- calculate an interval between datetime values
SELECT	event_name, event_date, event_datetime, CURRENT_DATE(), 
		DATEDIFF(event_date, CURRENT_DATE()) AS days_until 					-- CURRENT_DATE() - event_date calculation output doesnt make sense
FROM 	my_events;

-- add or subtract an interval from a datetime value
SELECT	event_name, event_date, event_datetime, 
		DATE_ADD(event_datetime, INTERVAL 1 YEAR) AS plus_one_year 					
FROM 	my_events;



-- 4. STRING function

-- change the case
SELECT 	event_name, UPPER(event_name), LOWER(event_name)
FROM 	my_events;

-- clean up event type and find the length of the description
SELECT 	event_name, event_type,
		-- REPLACE(TRIM(event_type), '!', '' ) AS event_type_clean,		** alternative
        TRIM(REPLACE((event_type), '!', '' )) AS event_type_clean, 
		event_desc,
        LENGTH(event_desc) AS desc_length
FROM 	my_events;

-- combine the type and description columns
WITH my_event_clean AS(SELECT 	event_name, event_type,
								TRIM(REPLACE((event_type), '!', '' )) AS event_type_clean, 
								event_desc,
								LENGTH(event_desc) AS desc_length
						FROM 	my_events)

SELECT 	event_name, event_type_clean, event_desc,
		CONCAT(event_type_clean, ' | ', event_desc) AS full_desc
FROM 	my_event_clean;


-- Pattern Matching
-- return the first word of each event 
SELECT 	event_name,
		SUBSTR(event_name, 1, 3)								-- substring; extract from 1st char to 3rd char
FROM 	my_events;

SELECT 	event_name,
		INSTR(event_name, ' ')									-- instring; search for a particular char @ what pos
FROM  	my_events;

SELECT 	event_name,
		SUBSTR(event_name, 1, INSTR(event_name, ' ') - 1) AS first_word		-- extract first char until ' '-1; first word
FROM 	my_events;

-- update to handle single word events
SELECT	event_name,
		CASE WHEN INSTR(event_name, ' ') = 0 THEN event_name				-- when search for INSTR if value = 0, then just return event_name
			 ELSE SUBSTR(event_name, 1, INSTR(event_name, ' ') - 1) 		-- extract first char until ' '-1; first word
		END AS first_word
FROM 	my_events;

-- return descriptions that contain 'family' 
SELECT 	*
FROM  	my_events
WHERE 	event_desc LIKE '%family%';

-- return descriptions that start with 'A'
SELECT 	*
FROM  	my_events
WHERE 	event_desc LIKE 'A %';

-- return students with three letter first names
SELECT 	*
FROM 	students
WHERE 	student_name LIKE '___ %';

-- note any celebration word in the sentence
SELECT 	event_desc,
		REGEXP_SUBSTR(event_desc, 'celebration|festival|holiday') AS celebration_word		-- regular expression; check if event_desc have 'x' or 'y' or 'z'
FROM  	my_events
WHERE 	event_desc LIKE '%celebration%'
		OR event_desc LIKE '%festival%'
        OR event_desc LIKE '%holiday%';

-- return words with hyphens in them
SELECT 	event_desc,
		REGEXP_SUBSTR(event_desc, '[A-Z][a-z]+(-[A-Za-z]+)+') AS hyphen						-- '[A-Z][a-z]+(-[A-Za-z]+)+' just use regex interpreter/AI for help
FROM  	my_events;



-- 5. NULL functions

-- Create a contacts table
CREATE TABLE contacts (
    name VARCHAR(50),
    email VARCHAR(100),
    alt_email VARCHAR(100));

INSERT INTO contacts (name, email, alt_email) VALUES
	('Anna', 'anna@example.com', NULL),
	('Bob', NULL, 'bob.alt@example.com'),
	('Charlie', NULL, NULL),
	('David', 'david@example.com', 'david.alt@example.com');

SELECT * FROM contacts;

-- return null values
SELECT 	* 
FROM 	contacts
WHERE 	email IS NULL;

-- return non-null values
SELECT 	* 
FROM 	contacts
WHERE 	email IS NOT NULL;

-- return non-null values using a CASE statement
SELECT 	name, email,
		CASE WHEN email IS NOT NULL THEN email
			 ELSE 'no email' 
		END AS contact_email
FROM 	contacts;

-- return non-null values using IFNULL 
SELECT 	name, email,
		IFNULL(email, 'no email') AS contact_email
FROM 	contacts;

-- return an alternative field using IF NULL
SELECT 	name, email, alt_email,
		IFNULL(email, alt_email) AS contact_email
FROM 	contacts;

-- return an alternative field after multiple checks
SELECT 	name, email, alt_email,
		IFNULL(email, 'no email') AS contact_email_value,
        IFNULL(email, alt_email) AS contact_email_column,
        COALESCE(email, alt_email, 'no email') AS contact_email_coalesce 	-- check for nulls in email column first, if yes put in x, if still yes put y)
FROM 	contacts;

