--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 03
-- Exercise 03
--------------------------------------------------------------------------------
-- In this exercise, we will explore the effect of the preserve_insertion_order
-- setting in DuckDB when exporting data to CSV files under constrained memory
-- conditions.
INSTALL tpch;
LOAD tpch;

ATTACH 'tpch.db';
USE tpch;

call dbgen(sf = 1);

SET threads = 2;
SET max_temp_directory_size = '0MB';
SET memory_limit = '128MB';
-- OK
SET preserve_insertion_order = false;
COPY (FROM lineitem) TO '/tmp/lineitem.csv';
-- OOM
SET preserve_insertion_order = true;
COPY (FROM lineitem) TO '/tmp/lineitem.csv';

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Try to explain the observed behavior when setting preserve_insertion_order to
-- true vs. false in the above export queries. What could the difference in terms of
-- memory usage and execution strategy be?
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- How would you modify the above export queries to successfully export the
-- lineitem table to a CSV file while preserving the insertion order, given the
-- memory constraints?
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
