USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    ps.ps_partkey,
    SUM(ps.ps_supplycost * ps.ps_availqty) AS value
FROM partsupp ps
INNER JOIN supplier s
    ON ps.ps_suppkey = s.s_suppkey
INNER JOIN nation n
    ON s.s_nationkey = n.n_nationkey
WHERE n.n_name = 'GERMANY'
GROUP BY
    ps.ps_partkey
HAVING
    SUM(ps.ps_supplycost * ps.ps_availqty) >
    (
        SELECT
            SUM(ps2.ps_supplycost * ps2.ps_availqty) * 0.0001
        FROM partsupp ps2
        INNER JOIN supplier s2
            ON ps2.ps_suppkey = s2.s_suppkey
        INNER JOIN nation n2
            ON s2.s_nationkey = n2.n_nationkey
        WHERE n2.n_name = 'GERMANY'
    )
ORDER BY
    value DESC
OPTION (MAXDOP 2);