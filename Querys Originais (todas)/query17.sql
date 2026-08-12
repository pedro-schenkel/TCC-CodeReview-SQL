USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    SUM(l.l_extendedprice) / 7.0 AS avg_yearly
FROM part p
INNER JOIN lineitem l
    ON p.p_partkey = l.l_partkey
WHERE p.p_brand = 'Brand#23'
  AND p.p_container = 'MED BOX'
  AND l.l_quantity <
  (
      SELECT
          0.2 * AVG(l2.l_quantity)
      FROM lineitem l2
      WHERE l2.l_partkey = p.p_partkey
  )
OPTION (MAXDOP 2);