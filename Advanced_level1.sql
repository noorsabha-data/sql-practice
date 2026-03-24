-- lets discuss the challenges we face while writing sql queries and related to database
-- 1. redundancy 
-- 2. performance issue
-- 3. complexity 
-- 4. Hard to maintain
-- 5. DB Stress
-- 6. security 

-- in order to resolve problems that we mmight face in our data projects
-- we r going to discuss these solutions
-- 1. Subquery
-- 2. CTE
-- 3. Views
-- 4. Temp Tables
-- 5. CTAS

-- lets take quick and simplified look to database architecture
-- there are two sides server/client(where we write a queries)

-- SERVER side components
-- DATABASE ENGINE 
-- it is brain of database , excecuting multiple operations ,
-- such as storing,retrieving,managing the data within database

-- STORAGE 
-- Two Types 
--  - DISK STORAGE 
--  - CACHE

-- DISK STORAGE - Long term memory where data is stored permanantly
-- can store large amount of data but quite slow to read and to write
-- There are 3 types of data storage in DISK

-- 1. USER 
-- it is main content of database where tha actual data that user care about is stored

-- 2. SYSTEM CATALOG
-- its stores internal information of database i.e metadata about database
-- we can access it through hidden folder called information schema
USE salesdb;
SELECT 
DISTINCT TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS;

-- 3. TEMPORARY DATA STORAGE 
-- temporary space used by database for short term task 
-- like processing query or sorting data 
-- once task is done the storage is cleared

-- CACHE - short term memory where data is stored temporarily like our machines ram
-- stores only small amount of data but fast to read and write 

-- lets understand how simple query works
-- database enine will check tht table in chache for faster results
-- if its not there then it willl check it in disk storage inside the user storage
-- after excecuting it db engine will send the result back to client

-- SUBQUERY
-- a query inside another query also called embedded query 
-- need : to have a logical flow/reduce complexity/improve readability
-- we can have many subqueries inside a main query 
-- only main query has access to its sub query not other queries have 
-- subqueries are not global

-- SUBQUERY CATEGORIES

-- based on DEPENDENCY 
-- non-corelated subquery - subquery is independent of main query
-- corelated subquery - subquery is depend upon main query

-- based on result 
-- when subquery return a scalar value 
-- when subquery returns a multiple rows but single column 
-- when subquery returns a table i.e multple rows and multiple columns

-- based on location/clauses
-- SELECT 
-- FROM 
-- JOIN like before a join 
-- WHERE we can use it two types of operators
-- comparison operator(<,>,>=,<=,=)
-- logical operator(IN/ANY/ALL/EXIST)

-- task:find the products that have a price higher than the avg price of all products
-- Main QUery
SELECT * FROM
	-- SUBQUERY
	(
    SELECT 
    productid,
    price,
    AVG(price) OVER() AS avg_price
    FROM products
	)t
WHERE t.price> t.avg_price  ; 

-- task: Rank th ecustomers based on their total amount of sales
SELECT *,
RANK() OVER(ORDER BY total_sales DESC) 
FROM

	-- SUBQUERY 
	(SELECT 
	customerid,
	SUM(sales) AS total_sales
	FROM orders
	GROUP BY customerid) t;
    
-- How database server excecutes the subquery
-- db engine will execute the subquery and retrieve the result from the disk storage the user data
-- and store thet result in caahche storage for faster exceution of main query 
-- it will forward result to db engine and db engine gonna forward result to client side
-- and subquery result gonna be delete from chache	
    
-- subquery in select clause
-- used to agg data side by side with main queries data 
-- allowing for direct comparison
-- result of this subquery should be a scalar i.e a single value 

-- task: show the productIDs,names,prices and total number of orders
-- Main Query
SELECT
productid,
product,
price,
-- subquery
(SELECT COUNT(*) FROM orders) AS Total_orders
FROM products  ;

