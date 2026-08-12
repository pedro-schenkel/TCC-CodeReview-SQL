USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    o_year,
    SUM(CASE
            WHEN nation = 'BRAZIL'
            THEN volume
            ELSE 0
        END) / SUM(volume) AS mkt_share
FROM
(
    SELECT
        DATEPART(YEAR, o.o_orderdate) AS o_year,
        l.l_extendedprice * (1 - l.l_discount) AS volume,
        n2.n_name AS nation
    FROM part p
    INNER JOIN lineitem l
        ON p.p_partkey = l.l_partkey
    INNER JOIN supplier s
        ON s.s_suppkey = l.l_suppkey
    INNER JOIN orders o
        ON o.o_orderkey = l.l_orderkey
    INNER JOIN customer c
        ON c.c_custkey = o.o_custkey
    INNER JOIN nation n1
        ON c.c_nationkey = n1.n_nationkey
    INNER JOIN region r
        ON n1.n_regionkey = r.r_regionkey
    INNER JOIN nation n2
        ON s.s_nationkey = n2.n_nationkey
    WHERE
        r.r_name = 'AMERICA'
        AND o.o_orderdate BETWEEN '1995-01-01' AND '1996-12-31'
        AND p.p_type = 'ECONOMY ANODIZED STEEL'
) AS all_nations
GROUP BY
    o_year
ORDER BY
    o_year
OPTION (MAXDOP 2);