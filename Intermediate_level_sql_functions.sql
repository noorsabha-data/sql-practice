-- FUNCTIONS -  take some input value do some calculations and return output
-- ROW LEVEL FUNCTIONS
-- Two Types - 1.Single-Row-Functions - single i/p value and single o/p value (one value in / one value out) e.g LOWER()
-- 2.Multi-Row-Functions - multiple i/p value and suingle o/p value e.g - SUM()
-- NESTED FUNCTIONS - function inside a function e.g-LOWER(LEFT('Maria',2)) , o/p of inner function is input to outer function

-- SINGLE ROW FUNCTIONS
-- 1.string functions
-- 2.numeric function
-- 3.date&time function 
-- 4.null function

-- MULTI ROW FUNCTIONS
-- 1.aggregate function (basic)
-- 2.window function (advanced)

-- string function 
-- 1. manipulation - upper/lower/trim/replace/concat
-- 2. calculation - length
-- 3. string extraction - left/right/substring

-- CONCAT 
SELECT CONCAT(first_name,"-",country) AS name_country 
FROM customers;

-- UPPER 
SELECT UPPER(first_name) AS upper_case
FROM customers;

-- LOWER
SELECT LOWER(first_name) AS lower_case
FROM customers;

-- TRIM - to remove leading & trailing space
-- removing leading and trailing spaces
UPDATE customers
SET first_name = TRIM(first_name)
WHERE TRIM(first_name) != first_name;

SELECT first_name 
FROM customers 
WHERE TRIM(first_name) != first_name;

-- simple way to check extra spaces 
-- counts number of bytes
SELECT first_name ,
LENGTH(first_name),
LENGTH(TRIM(first_name)),
LENGTH(first_name) - LENGTH(TRIM(first_name)) AS flag
FROM customers ;


-- simple way to check number of characters
-- counts number of char
SELECT first_name ,
CHAR_LENGTH(first_name),
CHAR_LENGTH(TRIM(first_name))
FROM customers ;

-- REPLACE
-- 1.
SELECT 
'123-456-789-0' AS phone_number,
REPLACE('123-456-789-0','-','') AS clean_phone_number;

-- 2.
SELECT 
'requirement.txt' AS text_file,
REPLACE('requirement.txt','.txt','.csv') AS csv_file;

-- string extraction
-- LEFT() to extract from starting posn
-- RIGHT() to extract value from ending posn
-- SUBSTRING()
SELECT 
first_name,
LEFT(first_name,2),
RIGHT(TRIM(first_name),2),
SUBSTRING(TRIM(first_name),2,LENGTH(first_name))
FROM customers;

-- NUMBER FUNCTION

-- ROUND 
SELECT 
ROUND(3.516,2), -- 6>1
ROUND(3.516,1), -- 1<5
ROUND(3.516,0) ;-- 5>3

-- ABS
SELECT 
ABS(-10),
ABS(10);

-- DATE FUNCTIONS
-- TIMESTAMP
USE salesdb;

SELECT
orderid,
orderdate,
WEEK(orderdate),
EXTRACT(SECOND FROM creationtime),
EXTRACT(quarter FROM orderdate),
DAYNAME(orderdate),
MONTH(orderdate),
MONTHNAME(orderdate),
YEAR(orderdate),
shipdate,
creationtime,
DATE(creationtime),
'2025-08-02' AS hardcoded,
TIMESTAMP('2025-08-02') AS notHardCoded,
NOW() AS Today,
CURRENT_DATE() AS date
FROM orders;

SELECT DATE_TRUNC('YEAR', '2026-03-13 15:45:10');

SELECT
LAST_DAY(orderdate),
DATE_FORMAT(orderdate,'%y-%m-01')
FROM orders;

-- usecase datetime extraction function 
-- 1. to check how many product are sold during each year 

SELECT 
YEAR(orderdate),
COUNT(*)
FROM orders
GROUP BY YEAR(orderdate);

-- each month
SELECT 
MONTHNAME(orderdate),
COUNT(*)
FROM orders
GROUP BY MONTHNAME(orderdate);

-- subset month of february
SELECT 
*
FROM orders 
WHERE MONTH(orderdate) = 2;

SELECT 
DATE_FORMAT(creationtime , '%W %M %d %Y %H:%i:%s')
FROM orders;