-- SUBQUERY IN JOIN CLAUSE
-- used to prepare data (filtering or aggregation)
-- before joining with tables
-- show all the customer details and find total orders of each customer
SELECT * FROM customers c 
LEFT JOIN
	(SELECT 
	customerid,
	COUNT(orderid)
	FROM orders 
	GROUP BY customerid) t
ON c.customerid=t.customerid;  

-- SUBQUERY IN WHERE CLAUSE
-- Used for complex filtering logic and makes query more flexible and dynamic 

-- Find th eproducts that have price higher than avg price of all products

SELECT 
productid,
price
FROM products 
WHERE price > (SELECT avg(price) FROM products);

-- now using a logical operator IN
-- task:select orders whose customers are from germany
SELECT * FROM orders
WHERE customerid IN (SELECT customerid FROM customers
WHERE country = 'Germany') ;

-- USing operator ANY/ALL
-- task: check the female employees whose salary is greater than any of male employee
-- task: check the female employees whose salary is greater than all of male employ

SELECT * FROM employees
WHERE gender = 'F' AND salary > ANY(SELECT salary FROM employees
WHERE gender = 'M') ;

-- all
SELECT * FROM employees
WHERE gender = 'F' AND salary > ALL(SELECT salary FROM employees
WHERE gender = 'M') ;

-- lets discuss subquery based on their dependency 
-- corelated subquery is depend upon main query 
-- first main query is going to execute and then is will pass data to subqueryy
-- if subquery gives the result then the specific row is going to display
-- and it is going to continue for each row can say its an iterative process

-- task:print all the details of customer and count of total order made by each customer
SELECT * ,
     -- corelated subquery here we r filtering first then counting
	(SELECT 
    COUNT(*) 
    FROM orders o 
    WHERE o.customerid = c.customerid)
FROM customers c;

-- non-corelated subquery / correlated subquery
-- independent of main query/depend on main query
-- excecuted only once/excecute for each row processed by main query
-- can be excecuted on its own/cant be excecuted on its own
-- easyb to read/complex to read
-- static comparison / row by row comparison

-- CORELATED SUBQUERY USING OPERATOR EXIST
-- exist operator checks whether subquery returns any result or not 
-- task: show all the details of customers in germany 

SELECT * 
FROM orders o
WHERE  EXISTS
	(SELECT 1 
    FROM customers c 
    WHERE country = 'Germany' 
    AND
    c.customerid = o.customerid);
    
-- SUBQUERY SUMMARY
-- query inside another query 
-- breaks the complex query into smaller,manageable pieces
-- USECASES
-- create temporary result set
-- prepare data before joining table
-- dynamic and complex filtering
-- check existence of rows from other table (exists)
-- row by row comparison using corelational subquery

-- CTE (Common Table Expression)
-- temporary named result(virtual table)
-- can be used multiple times in your query 
-- to simply and organize complex query 

-- in one line : 
-- virtual table which can be used inside query to solve complex logic

-- subquery vs cte 
-- cannot be resued / can be reused multiple times
-- bottom top approach / top down approach
-- only main query has access / can access from any query

-- Non-recursive cte -- excecuted only once without any repitition
-- STAND ALONE CTE
-- find the total sales per customer

WITH cte_total_sales AS
(
SELECT 
	customerid,
    SUM(sales) AS total_sales
    FROM orders
    GROUP BY customerid
)

-- MAIN QUERY
SELECT 
c.customerid,
c.firstname,
c.lastname,
cts.total_sales
FROM customers c
LEFT JOIN 
cte_total_sales cts
ON cts.customerid = c.customerid;

