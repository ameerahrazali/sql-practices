-- Connect to database
USE maven_advanced_sql;

-- ASSIGNMENT 1: Basic Joins
-- Looking at the orders and products tables, which products exist in one table, but not the other?

         
-- View the orders and products tables
SELECT * FROM orders;
SELECT * FROM products;

SELECT COUNT(DISTINCT product_id) FROM orders;		-- since product_id is the unique column from both
SELECT COUNT(DISTINCT product_id) FROM products;	-- to count unique products from table(s); products table (18) > orders (15) 


-- Join the tables using various join types & note the number of rows in the output
SELECT COUNT(*) 
FROM orders o LEFT JOIN products p
	 ON o.product_id = p.product_id;			-- left join; 8549
     
SELECT COUNT(*) 
FROM orders o RIGHT JOIN products p
	 ON o.product_id = p.product_id;			-- right join; 8552
 
 
-- View the products that exist in one table, but not the other
SELECT * 
FROM orders o LEFT JOIN products p
	 ON o.product_id = p.product_id				
WHERE p.product_id IS NULL;						-- no null values when using left join
     
SELECT * 
FROM  products p RIGHT JOIN orders o
	 ON p.product_id = o.product_id
WHERE o.product_id IS NULL;						-- 3 null rows; new products not yet ordered				


-- Pick a final JOIN type to join products and orders
SELECT p.product_id, p.product_name,			-- only necessary columns to answer the question
	   o.product_id AS product_id_in_orders		-- which product id exists in product table but not in orders table
FROM products p LEFT JOIN orders o				-- LEFT join product p table with order o table to look at the items that are present in one table but not the other
	 ON o.product_id = p.product_id				
WHERE o.product_id IS NULL;		



-- ASSIGNMENT 2: Self Joins
-- Which products are within 25 cents of each other in terms of unit price?

-- View the products table
SELECT * FROM products;


-- Join the products table with itself so each candy is paired with a different candy
SELECT 	p1.product_name, p1.unit_price,
		p2.product_name, p2.unit_price
FROM 	products p1 INNER JOIN products p2
		ON p1.product_id <> p2.product_id;		-- do not pair with itself
        
-- Calculate the price difference, do a self join, and then return only price differences under 25 cents
SELECT 	p1.product_name, p1.unit_price,
		p2.product_name, p2.unit_price,
        p1.unit_price - p2.unit_price AS price_diff
FROM 	products p1 INNER JOIN products p2
		ON p1.product_id <> p2.product_id
WHERE	p1.unit_price - p2.unit_price BETWEEN -0.25 AND 0.25;

-- alternatively using ABS & w/o using BETWEEN
SELECT 	p1.product_name, p1.unit_price,
		p2.product_name, p2.unit_price,
        p1.unit_price - p2.unit_price AS price_diff
FROM 	products p1 INNER JOIN products p2
		ON p1.product_id <> p2.product_id
WHERE	ABS(p1.unit_price - p2.unit_price) < 0.25
		AND p1.product_name < p2.product_name				-- product name sorted alphabetically
ORDER BY price_diff DESC;
