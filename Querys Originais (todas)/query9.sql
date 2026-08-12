USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    nation,
    o_year,
    SUM(amount) AS sum_profit
FROM
(
    SELECT
        n.n_name AS nation,
        DATEPART(YEAR, o.o_orderdate) AS o_year,
        l.l_extendedprice * (1 - l.l_discount)
            - ps.ps_supplycost * l.l_quantity AS amount
    FROM part p
    INNER JOIN lineitem l
        ON p.p_partkey = l.l_partkey
    INNER JOIN partsupp ps
        ON ps.ps_partkey = l.l_partkey
       AND ps.ps_suppkey = l.l_suppkey
    INNER JOIN supplier s
        ON s.s_suppkey = l.l_suppkey
    INNER JOIN orders o
        ON o.o_orderkey = l.l_orderkey
    INNER JOIN nation n
        ON s.s_nationkey = n.n_nationkey
    WHERE p.p_name LIKE '%green%'
) AS profit
GROUP BY
    nation,
    o_year
ORDER BY
    nation,
    o_year DESC
OPTION (MAXDOP 2);