-- CAST
SELECT CAST(DATE_FORMAT(CURRENT_TIME(),'%h %p') AS CHAR) AS now_as_string;

-- convert 
 SELECT CONVERT(DATE_FORMAT(CURRENT_TIME(),'%h %p') , CHAR) AS now_as_string;

-- DATEDIFF - result in number of days
SELECT DATEDIFF(CURRENT_DATE(),birthdate) 
FROM employees;

-- TIMESTAMPDIFF
SELECT TIMESTAMPDIFF(MONTH,birthdate,CURRENT_DATE()) 
FROM employees;

-- shipping duration in days for each order
SELECT 
orderid,
orderdate,
LAG(orderdate) OVER(ORDER BY orderdate),
TIMESTAMPDIFF(DAY,LAG(orderdate) OVER(ORDER BY orderdate),orderdate), 
shipdate,
DATE_ADD(shipdate, INTERVAL 5 YEAR),
DATE_ADD(shipdate, INTERVAL 3 MONTH),
DATE_ADD(shipdate, INTERVAL 4 DAY),
TIMESTAMPDIFF(DAY,orderdate,shipdate) 
FROM orders;

--  STR_TO_DATE to check whether its a valid date or not 
SELECT 
Orderdate ,
CASE 
WHEN  STR_TO_DATE(OrderDate,'%Y-%m-%d')  IS NOT NULL THEN CAST(OrderDate AS DATE)
ELSE '9999-01-01'
END AS cast_order_date
FROM (
SELECT '2020-08-01' AS OrderDate 
UNION 
SELECT '2020-08-03'
UNION 
SELECT '2020-08-02'
UNION
SELECT '2020-08'

)t
WHERE  STR_TO_DATE(OrderDate,'%Y-%m-%d')  IS NOT NULL;


-- Now we will learn how to handle null inside our data
-- For that we will learn NULL Functions
-- 1. we can replace it with a static value
-- 2. we can replace with a specific column 

-- 1.IFNULL(NULl,'N/A')
-- 2.IFNULL(orderdate,shippingdate)and

-- COALESCE (oderdate,shippingdate,'N/A') -- ||rly we can add more values
-- it will replace orderdate null values by shipping date 
-- if there is any NULL value in shippingdate it will replace it with 'N/A'(static value)

-- USECASE alter

-- 1.handling values during data aggregation
USE salesdb;

SELECT
customerid,
score,
avg(score) OVER() AS 'avg_score',
AVG(COALESCE(score,0)) OVER() AS 'avg_score2'
FROM customers;

-- 2. Mathematical Operations (handling nulls)
SELECT
customerid,
firstname,
lastname,
COALESCE(lastname,""),
CONCAT(firstname," ",COALESCE(lastname,"")) AS full_name,
score,
COALESCE(score,0)+10
FROM customers;

-- 3.handling nulls before doing joins
-- special case - null inside keys
-- if our keys are null while joining it will not consider null value is same with another null value
SELECT 
c.firstname , c.lastname
FROM customers c
JOIN employees e
ON COALESCE(c.firstname," ") = COALESCE(e.firstname," ")
AND  COALESCE(c.lastname," ") =  COALESCE(e.lastname," ");

-- 4.Handling NULL while sorting data 
-- if sorting ASC sql gonna put null values at the top 
-- not bcoz it is lowest bcoz null means no value 
-- but sql show it like this it gonna place it on top 
-- after that it will put values from lowest to highest
-- TWO WAYS 
-- 1.lazy way - replace null with highest value by using coalesce 
-- 2. professional way - setting flag for null then sorting it by using nested order by 

SELECT 
score ,
score IS NULL AS flag
FROM customers
ORDER BY flag , score;

-- NULL IF function is used for data quality check 
-- e.g price cannot be negative 
-- e.g discount price cannot be same as original price 
-- NULLIF(v1,v2) = v1 if v1!=v2 ELSE NULL
-- lets take an example divinding by 0 will give an error lets tackle it using ifnull
SELECT 
orderid,
sales,
quantity,
sales/ NULLIF(quantity,0) AS price
FROM orders;

-- IS NULL / IS NOT NULL return a boolean values which we treat as flag
-- USE CASE - searching for missing info or NULLS 
SELECT * 
FROM customers
WHERE score IS NULL;

