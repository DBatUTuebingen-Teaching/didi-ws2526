--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 04
-- Exercise 02
--------------------------------------------------------------------------------
-- Please run the following SQL queries on your DuckDB instance and measure
-- their run times.

INSTALL tpch;
LOAD tpch;

CALL dbgen(sf = 10);

.timer on

-- (1) Full //ism
RESET threads;

SELECT l.l_returnflag, max(l.l_quantity)
FROM   lineitem AS l
GROUP BY l.l_returnflag;
-- Run Time (s): <your measured time>

SELECT l.l_returnflag, median(l.l_quantity)
FROM   lineitem AS l
GROUP BY l.l_returnflag;
-- Run Time (s): <your measured time>

-- (2) No //ism
SET threads = 1;

SELECT l.l_returnflag, max(l.l_quantity)
FROM   lineitem AS l
GROUP BY l.l_returnflag;
-- Run Time (s): <your measured time>

SELECT l.l_returnflag, median(l.l_quantity)
FROM   lineitem AS l
GROUP BY l.l_returnflag;
-- Run Time (s): <your measured time>

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Please compare the run times of the queries with and without parallelism.
-- What do you observe? Please explain your observations.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Please sketch how you would implement parallel aggregation
-- for the MAX aggregation function with parallelism. A plain English
-- description is sufficient.
--
-- Hint: What does each thread need to do? How are the partial results
-- combined to produce the final result?
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Please try to do the same for the MEDIAN aggregation function.
-- How would you implement parallel aggregation for the MEDIAN aggregation
-- function with parallelism? A plain English description is sufficient.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- Please now try to explain why the MEDIAN aggregation function
-- benefits less from parallelism than the MAX aggregation function in
-- DuckDB, based on your sketches from tasks (b) and (c).
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
