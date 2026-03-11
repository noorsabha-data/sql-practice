/* this
is
a 
comment*/
-- slecting all columns
SELECT * FROM customers;
SELECT * FROM orders;

-- selecting a specific column
SELECT 
	first_name,
	country,
	score
FROM customers;

-- where clause to filter data 
SELECT * 
FROM customers
WHERE score != 0;

SELECT * 
FROM customers
WHERE country = 'Germany';

SELECT 
	id,
	first_name,
	country
FROM customers
WHERE country = 'Germany';


-- ORDER BY Clause to sort your data ascending or descending

-- DESC
SELECT * 
FROM customers
ORDER BY score DESC;

-- ASC
SELECT * 
FROM customers
ORDER BY score ASC;

-- nested sorting useful numerical inside categorical
-- specially when groups are forming in categorical
SELECT * 
FROM customers
ORDER BY country ASC , score DESC ; -- here in country countries are repeating so it wll sort scre accrdngly

-- illogical nested sorting 
-- values are not repeating (groups are not formed) in first sorting 
SELECT * 
FROM customers
ORDER BY id ASC , score DESC ; -- here in country countries are repeating so it wll sort scre accrdngly

-- GROUP BY CLAUSE to aggregate a column by another column
-- we can select only agg column or column used in group by inside select statement 
-- if we select non-agg its going to take first occurance of that column in particular group
-- if we r using more than one column in group by 
-- and each combination is unique then agg column will not get affected

SELECT 
	country , 
	SUM(score) AS total_score
FROM customers
GROUP BY country;

SELECT 
    first_name,
	country , 
	SUM(score) AS total_score
FROM customers
GROUP BY country;

SELECT 
    first_name,
	country , 
    COUNT(*), -- every value is one non-repeating values
	SUM(score) AS total_score
FROM customers
GROUP BY country,first_name;

-- total_score and total_number_customers each country
SELECT 
	country , 
	SUM(score) AS total_score,
    COUNT(id) AS total_customers
FROM customers
GROUP BY country;

-- HAVING CLAUSE to filter GROUP BY data
-- condition will get apply on agg columns
SELECT 
	country , 
	SUM(score) AS total_score,
    COUNT(id) AS total_customers
FROM customers
GROUP BY country
HAVING total_score > 800 ;

-- use WHERE when u want to filter data before aggregation 
-- use HAVING  when u want to filter data after  aggregation 
SELECT 
	country , 
	SUM(score) AS total_score,
    COUNT(id) AS total_customers
FROM customers
WHERE score > 400
GROUP BY country
HAVING total_score > 800 ;

SELECT 
	country , 
	AVG(score) AS total_score
FROM customers
WHERE score != 0
GROUP BY country
HAVING total_score > 430 ;

-- DISTINCT keyword
-- it is going to remove tha duplicate and will give only unique values from that column
SELECT 
DISTINCT country 
FROM customers  ; 

-- no sense bcoz every value is unique 
SELECT 
DISTINCT * 
FROM customers  ; 

-- LIMIT CLAUSE to extract n number of values only, lets say top 3  values
SELECT *
FROM customers 
LIMIT 3;

-- top 3 highest score customers 
SELECT *
FROM customers 
ORDER BY score DESC
LIMIT 3;

-- lowest top 2 acc to score
SELECT *
FROM customers 
ORDER BY score ASC
LIMIT 2;

-- order by order-dates
SELECT * 
FROM orders
ORDER BY order_date DESC
LIMIT 2;

-- till no ewe have learned theese clauses
-- SELECT
-- DISTINCT
-- FROM 
-- WHERE
-- GROUP BY 
-- HAVING 
-- ORDER BY 
-- LIMIT


-- ORDER OF EXCECUTION 

-- 1. FROM
-- 2. WHERE
-- 3. GROUP BY -- this is where agg functions will also get performed
-- 4. HAVING
-- 5. SELECT DISTINCT
-- 6. ORDER BY 
-- 7. LIMIT 