-- ||rly whose score is not null
SELECT * 
FROM customers
WHERE score IS NOT NULL;

-- IS NULL use case in anti joins - to find unmatching data
--  customers who has not placed any orders
SELECT c.customerid,
c.firstname,
c.lastname,
o.orderid,
o.customerid
FROM customers c
LEFT JOIN orders o
ON c.customerid=o.customerid
WHERE o.customerid IS NULL;

-- how to tackle empty string '' and spaces' ' in data 
with orders as (
SELECT 'A' AS customer_name 
UNION
SELECT NULL 
UNION
SELECT ''
UNION
SELECT '  '
)

SELECT * ,
LENGTH(customer_name),
TRIM(customer_name),
LENGTH(TRIM(customer_name)),
NULLIF(TRIM(customer_name),'') AS ploicy1,
COALESCE(NULLIF(TRIM(customer_name),''),'unknown') AS policy2
FROM orders;

-- NULL summary 
-- NULLs special markers means missing value 
-- using nulls optimize storage and performance 

-- FUNCTIONS - IFNULL , COALESCE , NULLIF, IS NULL , IS NOT NULL 

-- usecases
-- 1. agg function 
-- 2. performing mathematical operation 
-- 3. joining if key is null 
-- 4. sorting data in ascending and wants null value at last 
-- 5. left anti join finding unmatching data 
-- 6. data policies - null(before entering data into database for memory optimization)
-- default value like unknown while preparing data to represent in front of user

-- CASE STATEMENT 
-- it is used for evaluating a list of condition one by one and returning a value
-- when the specific 1st condition is met 

-- USECASE - categorizing a data (grouping a data into categories based on certain condition)
-- main purpose - data transformation 
-- deriving new information 
-- by generating new columnn based on existing data
SELECT 
t.TotalSales,
SUM(t.sales) TotalSalesPercategory
FROM(
SELECT 
orderid,
sales,
CASE
    WHEN sales>50 THEN 'High'
    WHEN sales>20 THEN 'Medium'
    ELSE 'Low'
END  AS TotalSales  
FROM orders) t
GROUP BY t.TotalSales
ORDER BY TotalSalesPercategory DESC;

-- RULE - return result values must be of compatible data type 
-- e.g if u r returning 'pass' when condition is true return 'fail' when condn is false not 0
-- 2. it can be used any where select,from,groupby,orderby 

-- #2nd USECASE
-- Mapping Values - translating code values into readable values
-- e.g retrieve employees details with gender displayed as full text 
SELECT 
employeeid, 
firstname,
lastname,
gender,
CASE 
    WHEN gender = 'M' THEN 'Male'
    WHEN gender = 'F' THEN 'Female'
    ELSE NULL
END AS full_gender    
FROM employees;

-- lets map country name to its abbreviated form 
-- for that we need list of all countries from our data
SELECT 
DISTINCT country
FROM customers;

-- now lets map
SELECT
customerid,
firstname,
lastname,
country,
CASE
    WHEN country='Germany' THEN 'DE'
    WHEN country='USA' THEN 'US'
    ELSE 'N/A'
END AS abrr_country
FROM customers;

-- QUICK FORM
-- rest - we can use only one column and it is for only equal to opertr
SELECT
customerid,
firstname,
lastname,
country,
CASE country
    WHEN 'Germany' THEN 'DE'
    WHEN 'USA' THEN 'US'
    ELSE 'N/A'
END AS abrr_country
FROM customers;

-- 3rd USECASE - Handling NULLs
-- performed agg on the basis of NULL
SELECT 
customerid,
score,
AVG(score) OVER(),
CASE
    WHEN score IS NULL THEN 0
    ELSE score
END AS score_clean,
AVG(
CASE
    WHEN score IS NULL THEN 0
    ELSE score
END
) OVER () AS cleaned_score_avg
 FROM customers;   

    
-- 4.USECASE - conditional aggregation
-- applying aggregate function only on subset of data that meets specific condition
-- performed agg on the basis of flag
SELECT 
customerid,
SUM(CASE 
    WHEN sales>20 THEN 1 
    ELSE 0
END) AS sales_count  ,
COUNT(sales)  
FROM
orders
GROUP BY customerid ;