-- MULTIPLE STAND ALONE CTES
WITH 
cte_total_sales AS
(
SELECT 
	customerid,
    SUM(sales) AS total_sales
    FROM orders
    GROUP BY customerid
),
cte_last_order AS
(
SELECT 
	customerid,
    MAX(orderdate) AS last_order
    FROM orders
    GROUP BY customerid
),
-- nested cte - a cte inside a cte
-- task:rank each customer based on their total sales
cte_rank_customer AS
(
SELECT 
	customerid,
    total_sales,
    RANK() OVER(ORDER BY  total_sales DESC) AS rank_customers
    FROM  cte_total_sales
),
-- nested cte customer segmentation based on total sales
cte_customer_segment AS
(
SELECT 
	customerid,
    total_sales,
    CASE
        WHEN total_sales > 100 THEN 'High'
		WHEN total_sales > 80 THEN 'Medium'
        ELSE 'Low'
    END   AS customersegments  
    FROM  cte_total_sales
)

-- testing 
-- SELECT * FROM cte_customer_segment;

-- MAIN QUERY
SELECT 
c.customerid,
c.firstname,
c.lastname,
cts.total_sales,
clo.last_order,
crc.rank_customers,
ccs.customersegments
FROM customers c
LEFT JOIN 
cte_total_sales cts
ON cts.customerid = c.customerid
LEFT JOIN cte_last_order clo
ON clo.customerid = c.customerid
LEFT JOIN cte_rank_customer crc
ON crc.customerid = c.customerid
LEFT JOIN cte_customer_segment ccs
ON ccs.customerid = c.customerid;

-- cte best practices 
-- rethink of merge cte into 1 cte if its possible 
-- best practcice is not to have more than 5 ctes in 1 query

-- Recursive CTE
-- self-referencing query that repeatedly process data untill specific condition is met 
-- two parts 
-- 1. anchor query -- interact with db and pass the result to recursive cte
-- 2. recursive query -- excetuted multiple times untill specific condition is met

-- task: select the series of number from 1 to 20 
WITH RECURSIVE series AS(
	SELECT 1 AS MyNumber -- anchor query
    UNION ALL
    SELECT 
    MyNumber + 1 -- recursive query
    FROM series
    WHERE MyNumber < 20
)
SELECT * FROM series;

SELECT VERSION();

-- task: find th elevel heirarchy for employess 
USE salesdb;
WITH RECURSIVE cte_heirarchy AS
(   
    -- Anchor Query
	SELECT 
    employeeid,
    firstname,
    managerid,
	1 AS level
	FROM employees
	WHERE managerid IS NULL
    
    UNION ALL
    
    -- Recursive Query
    SELECT 
    e.employeeid,
    e.firstname,
    e.managerid,
    level + 1
    FROM employees e
    INNER JOIN cte_heirarchy cth
    ON e.managerid = cth.employeeid
    
)
SELECT * FROM cte_heirarchy;

-- CTE SUMMARY 
-- it is temporary named result set that can be used multiple times within a query 
-- advantage: 
--        - readability (breaks complex query into smaller piece)
--        - modularity (peices are asy to manage,develop,self-contained)
--        - reusability (reduce redundancy in query)
--        - recursive(iteration and looping in sql)
-- result of cte is like table but cant be used from multiple queries
-- tip - dont create more than 5 ctes in one query

-- VIEW 
-- it is not a query that we excecute in sql 
-- it is an object that we find in database

-- lets discuss the whole structure of database

-- sql server - it manages all the daatbases
-- its like control server that stores,manages,and provide access to database
-- for users or applications

-- we have multiple databases in our sql server
-- database - collection of information that is stored in structured way 

-- inside each database we have multiple schemas 
-- schema - logical layer that group related objects together 

-- inside schema we can find multiple tables 
-- table - a place where data is stored and organized into rows and columns 

-- inside the schema we have another kind of objects we called it views
-- view - it is virtual table that shows the data without storing it physically
-- we have a columsn amd keys inside our table as also views
-- inside our column we have column name and data type 
-- now we can see our database structure is really organized 
-- first node is sql server and last node is column name and datatype

-- to manage this structure we have set of commands we called it as DDL
-- Data Defination Language
-- it is a set of commands that allow us to define and manage structure of database 
-- we have commands like 
-- CREATE
-- ALTER
-- DROP

