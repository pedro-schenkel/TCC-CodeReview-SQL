DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT TOP (10)
    o.o_orderkey,
    (
        SELECT SUM(l2.l_extendedprice * (1 - l2.l_discount))
        FROM lineitem l2
        WHERE l2.l_orderkey = o.o_orderkey
          AND l2.l_shipdate > '1995-03-15'
    ) AS revenue,
    o.o_orderdate,
    o.o_shippriority
FROM customer c
INNER JOIN orders o
    ON c.c_custkey = o.o_custkey
WHERE c.c_mktsegment = 'BUILDING'
  AND o.o_orderdate < '1995-03-15'
  AND EXISTS
  (
        SELECT 1
        FROM lineitem l3
        WHERE l3.l_orderkey = o.o_orderkey
          AND l3.l_shipdate > '1995-03-15'
  )

ORDER BY
    revenue DESC,
    o.o_orderdate
OPTION (MAXDOP 2);

-- Adicionado subconsulta no campos do select e no where.