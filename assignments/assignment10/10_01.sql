--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 10
-- Exercise 01
--------------------------------------------------------------------------------
-- In the lecture, we have discussed two ways to represent nested/complex values:
-- "Struct of Lists" vs. "List of Structs". In this exercise, you will
-- generate datasets for both representations, measure the performance of
-- extraction queries, and reason about memory access paths and cache efficiency.
--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Before measuring performance, we use DuckDB's `test_vector_types` to
-- understand the logical output format of these complex types.
--
-- Start the DuckDB CLI and run the following commands:
--
-- (i) Struct of Lists
SELECT DISTINCT t.x
FROM test_vector_types(null :: struct(a int[], b text[])) AS t(x);

-- (ii) List of Structs
SELECT DISTINCT t.y
FROM test_vector_types(null :: struct(a int, b text)[]) AS t(y);

-- We have already discussed columnar vs. row-based layouts in the lecture.
-- This is a similar concept but applied to nested types.
-- Please hypothesize about the physical memory layout required to access
-- the first integer of field `a` in both cases. Provide your answer as
-- about one paragraph (4-5 sentences) in plain text.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Next, we want to experimentally estimate if there is a performance difference
-- when extracting the first integer of field `a` for all rows in both layouts.
-- To get stable timings, we need a larger dataset. Create two tables with
-- 10 million rows each:
--
-- 1. Create `sol_table` (Struct of Lists):
CREATE TABLE sol_table AS
SELECT {'a': [i, i+1, i+2, i+3],
        'b': ['v1', 'v2', 'v3', 'v4']} AS x
FROM generate_series(1, 10000000) AS _(i);

-- 2. Create `los_table` (List of Structs):
CREATE TABLE los_table AS
SELECT [{'a': i,   'b': 'v1'},
        {'a': i+1, 'b': 'v2'},
        {'a': i+2, 'b': 'v3'},
        {'a': i+3, 'b': 'v4'}] AS y
FROM generate_series(1, 10000000) AS _(i);
--
-- Now, we will run extraction queries on both tables to measure performance.
-- Use the DuckDB CLI with `.timer on` and `SET threads = 1` to ensure
-- single-threaded execution for consistent timing.
--
-- 3. Run the following two queries 5 times each and record the wall-clock times:
--
--    (i) Query for Struct of Lists (Access field 'a', then index 1)
      SELECT SUM(x.a[1]) FROM sol_table;
--
--    (ii) Query for List of Structs (Access index 1 of list, then field 'a')
      SELECT SUM(y[1].a) FROM los_table;
-- 4. Report the average time for each query after 5 runs.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- 1. Draw an ASCII representation of the physical and logical representation
--    of both layouts.
--    These ASCII characters may be helpful: ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼ ─ │
--
-- 2. Provide an access path describing how to reach the first integer
--    of `a` for one row in both layouts.
--    Example: "Access struct vector -> access child vector 'a' -> index 1"
--
-- 3. Explain why the "Struct of Lists" layout is generally more cache-efficient
--    when we only want to sum field `a`.
--    (Hint: Think about which data is loaded into the CPU cache and whether
--    the string data in field `b` is ever touched or skipped.)
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- As teased on slide 07, DiDi-07.pdf, we can apply the representation schemes
-- recursively to create even more complex types.
-- The following query generates an "Array of Arrays of Integers".

SELECT DISTINCT t.y
FROM test_vector_types(null :: INT[][]) AS t(y);

-- ┌─────────────────────────────────┐
-- │                y                │
-- │            int32[][]            │
-- ├─────────────────────────────────┤
-- │ []                              │
-- │ [[3, 5], []]                    │
-- │ [[NULL]]                        │
-- │ [[7]]                           │
-- │ [[-2147483648, 2147483647], []] │
-- └─────────────────────────────────┘
--
-- Please, analogously to Task (c), provide an ASCII representation of the
-- physical representation of this type.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
