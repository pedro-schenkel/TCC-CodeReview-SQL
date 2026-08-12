USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    l.l_shipmode,
    SUM(
        CASE
            WHEN o.o_orderpriority IN ('1-URGENT', '2-HIGH')
                THEN 1
            ELSE 0
        END
    ) AS high_line_count,
    SUM(
        CASE
            WHEN o.o_orderpriority NOT IN ('1-URGENT', '2-HIGH')
                THEN 1
            ELSE 0
        END
    ) AS low_line_count
FROM orders o
INNER JOIN lineitem l
    ON o.o_orderkey = l.l_orderkey
WHERE l.l_shipmode IN ('MAIL', 'SHIP')
  AND l.l_commitdate < l.l_receiptdate
  AND l.l_shipdate < l.l_commitdate
  AND l.l_receiptdate >= '1994-01-01'
  AND l.l_receiptdate < DATEADD(MONTH, 1, CAST('1994-01-01' AS DATETIME))
GROUP BY
    l.l_shipmode
ORDER BY
    l.l_shipmode
OPTION (MAXDOP 2);