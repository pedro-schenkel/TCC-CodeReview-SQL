USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    n.n_name,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM customer c
INNER JOIN orders o
    ON c.c_custkey = o.o_custkey
INNER JOIN lineitem l
    ON l.l_orderkey = o.o_orderkey
INNER JOIN supplier s
    ON l.l_suppkey = s.s_suppkey
INNER JOIN nation n
    ON s.s_nationkey = n.n_nationkey
INNER JOIN region r
    ON n.n_regionkey = r.r_regionkey
WHERE c.c_nationkey = s.s_nationkey
  AND r.r_name = 'ASIA'
  AND o.o_orderdate >= '1994-01-01'
  AND o.o_orderdate < DATEADD(YEAR, 1, CAST('1994-01-01' AS DATETIME))
GROUP BY
    n.n_name
ORDER BY
    revenue DESC
OPTION (MAXDOP 2);