--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 09
-- Exercise 01
--------------------------------------------------------------------------------
-- In the lecture, we have learned about DuckDB's execution model, pipelines, and
-- parallelism.

-- Generate a TPC-H dataset with scale factor 1
CALL dbgen(sf=1);

-- Export the orders table to a JSON file, using array_agg to create a single JSON object
-- containing all orders. (Please never do this on large tables in practice, as
-- this is only for demonstration purposes.)
COPY (SELECT array_agg(to_json(o)) AS orders
      FROM   orders AS o)
TO 'orders_data.json' (FORMAT json);

-- Now, read the JSON file back into DuckDB, using a large maximum_object_size
-- to avoid errors when parsing the large JSON array.
.timer on
SET threads = 1;
-- SET threads = 2;

-- Q1:
SELECT * FROM read_json('orders_data.json', maximum_object_size = 335544280) AS t;

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Execute query Q1 first with SET threads = 1; and then with SET threads = 2;.
-- Observe the execution times and explain the differences.
-- Does the query benefit from parallelism? Why (not)?
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- How would you modify the JSON file or the query to better benefit from
-- parallelism? Please hand in your modified `COPY ...` statement, and if
-- necessary, your modified query Q1 as well.
-- Briefly explain your modifications (2-5 sentences).
--
-- Hint: You may consider storing the data as multiple JSON objects instead of a
-- single large JSON array.
-- https://duckdb.org/docs/stable/data/json/loading_json
-- Consider using the `read_json_objects` or `read_ndjson_objects` functions.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (c) — This task does not give you any points, unfortunately.
--------------------------------------------------------------------------------
-- Consider NOT working on tasks (a) and (b) before Christmas.
-- Have a merry Christmas and a happy new year, everyone!
--------------------------------------------------------------------------------
-- Solution:
-- 🎄
--------------------------------------------------------------------------------
