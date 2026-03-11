# sql-practice
- SQL queries and exercises focused on data analysis, including joins, aggregations, and real-world business questions using sample datasets.
- This repository contains SQL queries and exercises that I am practicing while learning data analysis.

## Databases Used
- customers sample Database
- orders sample Database

## Topics Covered
- SELECT statements
- Filtering (WHERE)
- Joins
- GROUP BY and Aggregations
- Subqueries
- Window Functions

## Example Query

SELECT customer_id, COUNT(*) AS total_rentals
FROM rental
GROUP BY customer_id
ORDER BY total_rentals DESC;

## Goal

The goal of this repository is to strengthen SQL skills for data analysis and data science roles.
