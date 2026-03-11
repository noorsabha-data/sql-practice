# sql-practice
- SQL queries and exercises focused on data analysis, including joins, aggregations, and real-world business questions using sample datasets.
- This repository contains SQL queries and exercises that I am practicing while learning data analysis.

## Databases Used
- mydatabase sample Database
- salesdb sample Database

## Topics Covered
- SELECT statements
- Filtering (WHERE)
- Joins
- GROUP BY and Aggregations
- Subqueries
- Window Functions

## Example Query

SELECT 
	country , 
	SUM(score) AS total_score,
    COUNT(id) AS total_customers
FROM customers
WHERE score > 400
GROUP BY country
HAVING total_score > 800 ;

## Goal

The goal of this repository is to strengthen SQL skills for data analysis and data science roles.