-- 3 levels of database structure 
-- there is 3 level of data asbtraction in database architecture 

-- physical(internal) level 
-- this is an internal level where a data base admin manages all the data files
-- partitions,logs,catalogs,blocks and caches and this is one of the most complicated layer

-- logical(conceptual) level - we usually deal with how to organize our data 
-- we have data engineers that access this level in order to define structure of our data 
-- it usually focuses on how to structure our data rather than storage 
-- in this level a developer usually creates tables , relationship between those tables ,
-- views, indexes,procedures,functions
-- it is less complicated than physical layer 
-- it provides layer of abstraction for developer where they usually dont care about where data is storing physically

-- view(external) level
-- view level is highest level of abstraction in the database 
-- it is where end users and applications can access and see 
-- e.g we can create view1 for business analyst
-- view2 for representaion using dashboards
-- viewN for end users 

-- what is view 
-- a virtual table in sql based on the result of query without storing data in databse 
-- views are persisted sql query in dataabse 
-- view is like a layer of abstraction between us and a real data 

-- USECASE 
-- lets say if some logic is repeating in the multiple sql query  
-- we can save its script as a view thats how we can centralized the logic
-- whoever required that centralized logic can use it anytime

-- VIEW vs CTE
-- reduce redundancy in multiple queries
-- reduce redundancy in 1 query

-- improve reusability in multiple queries
-- improve reusability in single query

-- persisted logic(logic is so imp so we persist it)as
-- temporary logic (on the fly we use it)

-- need a maintenance like CREATE/DROP
-- no mainatenance required it gets auto cleanup

-- SQL VIEWS 
-- CREATE
-- UPDATE
-- DROP

-- lets discuss how we create a view in databse 
-- task: find the running total of sales for each month
CREATE VIEW V_Monthly_Summary AS
(
	SELECT 
    EXTRACT(MONTH FROM orderdate) AS month_no,
    SUM(sales) AS total_sales,
    COUNT(orderid) AS total_orders,
    SUM(quantity) AS total_quantity
    FROM orders
    GROUP BY month_no
);
-- using view
SELECT *,
SUM(total_sales) OVER(ORDER BY month_no)
FROM v_monthly_summary;

-- How to update a view defination 
CREATE OR REPLACE VIEW V_Monthly_Summary AS
(
	SELECT 
    EXTRACT(MONTH FROM orderdate) AS month_no,
    SUM(sales) AS total_sales,
    COUNT(orderid) AS total_orders
    FROM orders
    GROUP BY month_no
);

-- How to delete a view
DROP VIEW v_monthly_summary;

-- how database excecutes view 
-- whenever we write a sql query to create view and excecute it 
-- database engine will recoginze it as a view 
-- and it is going to store it in a disk storage in catalog 
-- db engine will store all the meta data and a view query in system catalog
-- db engine will retrieve query from the catalog 
-- and query is going to excecute first 
-- and it is going to retrieve the data from the physical table
-- now we have the retrieve data for the end user 
-- now the query from end user is going to execute 
-- db engine will send this retrieve data to our end user data analyst
-- this gonna happen every time end user selecting the data fro the view 

-- now if end user wants to delete the view 
-- lets say if he has write drop view
-- db engine will delete the metadata and sql query from system catalog
-- as we see when we r dropping the view we r not loosing actual data 

-- 2nd USECASE 
-- Hide Complexity
-- lets say we need few information from each table in order to join them again and agian
-- we can write complex sql query and store it as a view so that user can have easy interaction
-- this way we can provide an abstraction as well easy and freindly interaction to end user
-- task: provide view that combine details from orders,products,customers and emplyees

