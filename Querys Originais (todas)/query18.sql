USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT TOP (100)
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice,
    SUM(l.l_quantity) AS total_quantity
FROM customer c
INNER JOIN orders o
    ON c.c_custkey = o.o_custkey
INNER JOIN lineitem l
    ON o.o_orderkey = l.l_orderkey
WHERE o.o_orderkey IN
(
    SELECT
        l2.l_orderkey
    FROM lineitem l2
    GROUP BY
        l2.l_orderkey
    HAVING
        SUM(l2.l_quantity) > 312
)
GROUP BY
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice
ORDER BY
    o.o_totalprice DESC,
    o.o_orderdate
OPTION (MAXDOP 2);