-- performing agg not on the basis of flag
SELECT 
customerid,
SUM(CASE 
    WHEN sales>30 THEN sales
    ELSE 0
END) AS sales_amount,
SUM(sales)  
FROM
orders
GROUP BY customerid ;

-- CASE STATEMENT SUMMARY
-- evaluating a list of conditions and returning a value when 1st condition is met 
-- rule - data type of returning values must be same for compatibility 
-- usecase - deriving new information 
-- 1. categorization 
-- 2. mapping values 
-- 3.handling nulls by using conditional agg 
-- 4. conditional aggregation 
--    - using flag 
--    - using a specific condition 

-- AGGREGATE AND ANALYTICAL FUNC?TIONS
-- usually used to uncover insights about our data
-- AGGREGATE FUNCTIONS - multiple i/p and only single o/p
SELECT 
customerid,
COUNT(sales),
SUM(sales),
AVG(sales),
MAX(sales),
MIN(sales)
FROM orders
GROUP BY
customerid;

-- analyse score in our data 
SELECT DISTINCT score FROM customers;

SELECT 
CASE
    WHEN score > 750 THEN 'High'
	WHEN score > 350 THEN 'Medium'
    ELSE 'Low'
END AS scoreCat,
SUM(score),
COUNT(score),
AVG(score),
MAX(score),
MIN(score) 
FROM customers
GROUP BY scoreCat;

-- WINDOW FUNCTIONS - ANALYTICAL FUNCTIONS
-- performing calculations e.g aggregation on subset of data without loosing level of details of row

-- WINDOW VS GROUP BY 
-- - group by does agg but compress details of row/used for simple data analysis/has only agg function
-- - window does agg but keeps details of row/used for advanced data analysis/has more advanced function for analyzing the data

-- WHY WINDOW -
-- GROUP BY Limitations - we cannot provide agg and details at same time
-- WINDOW provides granularity in result i.e returns a result for each row
-- in order to show agg as well as other information we use window function 
SELECT 
orderid,
orderdate,
productid,
SUM(sales) OVER(partition by productid)
FROM orders;

-- WINDOW SYNTAX 
-- two parts 
-- 1. window function or agg function 
-- 2. over clause - contains 3 main clause 
--                1. partition clause
--                2. order clause
--                3. Frame clause 

-- list of window functions
-- 1.Aggregate Functions - count(exp-all data types)/sum/avg/min/max-(exp - numeric)
-- 2.Rank Functions - row_number/rank/dense_rank/cume_dist/percent_rank-(no exp)/ntile(numeric)
-- 3.value(Analytical Function) - lead/lag/first_value/last_value(exp-all datatypes)

-- over clause 
-- 1.it tells sql that we r using window function
-- 2.it is used to define window/subset of data using partition by 
--   3 variation of partition by 
--   1. we can skip partition by - over()
--   2. we can use single column - over(parttion by column1)
--   3. we can use multiple columns - over(partition by column1,column2)

-- task:total sales across all orders and provide orderid,order date
-- total sales across all orders product id and provide orderid,order date
-- total sales across all orders on the basis of productid and orderstatus and provide orderid,order date
SELECT
orderid,
orderdate,
orderstatus,
 productid,
SUM(sales) OVER() total_sales,
SUM(sales) OVER(PARTITION BY productid) total_sales1,
SUM(sales) OVER(PARTITION BY productid,orderstatus) total_sales2
FROM orders;

-- over clause -2nd part ORDER BY - sort the data within the window
-- we can skip order by for agg functions 
-- but for rank and value fynctions it is must

-- task:Rank each order based on their sales from highest to lowest
-- and provide orderid as well orderdate
SELECT
orderid,
orderdate,
sales,
RANK() OVER(ORDER BY sales DESC)
FROM orders;

-- OVER clause 3rd part FRAME 
-- It defines subset of rows within each window that is relevent for calculation
-- it contains two things - start of frame and end of frame 
-- we can define start and end of frame by using 3 values 
-- for strat of frame - current row/n preceding/unbounded preceding
-- for end of frame - current row / n following/unbounded following

-- if we dont use order by in over clause frame would be unbounded preceding and unbounded following
-- if we use order by but not frame the default frame would be unbounded preceding and current row 
-- we can use shortcut only with preceding bcoz default end of frame is current row

