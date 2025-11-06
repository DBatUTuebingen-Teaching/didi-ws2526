--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 03
-- Exercise 02
--------------------------------------------------------------------------------
-- In this exercise, we will investigate the memory usage and streaming capabilities
-- of DuckDB by running various queries on the TPC-H lineitem table with artificially
-- constrained memory settings.
-- We will observe which queries can be executed within the memory limits
-- and which ones lead to out-of-memory (OOM) errors.
--
-- Setup the TPC-H database and configure memory settings.
INSTALL tpch;
LOAD tpch;

ATTACH 'tpch.db';
USE tpch;

call dbgen(sf = 1);

SET memory_limit = '2MB';
SET max_temp_directory_size = '0MB';

-- Restrict parallel processing to reduce memory usage
SET threads = 1;

-- Q1:
SELECT l_shipdate, sum(l_extendedprice * l_discount) OVER (ORDER BY l_shipdate) AS revenue
FROM   lineitem
WHERE  l_orderkey < 10000;
-- Q2:
SELECT l_shipdate, sum(l_extendedprice * l_discount) OVER (PARTITION BY l_shipdate) AS revenue
FROM   lineitem
WHERE  l_orderkey < 10000;
-- Q3:
SELECT l_shipdate, sum(l_extendedprice * l_discount) OVER (PARTITION BY l_shipdate >= DATE '1994-01-01') AS revenue
FROM   lineitem
WHERE  l_orderkey < 10000;

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Similar to file 011-spilling.sql from the lecture material, run various queries
-- on the TPC-H lineitem table with the above memory settings. Identify which
-- queries can be executed successfully and which ones lead to OOM errors.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Explain the observed behavior in terms of memory usage and streaming
-- capabilities of DuckDB.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
