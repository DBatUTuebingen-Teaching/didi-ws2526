--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 06
-- Exercise 01
--------------------------------------------------------------------------------
-- Zonemaps in DuckDB are not be updated eagerly when a table column is
-- updated. Instead, new zonemap entries are created for the affected
-- row groups, and the scan operator switches between existing and new
-- zonemap entries as needed.
-- This script demonstrates this behavior.
--------------------------------------------------------------------------------

CREATE OR REPLACE TABLE t (
  c1 bigint,
  c2 bigint
);

INSERT INTO t(c1,c2)
  SELECT i & ~3 AS c1, (i * 9_876_983_769_044 :: hugeint % 100_000_000) :: bigint AS c2
  FROM   range(100_000_000) AS _(i);

-- Zonemap for column col
--
CREATE OR REPLACE MACRO zonemap(col) AS TABLE
  SELECT t.row_group_id                                          AS "row group",
         min(t.start)                                            AS "first rowid",
         sum(t.count)                                            AS "# rows",
         min(regexp_extract(t.stats, 'Min: (\d+)', 1) :: bigint) AS "min",
         max(regexp_extract(t.stats, 'Max: (\d+)', 1) :: bigint) AS "Max",
         "Max" - "min"                                           AS span
  FROM   pragma_storage_info('t') AS t
  WHERE  t.column_name = col AND t.segment_type = 'BIGINT'
  GROUP  BY t.row_group_id
  ORDER  BY t.row_group_id;

-- Zonemaps and table updates
--
-- When a table column (say c1: UPDATE t SET c1 = ...) is updated,
-- either...
-- (A) eagerly update the zonemap associated with column c1 as well
--     (costly on update)
-- (B) ignore the existing (now outdated zonemap)
--     (costly on scans: no skipping possible)
-- (C) create new zonemap entries for the affected/updated rowgroups
--     and switch between existing and new zonemap entries as needed
--     (implemented DuckDB, see below)

-- Perform a HEAVY update: negate all entries in column c1
UPDATE t SET c1 = -c1;

SELECT t.*
FROM t
LIMIT 20;

-- The evaluation of the predicate c1 = -500_000 still is "pushed down"
-- into the Sequential Scan over t.  Query runtime suggests that
-- zonemaps are still used, but performance appears to suffer slightly:
SELECT t.c1, t.c2
FROM   t
WHERE  t.c1 = -500_000;
-- Run Time (s): real 0.004 user 0.026735 sys 0.001540
--                    ^^^^^
--                    (before UPDATE: 0.001, see above)


-- In DuckDB's table storage, the row groups for column c1 are marked
-- as being updated (see column "has_updates").  The min/max stats
-- are still unchanged, however:
--
SELECT row_group_id, column_name, segment_id, stats, has_updates, persistent
FROM   pragma_storage_info('t')
WHERE  segment_type = 'BIGINT'
LIMIT 20;

-- During a Sequential Scan over t, the "has_updates" flag is checked:
-- - if false, perform row group skipping based on existing zonemap entry
--   as before,
-- - if true, use the new zonemap entry for the group created when the
--   UPDATE was performed (option (C) above).
--
-- These new zonemap entries are kept in extra update statistics storage.
-- Accessing this extra storage (see TRANSACTION below) to the performance
-- loss we saw above:

