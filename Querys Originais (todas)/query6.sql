USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    SUM(l_extendedprice * l_discount) AS revenue
FROM dbo.lineitem
WHERE l_shipdate >= '1994-01-01'
  AND l_shipdate < DATEADD(YEAR, 1, CAST('1994-01-01' AS DATETIME))
  AND l_discount BETWEEN 0.05 - 0.01 AND 0.05 + 0.01
  AND l_quantity < 24
OPTION (MAXDOP 2);