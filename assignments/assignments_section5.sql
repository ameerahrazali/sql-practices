-- Connect to database
USE maven_advanced_sql;


-- ASSIGNMENT 1: Numeric functions

-- Calculate the total spend for each customer
SELECT 	 o.customer_id, SUM(o.units * p.unit_price) AS total_spend
FROM 	 orders o LEFT JOIN products p
		 ON o.product_id = p.product_id
GROUP BY customer_id;

-- Put the spend into bins of $0-$10, $10-20, etc.
SELECT 	 o.customer_id, 
		 SUM(o.units * p.unit_price) AS total_spend,
         FLOOR(SUM(o.units * p.unit_price / 10)) * 10 AS total_spend_bin			-- FLOOR * 10 for within 10-20 range 
FROM 	 orders o LEFT JOIN products p
		 ON o.product_id = p.product_id
GROUP BY customer_id;

-- Number of customers in each spend bin
WITH bin AS (SELECT   o.customer_id, 
					  SUM(o.units * p.unit_price) AS total_spend,
					  FLOOR(SUM(o.units * p.unit_price / 10)) * 10 AS total_spend_bin			-- FLOOR * 10 for within 10-20 range 
			 FROM 	  orders o LEFT JOIN products p
					  ON o.product_id = p.product_id
			 GROUP BY customer_id)

SELECT 	 total_spend_bin, COUNT(customer_id) AS num_customers
FROM 	 bin
GROUP BY total_spend_bin
ORDER BY total_spend_bin;


-- ASSIGNMENT 2: Datetime functions

-- Extract just the orders from Q2 2024
SELECT 	* 
FROM 	orders
WHERE	YEAR(order_date) = 2024 AND MONTH(order_date) BETWEEN 4 AND 6;

-- Add a column called ship_date that adds 2 days to each order date
SELECT 	order_id, order_date,
		DATE_ADD(order_date, INTERVAL 2 DAY) AS ship_date
FROM 	orders
WHERE	YEAR(order_date) = 2024 AND MONTH(order_date) BETWEEN 4 AND 6;


-- ASSIGNMENT 3: String functions

-- View the current factory names and product IDs
SELECT 	 factory, product_id 
FROM 	 products 
ORDER BY factory, product_id;

-- Remove apostrophes and replace spaces with hyphens
SELECT 	 factory, product_id,
		 REPLACE(REPLACE(factory, "'", ""), " ","-") AS factory_clean
FROM 	 products 
ORDER BY factory, product_id;

-- Create new ID column called factory_product_id
WITH fp AS (SELECT 	 factory, product_id,
					 REPLACE(REPLACE(factory, "'", ""), " ","-") AS factory_clean
			FROM 	 products 
			ORDER BY factory, product_id)

SELECT 	factory, product_id, 
		CONCAT(factory_clean, '-', product_id) AS factory_product_id
FROM 	fp;


-- ASSIGNMENT 4: Pattern matching

-- View the product names
SELECT 	 product_name 
FROM 	 products 
ORDER BY product_name;

-- Only extract text after the hyphen for Wonka Bars
SELECT 	 product_name,
		 REPLACE(product_name, 'Wonka Bar - ', '') AS new_product_name
FROM 	 products 
ORDER BY product_name;

-- Alternative using substrings
SELECT 	 product_name,
		 CASE WHEN INSTR(product_name, '-') = 0 THEN product_name		-- when product_name w/o '-', return its product_name
			  ELSE SUBSTR(product_name, INSTR(product_name, '-') + 2) 	-- INSTR; search for '-' @ 2nd pos **SUBSTR; subtract product_name until INSTR
		 END AS new_product_name
FROM 	 products 
ORDER BY product_name;


-- ASSIGNMENT 5: Null functions			** TO BE STUDIED AGAIN

-- S1: View the columns of interest
SELECT 	 product_name, factory, division 
FROM 	 products
ORDER BY factory, division;

-- S2: Replace NULL values with Other
SELECT 	 product_name, factory, division,
		 IFNULL(division, 'Other') AS division_other
FROM 	 products
ORDER BY factory, division;

-- S3: Find the most common division for each factory
SELECT 	 COUNT(product_name) AS num_products, factory, division 
FROM 	 products
WHERE 	 division IS NOT NULL 
GROUP BY factory, division
ORDER BY factory, division;

-- S4: Replace NULL values with top division for each factory
WITH np 	 AS (SELECT   factory, division, COUNT(product_name) AS num_products  
				 FROM 	  products
				 WHERE 	  division IS NOT NULL 
				 GROUP BY factory, division
				 ORDER BY factory, division),
                 
	 np_rank AS (SELECT   factory, division, num_products,
						  ROW_NUMBER() OVER(PARTITION BY factory ORDER BY num_products DESC) AS np_rank	-- windows on factory col
				 FROM 	  np)

SELECT 	factory, division 
FROM 	np_rank 
WHERE 	np_rank = 1;

-- S5: Replace division with Other value and top division
WITH np 	 AS (SELECT   factory, division, COUNT(product_name) AS num_products  
				 FROM 	  products
				 WHERE 	  division IS NOT NULL 
				 GROUP BY factory, division
				 ORDER BY factory, division),
                 
	 np_rank AS (SELECT  factory, division, num_products,
						 ROW_NUMBER() OVER(PARTITION BY factory ORDER BY num_products DESC) AS np_rank	-- windows on factory col
				 FROM 	 np),
                 
	 top_div AS (SELECT factory, division
				 FROM 	np_rank
				 WHERE 	np_rank = 1)

SELECT   p.product_name, p.factory, p.division,
		 COALESCE(p.division, 'Other') AS division_other,   					-- from S2
         COALESCE(p.division, td.division) AS division_top
FROM 	 products p LEFT JOIN top_div td  										-- join product table with top_div query from CTE
		 ON p.factory = td.factory
ORDER BY p.factory, p.division;