CREATE VIEW  v_order_details AS
(
	SELECT 
	o.orderid,
	o.orderdate,
	p.product,
	p.category,
	CONCAT(COALESCE(c.firstname,''),' ',COALESCE(c.lastname,'')) AS cust_name,
	c.country,
	CONCAT(COALESCE(e.firstname,''),' ',COALESCE(e.lastname,'')) AS emp_name,
	e.department,
	-- salespersonid,
	o.sales,
	o.quantity
	FROM orders o
	LEFT JOIN products p 
	ON p.productid = o.productid
	LEFT JOIN customers c
	ON c.customerid = o.customerid 
	LEFT JOIN employees e 
	ON e.employeeid = o.salespersonid
);

-- test the view 
SELECT * FROM v_order_details;

-- 3rd usecase Data Security 
-- create view in order to protect your data before sharing it with end user 
-- task : exclude the data from usa 
CREATE VIEW  v_order_details_not_usa AS
(
	SELECT 
	o.orderid,
	o.orderdate,
	p.product,
	p.category,
	CONCAT(COALESCE(c.firstname,''),' ',COALESCE(c.lastname,'')) AS cust_name,
	c.country,
	CONCAT(COALESCE(e.firstname,''),' ',COALESCE(e.lastname,'')) AS emp_name,
	e.department,
	-- salespersonid,
	o.sales,
	o.quantity
	FROM orders o
	LEFT JOIN products p 
	ON p.productid = o.productid
	LEFT JOIN customers c
	ON c.customerid = o.customerid 
	LEFT JOIN employees e 
	ON e.employeeid = o.salespersonid
    WHERE c.country != 'USA'
);

-- 4th USECASE 
-- flexibility and dynamic
-- lets say if you splitting table into 2 
-- just update your view using union or union all so other user can use it

-- VIEW SUMMARY 
-- virtual table based on result of query without storing data
-- we use views to persist complex sql queries in database 
-- views are better than cte - reusability in multiple queries 
-- views are better than tables - flexible and easy to maintain

-- USECASE
-- store central complex business logic to be reused 
-- hide complexity by offering freindly view to user
-- data security by hiding sensitive rows of columns
-- flexibility and dynamic
-- offer your object in multiple language
-- virtual layer datamarts in datawarehouse


-- DB Table 
-- A table is a structured collection of data similar to spreadsheet or grid
-- it has rows and columns and intersection of a row and column is called as cell
-- table is an layer of abstraction for a dev 
-- actual data is stored in data files in disk storage 
-- whenever we write a sql query it is gonna retrieve the actual data from daafiles in the form of table

-- TWO TYPES 
-- permanent table 
-- temporary table 

-- two ways to create permanant table 
-- 1. by writing a query create/insert
-- 2. CTAS it creates a table but based on sql query
-- where we write a query just to retrieve data from the table we have created

-- ctas vs view
-- when we make a table using sql query it is going to create a permanent table 
-- and data is going to stored in that table ,so everytime we run a sql query 
-- though the data is already stored the results gonna be faster 
-- result is going to faster
-- where as in views everytime it has to retrieve the data first than results 
-- gonna be excecuted , its going to be sloweer

-- 2nd big diff is updated info 
-- ctas results will be outdated bcoz the query has already excecuted and result has already stored
-- views result will be updated bcoz data is gonna retrieve at runtime from main table 
-- if there is any change in main table its going to reflect in a view

-- lets see how to create a ctas
CREATE TABLE MonthlyOrders AS 
(
	SELECT 
    MONTHNAME(orderdate) AS order_month,
    COUNT(orderid)
    FROM orders
    GROUP BY order_month
);

-- how to drop 
DROP TABLE MonthlyOrders;

-- how to refresh CTAS using truncate if we want same table
TRUNCATE TABLE MonthlyOrders;

INSERT INTO MonthlyOrders
SELECT 
    MONTHNAME(orderdate) AS order_month,
    COUNT(orderid)
    FROM orders
    GROUP BY order_month;
    
-- 2nd usecase 
-- to create  persisted snapshot of data 
-- to analyze data quality issue  

