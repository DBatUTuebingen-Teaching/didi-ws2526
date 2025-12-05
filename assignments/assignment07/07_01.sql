--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 07
-- Exercise 01
--------------------------------------------------------------------------------
-- DuckDB's index support is relatively basic and has not (yet) seen extensive
-- efforts towards optimization and use in query plans. In this exercise, we
-- will try to trick DuckDB into using an index for a query that would
-- otherwise require a full table scan.
--
-- We will use the TPC-H lineitem table for this exercise. First, we create
-- an index on the l_orderkey column.

CALL dbgen(sf=1);

CREATE INDEX lineitem_orderkey_idx ON lineitem(l_orderkey);

.timer on

-- Q1
EXPLAIN ANALYZE
SELECT l.l_orderkey, l.l_quantity, l.l_comment
FROM   lineitem AS l
       SEMI JOIN (SELECT rowid
                  FROM   lineitem
                  WHERE  l_orderkey < 10
                    UNION ALL
                  SELECT rowid
                  FROM   lineitem
                  WHERE  l_orderkey > 5999990) AS rows USING (rowid)
WHERE l.l_comment LIKE '%careful%';

-- Q2
EXPLAIN ANALYZE
SELECT l.l_orderkey, l.l_quantity, l.l_comment
FROM   lineitem AS l
WHERE  (l.l_orderkey < 10 OR l.l_orderkey > 5999990)
AND    l.l_comment LIKE '%careful%';

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------
-- Q1 and Q2 above are logically equivalent queries. However, Q1 uses the index
-- on l_orderkey, while Q2 does not. You can verify this by looking at the
-- EXPLAIN ANALYZE output of both queries.
--
-- Please explain in your own words why DuckDB is able to use the index
-- in Q1, but not in Q2. Especially, please explain why using the rowid
-- allows the query planner to leverage the index.
-- 5-10 sentences are sufficient.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- In Q2, we have a predicate on l_orderkey to select rows where
-- l_orderkey < 10 OR l_orderkey > 5999990. Based on this idea,
-- please write a query in spirit of Q1 that uses the index on l_orderkey
-- to answer:
-- WHERE l_orderkey > 1000000 AND l_orderkey < 2000000
--
-- Again, use EXPLAIN to make sure that DuckDB indeed uses the `lineitem_orderkey_idx`
-- index to evaluate the predicates on column l_orderkey.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