-- 1.default frame without orderby
SELECT
orderid,
orderdate,
sales,
SUM(sales) OVER()
FROM orders;

-- 2.default frame with order by
SELECT
orderid,
orderdate,
sales,
SUM(sales) OVER(PARTITION BY orderstatus ORDER BY orderdate DESC)
FROM orders;

-- 3.preceding shortcut default end of frame is current row
SELECT
orderid,
orderdate,
sales,
SUM(sales) OVER(PARTITION BY orderstatus ORDER BY orderdate DESC ROWS 1 PRECEDING)
FROM orders;

-- 4.using following and preceding  shortcut not applicable for following
SELECT
orderid,
orderdate,
sales,
SUM(sales) OVER(PARTITION BY orderstatus ORDER BY orderdate DESC ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
FROM orders;

-- 4 WINDOW Function Rules
-- 1. we can use it only in SELECT and ORDER BY 
-- we cannot use it to filter the data e.g with WHERE clause and GROUP BY Clause
-- 2. Nesting a window function is not allowed i.e window inside a window
-- 3. if there is window function in your sql query and a where clause 
-- sql will excecute window function after a where clause
-- 4.window function can be used with groupby only if you r using a same column

-- e.g rank the customers based on their total sales
-- first we have to finf total sales for each customer using group by 
SELECT  
customerid,
SUM(sales),
RANK() OVER(ORDER BY SUM(sales) DESC)
FROM orders
GROUP BY customerid;
-- here we see function we r using inside window function is part of group by 

-- WINDOW FUNCTION SUMMARY

-- it perform calculations on subset of data without loosing any details

-- window vs group by 
-- powerful and dynamic than groupby 
-- used in advanced data analysis 
-- we can use them together in same query only if same column is used

-- window components
-- window function 
-- over clause contains - partition by / order by / frame 

-- rules 
-- nesting is not allowed 
-- can be used only in select and order by 
-- sql excecute window after filtering data if there is where clause

-- Window aggregate functions 

-- COUNT
-- count - overall analysis 
SELECT COUNT(*) FROM orders;

-- category analysis
SELECT 
orderstatus,
COUNT(*) OVER(Partition by orderstatus)
FROM orders;

-- to check nulls
SELECT 
COUNT(*) ,
COUNT(billaddress) -- will count non null values only
FROM orders;

-- quality check finding duplicates using primary key in partition by clause
SELECT 
orderid,
COUNT(*) OVER(Partition by orderid)
FROM orders;

SELECT DISTINCT t.orderid FROM(
SELECT 
orderid,
COUNT(*) OVER(Partition by orderid) as dups
FROM orders_archive)t
WHERE t.dups > 1;

-- 2. SUM()
-- find total sales of all orders as well as per product and provide orderid,orderdate
SELECT 
orderid,
productid,
orderdate,
SUM(sales) Over() ,
SUM(sales) OVER(PARTITION BY productid)
FROM orders;

-- most imp usecase of all agg functions 
-- COMPARISON ANALYSIS
-- here we will find perecentage of each sale compare to total sale 
SELECT 
orderid,
productid,
sales,
SUM(sales) OVER() totalSales,
ROUND(CAST(sales AS DECIMAL)/ SUM(sales) OVER() *100,2)
FROM orders;

-- 3.AVG()- returns an avg of value within a window
-- handling nulls before performing any agg operation is very important 
-- task:find avg sales across all orders
-- and avg sale for each product 
SELECT 
orderid,
orderdate,
productid,
sales,
AVG(sales) OVER() AS avg_sales,
AVG(sales) OVER(PARTITION BY productid) AS product_avg_sales
FROM orders;

-- find the orders whose sales is less than avg sales
-- here we can use window func in where clause
-- we will be using subquery in it
SELECT 
t.orderid,
t.sales
FROM
(SELECT 
orderid,
orderdate,
productid,
sales,
AVG(sales) OVER() AS avg_sales
FROM orders) t
WHERE t.sales > t.avg_sales ;

-- handling NULLS before applying agg function 
SELECT 
customerid,
firstname,
lastname,
country,
score,
AVG(score) OVER() as avg_score_null,
AVG(COALESCE(score,0)) OVER() as avg_score
FROM customers;

-- 4. min()/max()
-- provides minm and maxm value over a window 
SELECT 
employeeid,
firstname,
lastname,
department,
birthdate,
gender,
salary,
managerid,
MIN(salary) OVER() as lowest_salary,
MAX(salary) OVER() as highest_salary
FROM employees;

-- employee who has the highest salary 
SELECT * FROM(
SELECT 
employeeid,
firstname,
lastname,
department,
birthdate,
gender,
salary,
managerid,
MIN(salary) OVER() as lowest_salary,
MAX(salary) OVER() as highest_salary
FROM employees
)t
WHERE t.salary = highest_salary;

-- find the extreme point min and max of sale and find the deviation of sales from them
SELECT 
orderid,
sales,
MIN(sales) OVER() AS min_sale,
MAX(sales) OVER() AS max_sale,
sales - MIN(sales) OVER() min_deviation,
MAX(sales) OVER() - sales AS max_deviation
FROM orders;

-- ANALYTICAL USECASE of min and max

-- 1. RUNNING TOTAL - agg seq of members 
-- and it gets updated everytime new member adds thats y its like time seq 
-- and its called analysis over time

-- 2. ROLLING TOTAL -- agg values within a fixed window e.g last 30 days 
-- if 31st day will get add it will drop 1st day bcoz of wndow limit
-- its called rolling or shifting window

-- used for tracking current sales with target sales 
-- it is used for trend analysis from historical pattern
-- whenever we use agg function and orderby clause in over clause we do running total
-- whenever we use agg function and orderby clause in over clause 
-- within a fixed window we do rolling total total

-- calculate moving avg of sales for each product over time
SELECT 
orderid,
productid,
sales,
AVG(sales) OVER(PARTITION BY productid) AS product_avg,
AVG(sales) OVER(PARTITION BY productid ORDER BY orderdate) AS moving_product_avg
FROM orders;

-- calculate moving avg of sales for each product over time including only next order
SELECT 
orderid,
productid,
sales,
AVG(sales) OVER(PARTITION BY productid) AS product_avg,
AVG(sales) OVER(PARTITION BY productid ORDER BY orderdate) AS moving_product_avg,
AVG(sales) OVER(PARTITION BY productid ORDER BY orderdate ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS rolling_avg
FROM orders;

-- WINDOW AGG FUNCTION SUMMARY
-- used to aggregate set of values and return one single aggregated values

-- RULES
-- count function accept all data type as an expression 
-- all other functions accept only numeric data type expression 

-- USECASES
-- overall analysis e.g overall count
-- per groups analysis e.g count per group
-- part to whole analysis sales/total sales percentage 
-- comparison anaysis between groups e.g - average / extreme points(highest & lowest)
-- identifying duplicates by doing order by on primary key inside over clause and performing count
-- outlier detection e.g sales<avg sales or > avg sales
-- Running total used for analysis over time
-- rolling total - used for analysis in a specific window 
-- moving average to analyse trend over time 

-- Ranking in WINDOW FUNCTION
-- lets say if we have to rank the data based on their sales 
-- first we will sort the data highest to lowest 
-- sql will do sorting the data first before ranking the value 

-- Two Types 
-- 1. Integer-based ranking 
-- - we assign integer value to each row based on their posn
-- it has descrete values
-- we call it as top/bottom/N analysis
-- e.g Find top 3 products
-- has 4 function - ROW_NUMBER()/RANK()/DENSE_RANK()/NTILE

-- 2. percentage based ranking-
-- sql gonna calculate relative posn of each row and then gonna assign percentage value to each row
-- between 0 to 1
-- it has continous values we call it continous scae or normalized scale
-- to understand contributions of data values to overall total
-- e.g find top 20% of product
-- this type of analysing is called Distribution Analysis
-- only 2 functions cume_dist()/percent_rank()

-- ROW_NUMBER() 
-- It provides unique rank to each row even if there value is same it doesnt skip a rank
-- task: rank the order based on thier sales from highest to lowest
SELECT
orderid,
productid,
sales,
ROW_NUMBER() OVER(ORDER BY sales DESC) AS sales_rank_row
FROM orders;

-- RANK()
-- Assign a rank to each row
-- it handle th eties i.e if 2 rows has same value the rank will be same i.e shared rank
-- it leaves gap in ranking i.e it skips the rank by after assigning samee rank to rows having same value
-- olympic example if 2 people ties for gold there will be no silver only bronze
SELECT
orderid,
productid,
sales,
RANK() OVER(ORDER BY sales DESC) AS sales_rank_rank
FROM orders;

-- DENSE_RANK()
-- Assign a rank to each row
-- it handle th eties i.e if 2 rows has same value the rank will be same i.e shared rank
-- it doesnt leaves gap in ranking 
SELECT
orderid,
productid,
sales,
DENSE_RANK() OVER(ORDER BY sales DESC) AS sales_rank_dense
FROM orders;

-- task:finding top N analyses 
SELECT * FROM
(SELECT 
orderid,
orderdate,
productid,
sales,
ROW_NUMBER() OVER(PARTITION BY productid ORDER BY sales DESC) AS row_rank
FROM orders) t
WHERE t.row_rank = 1;

-- task:finding bottom N analyses 
-- bottom 2 customers based on thier total sales
SELECT * FROM
(SELECT 
customerid,
SUM(sales),
ROW_NUMBER() OVER( ORDER BY SUM(sales) ) AS row_rank
FROM orders
GROUP BY customerid) t
WHERE t.row_rank <= 2;

-- ROW_NUMBER() USECASE
-- assigning unique id to each row 
-- it help us in paginating - process of breaking down big data into smaller , more manageble chunks 
SELECT 
orderid,
orderdate,
ROW_NUMBER() OVER(ORDER BY orderid,orderdate) AS row_rank 
FROM orders_archive;

-- ROW_NUMBER() USECASE - finding duplicates
-- task: identifying duplicate rows in table 'Orders Archive'
-- and return clean result without any duplicates
SELECT * FROM
(SELECT 
*,
ROW_NUMBER() OVER(PARTITION BY orderid ORDER BY creationtime) AS rn
FROM orders_archive) t
WHERE t.rn=1;

-- to see the duplicates
SELECT * FROM
(SELECT 
*,
ROW_NUMBER() OVER(PARTITION BY orderid ORDER BY creationtime) AS rn
FROM orders_archive) t
WHERE t.rn>1;

-- NTILE()
-- it divides the rows into specified number of approximately equal groups 
-- called as buckets
-- bucket_size = number_of_rows/number_of_buckets
-- if the bucket_size is decimal the first group will be larger by sql rule

-- lets create the buckets first in order to understand how sql creates a buckets 
-- here we hae 10 rows
SELECT  
orderid,
sales,
NTILE(1) OVER(ORDER BY sales DESC) AS OneBucket,
NTILE(2) OVER(ORDER BY sales DESC) AS TwoBucket,
NTILE(3) OVER(ORDER BY sales DESC) AS ThreeBucket,
NTILE(4) OVER(ORDER BY sales DESC) AS FourBucket
FROM orders;

-- NTILE() USECASES
-- 1.Data Segmentation as data analyst
-- diving dataset into dintinct subsets based on certain criteria
SELECT *,
CASE
    WHEN bucket = 1 THEN 'High'
    WHEN bucket = 2 THEN 'Medium'
    WHEN bucket = 3 THEN 'Low'
END AS salessegmentation     
FROM    
(SELECT 
orderid,
sales,
NTILE(3) OVER(ORDER BY sales DESC) AS  bucket
FROM orders)t;

-- 2. ETL process or equalizing load processing as data engineer
-- lets say if we loading full tabe from one database to another database 
-- we might stress the network and face the information loss
-- to avoid this we will break the table into smaller subsets and load them one by one 
-- and at destination we will perform union oprn to get the whole table back

-- task:divide the table into 2 buckets in order too export them
SELECT 
orderid,
sales,
NTILE(2) OVER(ORDER BY orderid) AS  bucket
FROM orders;

-- percentage based ranking 
-- we are going to calculate relative posn of each row and will assign 
-- a percentage value to each row based on its relative posn 
-- we r going to have continous normalized scale 
-- can be used for distribution analysis 
-- where can find contribution of a specific row to overall data 
-- two functions - cume_dist/percent_rank

-- 1. CUME_DIST() - going to calculate dist of data points within a window
-- formula:posn_no/no_of_rows if there is a. tie sql gonna take last posn 
-- current_row is inclusive

-- 2.PERCENT_RANK() - calculates relative position of each row 
--  formula:posn_no-1/no_of_rows-1 if there is a. tie sql gonna take last posn 
-- current_row is exclusive

-- task:find the product falls under 40% of the price 
SELECT *,
CONCAT(t.DistRank*100,'%')
FROM
(SELECT 
productid,
price,
CUME_DIST() OVER(ORDER BY price DESC) AS DistRank
FROM products)t
WHERE t.DistRank <=0.4 ;

-- using PERCENT_RANK()
SELECT *,
CONCAT(t.DistRank*100,'%')
FROM
(SELECT 
productid,
price,
PERCENT_RANK() OVER(ORDER BY price DESC) AS DistRank
FROM products)t
WHERE t.DistRank <=0.4 ;

-- SUMMARY:
-- RANK WINDOW FUNCTIONS 
-- assign a rank for each row within a window 
-- two types - integer-based(row_number/rank/dense_rank/ntile)
-- percentage-based(cume_dist/percent_rank)
-- RULES:expression should be empty/order by clause is must/frame is not allowed
-- USECASES:
-- top/bottom/N analysis 
-- assigning unique ids helpful for pagination 
-- finding duplicates 
-- data segmentation (ntile)
-- equalizing load process (ntile)
-- data distribution ananalysis (cume_dist/percent_rank)

-- NEW TOPIC:
-- VALUE WINDOW FUNCTION(lead/lag/first_value/last_value)
-- in order to acces a value from another row
-- from present row we can access values from other rows such as previous/next/first/last
-- expression - any dataype for all value window function
-- partition by - optonal
-- order by -- required
-- frame -not allowed for lead/lag , optional for first_value, must for last_value


-- LEAD(expression,offset,default) - access the value from next row
-- expression - can be of any data type e.g a column sales
-- offset(optional) - how many rows we would like to jump default is 1
-- default(optional) - lets say if sql doesnt find anything instead of returnimg null it will return default row we mentioned 
-- LAG() - access the value from previous row

-- USECASE - Comparison analysis over time 
-- Time series analysis - process of analysing data to undersatnd its behaviour over time
-- most common MoM(month on month) & YoY(Year over year)

-- task: mom performance by finding percentage change in sales between previous and current month
SELECT 
MONTH(orderdate),
SUM(sales),
LAG(SUM(sales)) OVER(ORDER BY MONTH(orderdate)),
((SUM(sales) - LAG(SUM(sales)) OVER(ORDER BY MONTH(orderdate)))/SUM(sales)) *100
FROM orders
GROUP BY MONTH(orderdate) ;

-- customer retention analysis 
-- measure customer behaviour and loyalty to help business to build
-- strong relnship with customers

-- task:rank customers based on thier avg days between their orders
SELECT 
t.customerid,
AVG(no_of_days),
RANK() OVER(ORDER BY AVG(no_of_days) IS NULL,AVG(no_of_days)) as rank_customer
FROM
(SELECT 
orderid,
customerid,
orderdate,
LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate) AS previous_date,
DATEDIFF(LEAD(orderdate) OVER(PARTITION BY customerid ORDER BY orderdate),orderdate) AS no_of_days
FROM orders
ORDER BY customerid,orderdate) t
GROUP BY t.customerid;

-- FIRST_VAUE()/LAST_VALUE()
-- usecase : inorder to do comparison analysis
-- task:find the lowest and highest sales for each product 
-- find the diff in sales between current and lowest
SELECT 
orderid,
productid,
sales,
FIRST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales) as value_first,
LAST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS value_last,
FIRST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales DESC) as value_first_desc,
sales - FIRST_VALUE(sales) OVER(PARTITION BY productid ORDER BY sales) as sales_diff
FROM orders

-- SUMMARY
-- VALUE (ANALYTICAL) WINDOW Function
-- allow access specific value from another row
-- TYPES: previous_value(LAG)/next_value(LEAD)/first_value/last_value()
-- RULES: Expression(any data type)/ORDER BY(required)/Frame(optional) 
-- USECASES: 
-- 1. Time series analysis :mom and yoy(using lag)
-- 2. Time gaps analysis : customer retention (using lead)
-- comparison analysis: Extreme(highest/lowest)