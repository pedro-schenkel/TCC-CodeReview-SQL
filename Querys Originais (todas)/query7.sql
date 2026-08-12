USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    supp_nation,
    cust_nation,
    l_year,
    SUM(volume) AS revenue
FROM
(
    SELECT
        n1.n_name AS supp_nation,
        n2.n_name AS cust_nation,
        DATEPART(YEAR, l.l_shipdate) AS l_year,
        l.l_extendedprice * (1 - l.l_discount) AS volume
    FROM supplier s
    INNER JOIN lineitem l
        ON s.s_suppkey = l.l_suppkey
    INNER JOIN orders o
        ON o.o_orderkey = l.l_orderkey
    INNER JOIN customer c
        ON c.c_custkey = o.o_custkey
    INNER JOIN nation n1
        ON s.s_nationkey = n1.n_nationkey
    INNER JOIN nation n2
        ON c.c_nationkey = n2.n_nationkey
    WHERE
        (
            (n1.n_name = 'FRANCE' AND n2.n_name = 'GERMANY')
            OR
            (n1.n_name = 'GERMANY' AND n2.n_name = 'FRANCE')
        )
        AND l.l_shipdate BETWEEN '1995-01-01' AND '1996-12-31'
) AS shipping
GROUP BY
    supp_nation,
    cust_nation,
    l_year
ORDER BY
    supp_nation,
    cust_nation,
    l_year
OPTION (MAXDOP 2);