FROM duckdb_memory();
-- ┌─────────────────────┬────────────────────┬─────────────────────────┐
-- │         tag         │ memory_usage_bytes │ temporary_storage_bytes │
-- │       varchar       │       int64        │          int64          │
-- ├─────────────────────┼────────────────────┼─────────────────────────┤
-- │ BASE_TABLE          │                  0 │                       0 │
-- │ HASH_TABLE          │                  0 │                       0 │
-- │ PARQUET_READER      │                  0 │                       0 │
-- │ CSV_READER          │                  0 │                       0 │
-- │ ORDER_BY            │                  0 │                       0 │
-- │ ART_INDEX           │                  0 │                       0 │
-- │ COLUMN_DATA         │                  0 │                       0 │
-- │ METADATA            │                  0 │                       0 │
-- │ OVERFLOW_STRINGS    │                  0 │                       0 │
-- │ IN_MEMORY_TABLE     │         2133889024 │                       0 │
-- │ ALLOCATOR           │                  0 │                       0 │
-- │ EXTENSION           │                  0 │                       0 │
-- │ TRANSACTION         │         1280049152 │                       0 │ <-- update statistics are stored along with
-- │ EXTERNAL_FILE_CACHE │                  0 │                       0 │     a log of database changes
-- ├─────────────────────┴────────────────────┴─────────────────────────┤
-- │ 14 rows                                                  3 columns │
-- └────────────────────────────────────────────────────────────────────┘


-- DuckDB can merge the updates into the base table, making the extra
-- update statistic obsolete.  At that point, the table's zonemaps are
-- updated.

ATTACH 'scratch.db' AS scratch;
COPY FROM DATABASE memory TO scratch;

USE scratch;

-- In the persistent scratch database, the updates have been merged into
-- table t.  The zonemap of c1 has been updated:
SELECT row_group_id, column_name, segment_id, stats, has_updates, persistent
FROM   pragma_storage_info('t')
WHERE  segment_type = 'BIGINT'
LIMIT 20;


-- The query now is as fast as before:
SELECT t.c1, t.c2
FROM   t
WHERE  t.c1 = -500_000;
-- Run Time (s): real 0.001 user 0.001299 sys 0.002816
--                    ^^^^^

DETACH memory;

FROM duckdb_memory();
-- ┌─────────────────────┬────────────────────┬─────────────────────────┐
-- │         tag         │ memory_usage_bytes │ temporary_storage_bytes │
-- │       varchar       │       int64        │          int64          │
-- ├─────────────────────┼────────────────────┼─────────────────────────┤
-- │ BASE_TABLE          │          427294720 │                       0 │
-- │ HASH_TABLE          │                  0 │                       0 │
-- │ PARQUET_READER      │                  0 │                       0 │
-- │ CSV_READER          │                  0 │                       0 │
-- │ ORDER_BY            │                  0 │                       0 │
-- │ ART_INDEX           │                  0 │                       0 │
-- │ COLUMN_DATA         │                  0 │                       0 │
-- │ METADATA            │                  0 │                       0 │
-- │ OVERFLOW_STRINGS    │                  0 │                       0 │
-- │ IN_MEMORY_TABLE     │                  0 │                       0 │
-- │ ALLOCATOR           │                  0 │                       0 │
-- │ EXTENSION           │                  0 │                       0 │
-- │ TRANSACTION         │                  0 │                       0 │ <-- update statistics removed
-- │ EXTERNAL_FILE_CACHE │                  0 │                       0 │
-- ├─────────────────────┴────────────────────┴─────────────────────────┤
-- │ 14 rows                                                  3 columns │
-- └────────────────────────────────────────────────────────────────────┘

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Please explain in your own words what Zonemaps are, how they are used
-- to speed up query processing, and how DuckDB handles zonemaps when
-- a table column is updated. (One paragraph, approx. 5-15 sentences suffices.)
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Run the above script step by step and observe the behavior of zonemaps
-- in DuckDB when a table column is updated heavily.
-- Please explain in your own words how DuckDB handles zonemaps when a table
-- column is updated. (One paragraph, approx. 5-15 sentences suffices.)
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------
-- Can you think of a reason why heavy updates to a table column
-- (as in the above script) negatively impact query performance
-- even when DuckDB creates new zonemap entries for the affected
-- row groups instead of eagerly updating the existing zonemaps?
--
-- Hint: Consider where the new zonemap entries are stored
--       and how they are accessed during query processing.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (d)
--------------------------------------------------------------------------------
-- Do you think that this behavior is problematic, given that DuckDB
-- is designed as an OLAP database system? Why or why not?
--
-- Would this behavior be acceptable in an OLTP database system?
--
-- One paragraph, approx. 5-10 sentences suffices.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
