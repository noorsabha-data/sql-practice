
-- operators 

-- 1. COMPARISON OPERATORS (=,<> !=,>,<,>=,<=)
-- comparison between two columns i.e first_name = last_name
-- comparison between column and value i.e first_name = 'john'
-- comparison between function and a value i.e upper(first_name) = 'JOHN'
-- comparison between expression and a value i.e price*quantity = 100
-- comparison between subquery and a value i.e (SELECT AVG(sales) FROM orders) = 1000
USE MyDatabase;
-- filtering data using operators
-- task: retrieve all customers from germany 
SELECT * 
FROM customers
WHERE country = 'Germany';

-- task: retrieve all customers not from germany 
SELECT * 
FROM customers
WHERE country != 'Germany';

-- task: retreive customers score>500
SELECT * 
FROM customers
WHERE score > 500;

-- -- task: retreive customers with score of 500 or more
SELECT * 
FROM customers
WHERE score >= 500;

-- task: retreive customers score<500
SELECT * 
FROM customers
WHERE score < 500;

-- task: retreive customers with score of 500 orless
SELECT * 
FROM customers
WHERE score <= 500;

-- LOGICAL OPERATORS (AND,OR,NOT)

-- AND OPERATOR
-- task: retrieve all customers who are from USA AND has score greater than 500
SELECT * 
FROM customers
WHERE 
	country = 'USA' 
    AND
    score > 500;

-- OR OPERATOR
-- task: retrieve all customers who are from USA OR has score greater than 500
SELECT * 
FROM customers
WHERE 
	country = 'USA' 
    OR
    score > 500;
    
-- NOT OPERATOR
-- task: retrieve all customers who  has score not less than 500
SELECT * 
FROM customers
WHERE 
   NOT
   score < 500;
   
-- Range operator (BETWEEN)  lower and uppers boundries are inclusive 
-- task: retrieve customers whose scroe is between 100 and 500
SELECT * 
FROM customers
WHERE score 
BETWEEN 100 AND 500;

-- BETWEEN alternative using comaprison and logical operator
SELECT * 
FROM customers
WHERE 
	score >=100
	AND 
	score <=100;

-- IN Operator/NOT IN Operator
-- task: retrieve customers either germany or usa
SELECT * 
FROM customers
WHERE country IN ('Germany','USA');

-- task: retrieve customers not from  germany or usa
SELECT * 
FROM customers
WHERE country NOT IN ('Germany','USA');

-- Search Operator LIKE 
-- two wild cards % , _
-- 1. M% - starts with M after that it could be anything or nothing 
-- 2. %in - end with in before that it could be anything or nothing
-- 3. %r% - before r it could be anything or nothing and after r also it could be anything or nothing
-- 4. _ _b% -- one _ represents one char , here 2 letter before b after that it could be anything or nothing 

-- task: retreive customer first_name starts with M or m 
SELECT * 
FROM customers
WHERE first_name LIKE 'M%';

-- task: retreive customer first_name ends with n 
SELECT * 
FROM customers
WHERE first_name LIKE '%n';

-- task: retreive customer first_name contains r
SELECT * 
FROM customers
WHERE first_name LIKE '%r%';

-- task: retreive customer first_name third char is r
SELECT * 
FROM customers
WHERE first_name LIKE '__r%';


-- JOINS 
-- Two Types - 1. by columns (using joins)(inner,outer,left,right)
--           - 2. by rows (using set operator)(union,union all , except , intersect)

-- Why joins 
-- 1. recombine data all the tables to get big picture 
-- 2. data enrichment - to get extra info 
-- 3. to check existence to filter data does not invlove combining 

-- TYPES 
-- BASICS 

-- 1. NO JOIN (select everything from A and everythingg from B)
SELECT * FROM customers;
SELECT * FROM orders;

-- 2. INNER JOIN (return olny matching data from both tables)
-- in inner join dont worry about order of tables
-- putting table name in front of column is good practice bcoz 
-- if table has same column sql will get confused due to ambiguity
-- use case - data recombining and extraction 
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
INNER JOIN orders o
ON c.id = o.customer_id;

-- 3.LEFT JOIN all rows from left table and matching rows from right table
-- carefull about order of a table 
-- usecase - data recombining , data enrichment , extraction using where clause
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
LEFT JOIN orders o
ON c.id = o.customer_id;

-- 3.RIGHT JOIN all rows from right table and matching rows from left table
-- carefull about order of a table 
-- usecase - data recombining , data enrichment , extraction using where clause
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
RIGHT JOIN orders o
ON c.id = o.customer_id;

-- RIGHT JOIN using LEFT JOIN by swapping tables
SELECT 
    o.order_id,
	o.sales ,
	c.id,
	c.first_name
FROM orders o 
LEFT JOIN customers c
ON c.id = o.customer_id;

-- FULL JOIN 
-- since there is no full join in mysql we do this
-- usecase - data recombining , extraction using where clause
-- task:get all customers and orders even if there is no match
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
LEFT JOIN orders o
ON c.id = o.customer_id
UNION
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
RIGHT JOIN orders o
ON c.id = o.customer_id;

-- ADVANCED SQL JOINS
-- 1. LEFT ANTI JOINS (left join with where clause is nothing but left anti join)
-- only rows from left table which doesnt match with right table
-- usecase: to check existence
-- task:customer who has never ordered
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
LEFT JOIN orders o
ON c.id = o.customer_id
WHERE o.customer_id IS  NULL;

-- RIGHT ANTI JOIN

SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
RIGHT JOIN orders o
ON c.id = o.customer_id
WHERE c.id IS  NULL;

-- task: all orders without matching customers (right anti join using left anti join)
SELECT 
    o.order_id,
	o.sales ,
	c.id,
	c.first_name