-- 3rd usecase 
-- physical data mart 
-- persisting the data marts pf a DWH improves speed of data retrieval compared to using views

-- TEMPORARY TABLE
-- stores intermediate results in temporary storage within database during session
-- db will drop all the temporary tables once the session ends
-- it is like CTAS only but its not permanent 
-- it is going to delete from database automatically once the session ends 

-- how to create temporary table using #
CREATE TEMPORARY TABLE temp_orders AS
(
	SELECT * FROM orders
);
SHOW TABLES LIKE 'temp_orders';
SELECT * FROM temp_orders;
DELETE  FROM temp_orders
WHERE orderstatus = 'Delivered';

-- how dataabse excecutes temp tables 
-- when the query gets excecuted 
-- db engine will going to store metadata in system catalog 
-- and it is going to store data in temp storage
-- once the session ends the connection with user will break 
-- and db engine will going to cleanup everything in temp storage

-- temp usecase 
-- intermediate result
-- lets say if we r doing extract transform load
-- we can extract from our source database
-- perform some transformations using temp tables 
-- so it will be automatic cleanup after whole session ends
-- then we can store it or load  permanently in our destination db

-- SQL TABLES SUMMARY 
-- structued collection of data like spreadsheets(columns and rows)
-- 2 types - permanent (data lives forever in database)-CREATE_INSERT/CTAS
--         - temporary (data live only during the session)
-- CTAS USECASE
-- optimize performance - persist complex SQL Logic in table
-- creating snapshot - to analyze bugs and data issues 

-- Advantage of temp tables - automatic cleanup of data after session ends

-- COMPARISON
-- Subquery vs CTE vs Temp vs CTAS vs VIEWS
-- storage - memory cahche, memory cache, disk,disk,doent get stored
-- life time - temporary,temporary,temporary,permanent,permanent
-- when deleted - end of query , eoq,end of session, ddl-drop,ddl-drop
-- scope - single query,sq,multiple queries,mqs,mqs
-- reusability - 1place-1query,many place-1query,multi queries only during session,multi queries any time
-- up2date - always,always,never,never,always

-- SQL PROJECT BIG PICTURES

-- STORED PROCEDURES
-- A stored procedure is a saved SQL program that you can reuse.
-- A function that runs multiple SQL statements
-- Helps automate tasks and improve performance
-- we can store sql queries inside the databse whenver we need to execute those queries
-- we can simply go to database and excecute our stored procedures 

-- stored procedure vs query
-- query is a one time request on the other hand in stored procedure 
-- there will be multiple sql statemnts if you r exceuting sp there will be multple 
-- interactions with database that means you will have multiple transactions happening in sp

-- query is a single request whereas sp is like a program
-- e.g we can go and build looping logic 
-- control flow like if-else and we can parameter and variable in order to make our code flexible
-- as well as we can build error handling code

-- stored procedure vs python code 
-- it is precompiled while its not
-- no need to build the connection it is on same server , need to build the connection bcoz it is on diff server
-- whereas in python we can have version control , code can be more flexible
-- as well as we can build complex logic 
-- its recommended not to have a stored procedures in a big project
-- it can create complexity and can be chaotic

-- well lets understand how to build a stored procedure if you r working in mini project
-- stored procedure basics 
DELIMITER //
CREATE PROCEDURE GetCustomerSummary(IN countryName VARCHAR(50)) 
BEGIN 
	SELECT 
    COUNT(*) AS total_customers,
    AVG(score) AS AvgScore
    FROM customers
    WHERE country = 'USA';
END // 
DELIMITER ; 

-- how to excecute stored procedure
CALL  GetCustomerSummary();

-- parameters in stored procedures
-- placeholders used to pass values as a input to the procedure from the caller 
-- allowing dynamic data to be processed
DROP PROCEDURE IF EXISTS GetCustomerSummary;
DELIMITER //
CREATE PROCEDURE GetCustomerSummary(IN countryName VARCHAR(50)) 
BEGIN 
	SELECT 
    COUNT(*) AS total_customers,
    AVG(score) AS AvgScore
    FROM customers
    WHERE country COLLATE utf8mb4_general_ci = countryName COLLATE utf8mb4_general_ci ;
