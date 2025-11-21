--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 05
-- Exercise 01
--------------------------------------------------------------------------------
-- A fundamental operation in database systems is sorting. In the lecture,
-- we have discussed how DuckDB implements sorting using a parallel
-- algorithm, that can process data that does not fit into main memory.
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- DiDi-04.pdf, Slide 11, phase 2 describes how the Merge Path is used
-- to precompute the boundaries of segments that can be independently merged.
--
-- We provide two sorted runs A and B below.  Each segment shall hold
-- 4 values. Please compute:
--
-- 1. the Merge Matrix,
-- 2. the Merge Path, and
-- 3. the resulting segment boundaries.
--
-- Sorted runs A and B:
-- A = [1, 5, 9, 14, 20, 25, 26, 27]
-- B = [3, 8, 11, 15, 18, 30, 33, 60]
--------------------------------------------------------------------------------
-- Solution:

--    1  5  9 14 20 25 26 27
--  3 1  0  0  0  0  0  0  0
--  8 1  1  0  0  0  0  0  0
-- 11 1  1  1  0  0  0  0  0
-- 15 1  1  1  1  0  0  0  0
-- 18 1  1  1  1  0  0  0  0
-- 30 1  1  1  1  1  1  1  1
-- 33 1  1  1  1  1  1  1  1
-- 60 1  1  1  1  1  1  1  1

-- A: | 1 5 |  9 14 | 20 25 26 | 27       |
-- B: | 3 8 | 11 15 | 18       | 30 33 60 |
--    | #1  | #2    | #3       | #4       |

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- DuckDB does *not* use the Merge Path algorithm from the literature.
-- Instead, it uses a different approach to compute the segment boundaries.
-- The how and why of this approach is described here:
-- https://duckdb.org/2025/09/24/sorting-again
--
-- Please read the blog post and briefly summarize the main idea of DuckDB's
-- approach to compute segment boundaries for parallel sorting.
--
-- Note: We do not expect you to understand every detail of the blog post.
-- And we do not expect more than about a paragraph (maybe 5-15 sentences).
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- The blog post mentioned in Task (b) includes Python function compute_intersections
-- which sketches DuckDB's approach to segment boundary computation.  NB.: The code
-- in the blog post is slightly buggy—we thus provide a fixed version below.

-- You can use the function to check your solution to Task (a).  To do so, simply
-- run (value inf serves as a sentinel that marks the end of a run, the second
-- parameter 4 is the desired segment size):

-- compute_intersection([[1,5,9,14,20,25,26,27,inf], [3,8,11,15,18,30,33,60,inf]], 4)

-- This will return a list [b1,b2] of two integers in which b1 (b2) indicates
-- how many values of the first (second) run are to be placed in the first segment.
-- Remove b1 (b2) values from the start of first (second) run, then invoke function
-- compute_intersections again to find the values in the second segment, and so on.

-- Use function computer_intersections to compute the first five segments of
-- size 6 for the following four runs:

--   A:  [1,4,9,10,12,20]
--   B:  [3,4,6,12,13,15,18,23,26]
--   C:  [0,6,8,10,10,12,19,20,21,21]
--   D:  [1,2,3,4,5,6,7,8,9,10,11,12,13]

-- A fixed version of function compute_intersection (to keep the code simple,
-- the function does not check for edge cases like empty runs—this will
-- not affect us here):
--
-- from math import inf, ceil
--
-- def compute_intersections(sorted_runs, chunk_size):
--     k = len(sorted_runs)
--     intersections = [0] * k
--     while chunk_size > 0:
--         delta = ceil(chunk_size / k)
--         min_idx = 0
--         min_val = sorted_runs[0][intersections[0] + delta - 1]
--         for run_idx in range(1, len(sorted_runs)):
--             val = sorted_runs[run_idx][intersections[run_idx] + delta - 1]
--             if val < min_val:
--                 min_idx = run_idx
--                 min_val = val
--         intersections[min_idx] += delta
--         chunk_size -= delta
--     return intersections
--
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