FROM orders o
LEFT JOIN customers c
ON c.id = o.customer_id
WHERE c.id IS  NULL;

-- FULL ANTI JOIN
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
LEFT JOIN orders o
ON c.id = o.customer_id
WHERE o.customer_id IS  NULL
UNION
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
RIGHT JOIN orders o
ON c.id = o.customer_id
WHERE c.id IS  NULL;

-- inner join without using inner join and using left anti join
SELECT 
	c.id,
	c.first_name,
	o.order_id,
	o.sales 
FROM customers c
LEFT JOIN orders o
ON c.id = o.customer_id
WHERE o.customer_id IS NOT NULL;

-- CROSS JOIN (cartesian join )
-- we dont need specific column to join 5*4 = 20 combinations
-- usecase when we like to see combination of row from one table 
-- with all other rows from other table 
-- like color and product
SELECT *
FROM customers c
CROSS JOIN orders o ;

-- How to choose join types
-- DECISION TREE 
-- only matching data INNER JOIN
-- All rows from a particular table left join 
-- all rows from both table full join 
-- ONLY UNMATCHING DATA
-- from one side left join 
-- from both sides full join
-- choose your master table if you find information is not enough 
-- keep doing left joins with other table
-- at the  end if you want only matching data filter it using where clause and not null 
-- if all the tables are equally important we usually  do inner join 

-- use salesdb database

USE salesdb;

-- task
SELECT 
o.orderid,
c.firstname AS customerfirstname,
c.lastname AS customerlastname ,
p.product AS product_name,
o.sales,
p.price,
e.firstname AS employeefirstname,
e.lastname AS employeelastname
FROM orders o
LEFT JOIN customers c
ON o.customerid = c.customerid 
LEFT JOIN products p 
ON o.productid = p.productid
LEFT JOIN employees e 
ON o.salespersonid = e.employeeid;

-- SET Operators
-- 1. UNION return all distinct rows means each row gonna appear only once
-- RULES
-- 1. can use any clause in both the queries except order by bcoz it appearn only once and at last of query 
-- 2. both queries must have same number of columns 
-- 3. both queries must have same data type of columns 
-- 4. both queries must have same order of columns 
-- 5. name of column will be decided only from 1st subquery 
-- 6. make sure you are mapping correct columns even if no error results can be incorrect
-- with single column
SELECT 
customerid
FROM customers
UNION 
SELECT
employeeid
FROM employees;

-- with 2 columns 
SELECT 
customerid,
firstname
FROM customers
UNION 
SELECT
employeeid,
firstname
FROM employees;

SELECT 
firstname,
lastname
FROM 
customers
UNION
SELECT 
firstname,
lastname 
FROM 
employees;

-- UNION ALL - it will not remove duplicated and way more faster than union
-- usecase: 1.if you know there is no duplictaes
-- 2. if you try to fing out duplicates row in a specific column 
SELECT 
firstname,
lastname
FROM 
customers
UNION ALL
SELECT 
firstname,
lastname 
FROM 
employees;

-- EXCEPT doesnot work in mysql 
-- alternative NOT EXIST / left anti join
-- Find the employees who r not customers 

-- first approach
SELECT 
e.firstname,
e.lastname
FROM employees e
WHERE NOT EXISTS (
    SELECT *
    FROM customers c
    WHERE c.firstname = e.firstname
    AND c.lastname = e.lastname);
    
-- second approach
SELECT 
e.firstname,
e.lastname
FROM employees e
LEFT JOIN customers c
ON e.firstname = c.firstname
AND e.lastname = c.lastname
WHERE c.firstname IS NULL AND c.lastname IS NULL;    

-- intersect
-- similar to inner join bcoz there is no intersect in my sql
SELECT 
e.firstname,
e.lastname
FROM employees e
JOIN customers c
ON e.firstname = c.firstname
AND e.lastname = c.lastname;
    
-- set operator usecases 
-- to combine the data so that we can perform sql query on it and geneerate reports
-- another usecase we can make any change on that combine table instead of seperate tables
-- if th edata is broken into multiple table and we dont want any duplicate we combine it using
-- sql union and by performing sql query we can generate a reports

-- How to combine data between different tables
-- if the tables are exactly identical
-- first list all the columns in the select statement 
-- if any column is removing in  future it will be easy for you to remove
-- second define the name of tables as source table
SELECT 
'orders' AS sourceTable,
orderid,
productid,
customerid,
salespersonid,
orderdate,
shipdate,
orderstatus,
shipaddress,
billaddress,
quantity,
sales,
creationtime
FROM orders 
UNION 
SELECT 
'orders_archive' AS sourceTable,
orderid,
productid,
customerid,
salespersonid,
orderdate,
shipdate,
orderstatus,
shipaddress,
billaddress,
quantity,
sales,
creationtime
FROM orders_archive;

-- EXECPT set operator usecase 

-- 1.
-- DELTA DETECTION - identify the changes between two batches of data
-- while doing data pipeline i.e inserting data from data source to data warehouse
-- if few of data is repeating on any day we will perform left anti join on current data with previous data 
-- to get the new data and will send that data to data warehouse

-- 2.
-- when we r doing data migration between two daatbase i.e from database A to database B we will check the data quality
-- and completeness of data
-- i.e every data from database A will be send to Database B 
-- we will perform except opeartion between database a and database b 
-- to check wheteher there is still a data in databse A which is not moved to database B
-- if the except result is empty that means all the data from database A is moved to database B
-- similarly we will swap tha database and perform except operation 
-- to check both the tables are identical or not 
-- this is the way we do data completeness test using left anti join or lets say except operation 

-- summary 
-- union / union all to combine similar set of info to get a big picture 
-- except -- delta detection , data completeness check 


