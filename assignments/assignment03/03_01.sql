--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 03
-- Exercise 01
--------------------------------------------------------------------------------
-- In this exercise, we will investigate the effect of "German Strings"—as coined
-- by Andy Pavlo (CMU).
--
-- First, we create a table with 20 million rows containing different variants
-- of the same base string (the MD5 hash of the row number).
--
-- Note the difference between columns s1, s2, s3, and s4 in terms of
-- length, prefixes, and randomness.

RESET memory_limit;
RESET threads;
CREATE OR REPLACE TEMPORARY TABLE t (i int, s1 text, s2 text, s3 text, s4 text);
INSERT INTO t(i, s1, s2, s3, s4)
  SELECT i,
         md5(i :: text) AS s1,
         left(s1, 4)    AS s2,
         'duck' || s1   AS s3,
         s1 || 'duck'   AS s4
  FROM   range(20_000_000) AS _(i);

-- Next, we run ORDER BY queries on each of the string columns
-- and measure the execution time.
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Please fill in the run times you observe below.
--------------------------------------------------------------------------------
-- Solution:

.timer on
.mode trash
SET threads = 1;
.print "s1"
-- Time: <your time goes here>
SELECT i
FROM   t
ORDER BY s1;
-- Time: <your time goes here>
.print "s2"
SELECT i
FROM   t
ORDER BY s2;
-- Time: <your time goes here>
.print "s3"
SELECT i
FROM   t
ORDER BY s3;
-- Time: <your time goes here>
.print "s4"
SELECT i
FROM   t
ORDER BY s4;

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Explain the differences in observed run times based on the characteristics
-- of the string columns s1, s2, s3, and s4.
--
-- Note: We expect `ORDER BY s1` and `ORDER BY s4` to have similar performance.
-- `ORDER BY s2` is expected to be the fastest, while `ORDER BY s3` is
-- expected to be the slowest.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- How would you design a string column to achieve optimal performance for
-- ORDER BY queries? Justify your answer.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
