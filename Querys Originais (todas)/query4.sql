USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    o.o_orderpriority,
    COUNT_BIG(*) AS order_count
FROM orders o
WHERE o.o_orderdate >= '1995-01-01'
  AND o.o_orderdate < DATEADD(MONTH, 3, CAST('1995-01-01' AS DATETIME))
  AND EXISTS
  (
      SELECT 1
      FROM lineitem l
      WHERE l.l_orderkey = o.o_orderkey
        AND l.l_commitdate < l.l_receiptdate
  )
GROUP BY
    o.o_orderpriority
ORDER BY
    o.o_orderpriority
OPTION (MAXDOP 2);