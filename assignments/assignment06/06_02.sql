--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 06
-- Exercise 02
--------------------------------------------------------------------------------
-- Presence of duplicates in a non-unique index has an impact on index
-- scan performance.  Since index leaves store row IDs that point into
-- column chunks, collecting the rows for a key leads to "jumping"
-- in the data file.
--
-- Based on experiments described in YouTube video https://www.youtube.com/watch?v=RywT9_K4QWg
-- "Indexes are (not) all you need: Common DuckDB pitfalls and how to find them"


-- 1. Create table t of 100 million rows
--
CREATE OR REPLACE TABLE t AS
  SELECT (i * 9_876_983_769_044 :: hugeint % 100_000_000) :: bigint AS i
  FROM   range(100_000_000) AS _(i);

-- Few duplicates: each i occurs four times
SELECT avg(occurs)
FROM   (SELECT count(i)
        FROM   t
        GROUP BY i) AS _(occurs);

-- Create non-unique index on t(i)
CREATE INDEX t_i_idx ON t(i);


-- Measure table scan performance (ignore index)

-- Disable index usage (threshold will be 0)
SET index_scan_max_count  = 0;
SET index_scan_percentage = 0.0;

.timer on

-- Q1
SELECT count(i)
FROM   t
WHERE  i = 1904;
-- Run Time (s): real 0.011 user 0.064499 sys 0.005875

-- Now use index t_i_idx on table to perform the key lookup

RESET index_scan_max_count;
RESET index_scan_percentage;

-- Q2
-- Index usage speeds up query evaluation.  Good.
--
SELECT count(i)
FROM   t
WHERE  i = 1904;
-- Run Time (s): real 0.001 user 0.001301 sys 0.000614

.timer off

-- 2. Recreate table t, many duplicates: now each i occurs 40,000 times
--
CREATE OR REPLACE TABLE t AS
  SELECT (i * 9_876_983_769_044 :: hugeint % 10_000) :: bigint AS i
  FROM   range(100_000_000) AS _(i);

SELECT avg(occurs)
FROM   (SELECT count(i)
        FROM   t
        GROUP BY i) AS _(occurs);

-- Create non-unique index on t(i)
CREATE INDEX t_i_idx ON t(i);

-- Measure table scan performance (ignore index)

-- Disable index usage (threshold will be 0)
SET index_scan_max_count  = 0;
SET index_scan_percentage = 0.0;

.timer on

-- Q3
SELECT count(i)
FROM   t
WHERE  i = 1904;
-- Run Time (s): real 0.011 user 0.102831 sys 0.001775
--                    ^^^^^

RESET index_scan_max_count;
RESET index_scan_percentage;

-- Q4
-- Use index t_i_idx on table to perform the key lookup: once
-- we reach the index leaf, dereference about 40,000 row IDs
-- into the column chunks for table t.  In effect, index usage
-- SLOWS DOWN the query. :-/
EXPLAIN ANALYZE
SELECT count(i)
FROM   t
WHERE  i = 1904;
-- Run Time (s): real 0.028 user 0.068331 sys 0.139631
--                    ^^^^^
--
-- ┌─────────────┴─────────────┐
-- │         TABLE_SCAN        │
-- │    ────────────────────   │
-- │          Table: t         │
-- │      Type: Index Scan     │
-- │       Projections: i      │
-- │      Filters: i=1904      │
-- │                           │
-- │        40,000 rows        │
-- │          (0.25s)          │
-- └───────────────────────────┘
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Indexes in database systems are typically designed to speed up
-- certain types of queries. However, the experiments above show that
-- using a non-unique index can actually slow down query performance
-- when there are many duplicates for the indexed key.
--
-- Please run the above experiments in DuckDB on your own system
-- and report the observed runtimes of queries Q1 vs Q3, and Q2 vs Q4
-- to compare the scenarios featuring few vs many duplicate index keys.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Can you think of a reason why the presence of many duplicates
-- in a non-unique index negatively impacts index scan performance?
-- Please explain in your own words. (One paragraph, approx. 5-15 sentences
-- suffices.)
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Please write a query that computes for table t,
-- 1. the number of distinct keys in column i: name the column num_distinct,
-- 2. the total number of rows in table t: name the column total_rows,
-- 3. the ratio of total_rows to num_distinct: name the column ratio.
-- The result should be a single row with three columns.
-- Hint: use COUNT(DISTINCT ...).
--
-- Please provide the query and the result obtained when running it
-- on the table t with many duplicates (created above), and with few
-- duplicates.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- Based on your findings in Task (c), how should the database system
-- decide whether to use a non-unique index for query processing
-- or not? You may assume that the database system has statistics
-- about the number of distinct keys and the total number of rows
-- in the indexed column. (One paragraph, approx. 5-10 sentences suffices.)
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
