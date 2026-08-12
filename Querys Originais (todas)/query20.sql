USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    s.s_name,
    s.s_address
FROM supplier s
INNER JOIN nation n
    ON s.s_nationkey = n.n_nationkey
WHERE s.s_suppkey IN
(
    SELECT
        ps.ps_suppkey
    FROM partsupp ps
    WHERE ps.ps_partkey IN
    (
        SELECT
            p.p_partkey
        FROM part p
        WHERE p.p_name LIKE 'forest%'
    )
    AND ps.ps_availqty >
    (
        SELECT
            0.5 * SUM(l.l_quantity)
        FROM lineitem l
        WHERE l.l_partkey = ps.ps_partkey
          AND l.l_suppkey = ps.ps_suppkey
          AND l.l_shipdate >= '1994-01-01'
          AND l.l_shipdate < DATEADD(YEAR, 1, CAST('1994-01-01' AS DATETIME))
    )
)
AND n.n_name = 'CANADA'
ORDER BY
    s.s_name
OPTION (MAXDOP 2);