END // 
DELIMITER ; 
SET @country = 'USA';
CALL  GetCustomerSummary(@country);
SHOW FULL COLUMNS FROM customers;

-- task: find total no of orders and total sales
-- multiple sql statemtnts inside the sp
DROP PROCEDURE IF EXISTS GetCustomerSummary;
DELIMITER //
CREATE PROCEDURE GetCustomerSummary(IN countryName VARCHAR(50)) 
BEGIN 
	SELECT 
    COUNT(*) AS total_customers,
    AVG(score) AS AvgScore
    FROM customers
    WHERE country COLLATE utf8mb4_general_ci = countryName COLLATE utf8mb4_general_ci ;
    SELECT 
    COUNT(orderid) total_orders,
    SUM(sales) total_sales
    FROM orders o
    JOIN customers c
    ON c.customerid = o.customerid
    WHERE country COLLATE utf8mb4_general_ci = countryName COLLATE utf8mb4_general_ci ;
END // 
DELIMITER ; 
SET @country = 'USA';
CALL  GetCustomerSummary(@country);

-- stored procedure variables
-- variable - placeholder used to store values to be used later in procedure
-- control logic using if-else
DROP PROCEDURE IF EXISTS GetCustomerSummary;
DELIMITER //
CREATE PROCEDURE GetCustomerSummary(IN countryName VARCHAR(50),OUT message VARCHAR(100), OUT total_customers INT) 
BEGIN 
    -- DECLARE total INT DEFAULT 0;
	DECLARE avg_score DECIMAL(10,2);
	SELECT 
    COUNT(*)  , AVG(score) 
	INTO total_customers, avg_score
    
    
	FROM customers
    WHERE country COLLATE utf8mb4_general_ci = countryName COLLATE utf8mb4_general_ci ;
    -- IF logic to set message
    IF total_customers = 0 THEN
        SET message = 'No customers found';
    ELSEIF total_customers < 10 THEN
        SET message = 'Few customers found';
    ELSE
        SET message = 'Many customers found';
    END IF;
END // 
DELIMITER ; 
SET @country = 'USA';
SET @total = 0;
SET @msg = '';
CALL  GetCustomerSummary(@country,@msg,@total);
SELECT @total AS TotalCustomers, @msg AS Message;

-- TRIGGERS
-- special stored procedures that automatically runs in response to specific event on a table or view
-- based on any changes to table we can trigger another event 
-- trigger usecase 
-- 1. logging
-- logs are the record of activities or action that happen in system
-- lets create a table log 
USE salesdb;
CREATE TABLE EmployeeLogs(
	LogID INT PRIMARY KEY,
    employeeid INT,
    logmessage VARCHAR(50),
    logdate DATE
);

-- lets create a trigger
DELIMITER //
CREATE TRIGGER  trg_after_insert_employee  AFTER INSERT  ON employees
FOR EACH ROW
BEGIN 
	INSERT INTO EmployeeLogs(employeeid,logmessage,logdate)
    VALUES 
		(
        NEW.employeeid,
        CONCAT('New Employee Added =',CAST(NEW.employeeid AS CHAR(50))),
        CURDATE()
        );
	 
END //
DELIMITER ;

-- lets trigger our trigger 
SELECT * FROM EmployeeLogs;

ALTER TABLE EmployeeLogs 
MODIFY COLUMN LogID INT NOT NULL AUTO_INCREMENT ;

INSERT INTO employees(employeeid, firstname, lastname, department, birthdate, gender, salary, managerid)
VALUES 
(6,'Haria','poe','MR','1989-01-12','F',80000,3),
(7,'Maria','Doe','HR','1988-01-12','F',80000,3)

