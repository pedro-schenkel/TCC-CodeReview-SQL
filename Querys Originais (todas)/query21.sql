USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT TOP (100)
    s.s_name,
    COUNT_BIG(*) AS numwait
FROM supplier s
INNER JOIN lineitem l1
    ON s.s_suppkey = l1.l_suppkey
INNER JOIN orders o
    ON o.o_orderkey = l1.l_orderkey
INNER JOIN nation n
    ON s.s_nationkey = n.n_nationkey
WHERE o.o_orderstatus = 'F'
  AND l1.l_receiptdate > l1.l_commitdate
  AND EXISTS
  (
      SELECT 1
      FROM lineitem l2
      WHERE l2.l_orderkey = l1.l_orderkey
        AND l2.l_suppkey <> l1.l_suppkey
  )
  AND NOT EXISTS
  (
      SELECT 1
      FROM lineitem l3
      WHERE l3.l_orderkey = l1.l_orderkey
        AND l3.l_suppkey <> l1.l_suppkey
        AND l3.l_receiptdate > l3.l_commitdate
  )
  AND n.n_name = 'SAUDI ARABIA'
GROUP BY
    s.s_name
ORDER BY
    numwait DESC,
    s.s_name
OPTION (MAXDOP 2);