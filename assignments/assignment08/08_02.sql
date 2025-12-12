--------------------------------------------------------------------------------
-- Design and Implementation of Database Systems Internals
-- Assignment 08
-- Exercise 02
--------------------------------------------------------------------------------
-- The execution engine of a database system is the most intricate and important
-- component of an analytical database system. As we have seen in the lectures,
-- DuckDB's execution engine is pipeline-based and vectorized.
--
-- In the lecture, we have learned about pipeline breakers, and pipeline
-- dependencies. Your task in this exercise is to identify the pipeline breakers
-- and dependencies for a few queries.
-- Enable and configure DuckDB's profiling facility to dump a
-- compact variant of the query plan
PRAGMA enable_profiling = 'query_tree';
PRAGMA custom_profiling_settings = '{ "OPERATOR_TYPE": "true", "EXTRA_INFO": "true", "OPERATOR_CARDINALITY": "true" }';
PRAGMA explain_output = 'physical_only';
INSTALL tpch;
LOAD tpch;
CALL dbgen(sf=1);

-- Now, execute the following queries one by one, and for each query annotate
-- the query plan that is dumped by DuckDB's profiling facility with the pipeline
-- breakers and dependencies. Please use the format that we have used in the
-- lecture material `#021-pipelines.sql`, `DiDi-06.pdf` slides 08-10.

--------------------------------------------------------------------------------
-- Task (a)
--------------------------------------------------------------------------------

-- TPC-H Query 1
select
        l_returnflag,
        l_linestatus,
        sum(l_quantity) as sum_qty,
        sum(l_extendedprice) as sum_base_price,
        sum(l_extendedprice * (1 - l_discount)) as sum_disc_price,
        sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge,
        avg(l_quantity) as avg_qty,
        avg(l_extendedprice) as avg_price,
        avg(l_discount) as avg_disc,
        count(*) as count_order
from
        lineitem
where
        l_shipdate <= date '1998-12-01' - interval '90' day
group by
        l_returnflag,
        l_linestatus
order by
        l_returnflag,
        l_linestatus;

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------

-- TPC-H Query 5
select
        n_name,
        sum(l_extendedprice * (1 - l_discount)) as revenue
from
        customer,
        orders,
        lineitem,
        supplier,
        nation,
        region
where
        c_custkey = o_custkey
        and l_orderkey = o_orderkey
        and l_suppkey = s_suppkey
        and c_nationkey = s_nationkey
        and s_nationkey = n_nationkey
        and n_regionkey = r_regionkey
        and r_name = 'ASIA'
        and o_orderdate >= date '1994-01-01'
        and o_orderdate < date '1994-01-01' + interval '1' year
group by
        n_name
order by
        revenue desc;

--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
-- Task (c)
--------------------------------------------------------------------------------

-- TPC-H Query 10
select
        c_custkey,
        c_name,
        sum(l_extendedprice * (1 - l_discount)) as revenue,
        c_acctbal,
        n_name,
        c_address,
        c_phone,
        c_comment
from
        customer,
        orders,
        lineitem,
        nation
where
        c_custkey = o_custkey
        and l_orderkey = o_orderkey
        and o_orderdate >= date '1993-10-01'
        and o_orderdate < date '1993-10-01' + interval '3' month
        and l_returnflag = 'R'
        and c_nationkey = n_nationkey
group by
        c_custkey,
        c_name,
        c_acctbal,
        c_phone,
        n_name,
        c_address,
        c_comment
order by
        revenue desc
limit
        20;

--------------------------------------------------------------------------------
-- Task (b)
--------------------------------------------------------------------------------
-- Please explain in 5-10 sentences what pipeline breakers and dependencies are,
-- and why they are important for the performance of analytical database systems.
--------------------------------------------------------------------------------
-- Solution:

--------------------------------------------------------------------------------