-- slecting our own static values not from any table
SELECT 123 AS 'static_number' ;
SELECT 'baraa' AS 'static_string';

-- SELECTING static values along with dynamic table
SELECT *,
	'baraa' AS 'static_string'
FROM customers ;   

-- DDL COMMANDS
-- data defination language DDL it usually defines the database and make changes to database
-- CREATE
-- ALTER 
-- DROP

CREATE TABLE person(
	id INT NOT NULL ,
    Name VARCHAR(50) NOT NULL,
    Birth_date DATE ,
    phone_number VARCHAR(15) NOT NULL ,
    CONSTRAINT pk_persons PRIMARY KEY (id)
);

DESCRIBE person;
SHOW COLUMNS FROM person;

-- Adding one more column to a person table
ALTER TABLE person 
ADD COLUMN email VARCHAR (50) NOT NULL ;

-- modifying a column in a table 
ALTER TABLE person 
MODIFY COLUMN email VARCHAR (50) FIRST ;

-- modifying column position after column name
-- column datatype is must while modifying it
ALTER TABLE person 
MODIFY COLUMN email VARCHAR (50)  AFTER Name ;

-- DELETING A SPECIFIC COLUMN
-- no need to write COLUMN and no need to specify column data type 
-- just a name after DROP CLAUSE
ALTER TABLE person 
DROP email;

-- dropping whole table 
-- simple but risky 
DROP TABLE person;

-- DML Commands
-- Data manipulation commands 
-- INSERT
-- UPDATE 
-- DELETE 

-- 1.INSERT 
-- inerting into table specify list of columns you want to enter value into 
-- porividing no of values should match provided no of columns 
-- if you are not specifying list of columns 
-- then you should provide list of values for each column 
-- dont insert null into not null columns and primary key columns
INSERT INTO customers (id,first_name,country,score)
VALUES 
	(6,'Anna','USA',NULL),
    (7,'Sam',NULL,100);
-- so, we just manipulated our data
-- we added 2 new rows into our table

-- AS long as you r following columns constraints and datatypes you can enter any value
INSERT INTO customers (id,first_name,country,score)
VALUES 
	(8,'USA','max',NULL);
-- Here usa and max is invalid name and country respectively
 
 -- without providing column list 
INSERT INTO customers 
VALUES 
	(9,'Andreas','Germany',NULL);
    
-- entering values into only 2 columns 
-- so,have specify those 2 columns after insert into table_name statement
-- carefull we can skip only nullable columns
INSERT INTO customers (id,first_name)
VALUES 
	(10,'Sahra');

-- INSERTING values from source table to target table 
-- as long as datatype and constraints are matching we dont need to match source column nam ewith target column name
-- but you can specify if you would like to


INSERT INTO person 
SELECT 
	id,
    first_name,
    NULL AS Birth_date,
    'unknown' AS phone_number
FROM customers;

SELECT * FROM person;

-- 2. UPDATE
-- UPDATING VALUE OF COLUMNS in a particular table
-- WHERE CLAUSE is must otherwise we will be updating all the values in a particular column
SELECT * FROM customers;


-- change the score of customer id 6 to 0
UPDATE customers 
SET score = 0
WHERE id = 6;

-- id 10 change score to 0 and country to 'UK'
UPDATE customers 
SET 
	score = 0,
    country = 'UK'
WHERE id = 10;

-- updating for multiple rows i.e for subsets 
UPDATE customers
SET 
	score = 0
WHERE score IS NULL   ; 

-- 3.DELETE 
-- deleting a particular row where clause is must otherwise we will end up deleteing every row

DELETE FROM customers 
WHERE id > 5;

-- DELETING all the data from table we can use DELETE 
-- as well as TRUNCATE
-- TRUNCATE is preferred bcoz it is more faster than DELETE

-- DELETE FROM person -- will be slow 

-- reset everything and make the table empty 
TRUNCATE TABLE customers





