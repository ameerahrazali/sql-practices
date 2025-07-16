-- connect to database (mysql)
USE maven_advanced_sql;

-- 1. view the students table
SELECT * FROM students;

-- 2. the big 6
SELECT grade_level, AVG(gpa) AS avg_gpa
FROM students
WHERE school_lunch = 'Yes'
GROUP BY grade_level 
HAVING avg_gpa < 3.3
ORDER BY grade_level;

-- 3. common keywords

-- distinct
SELECT COUNT(DISTINCT grade_level)
FROM students;

-- max and min
SELECT MAX(gpa) - MIN(gpa) AS gpa_range
FROM students;

-- and
SELECT *
FROM students
WHERE grade_level < 12 AND school_lunch = 'Yes';

-- in
SELECT *
FROM students 
WHERE grade_level IN (9, 10, 11);

-- is null
SELECT *
FROM students
WHERE email IS NOT NULL;

-- like
SELECT *
FROM students
WHERE email LIKE '%.edu';

-- order by
SELECT * 
FROM students
ORDER BY gpa DESC;

-- limit
SELECT *
FROM students
LIMIT 5;

-- case statements
SELECT student_name, grade_level,
	CASE WHEN grade_level =  9 THEN 'Freshman'
		 WHEN grade_level = 10 THEN 'Sophomore'
         WHEN grade_level = 11 THEN 'Junior'
         ELSE 'Senior' END AS student_class
FROM students;