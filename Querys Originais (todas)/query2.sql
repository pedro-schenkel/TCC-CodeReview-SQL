USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT TOP (100)
    s.s_acctbal,
    s.s_name,
    n.n_name,
    p.p_partkey,
    p.p_mfgr,
    s.s_address,
    s.s_phone,
    s.s_comment
FROM part p
INNER JOIN partsupp ps
    ON p.p_partkey = ps.ps_partkey
INNER JOIN supplier s
    ON s.s_suppkey = ps.ps_suppkey
INNER JOIN nation n
    ON s.s_nationkey = n.n_nationkey
INNER JOIN region r
    ON n.n_regionkey = r.r_regionkey
WHERE p.p_size = 15
  AND p.p_type LIKE '%BRASS'
  AND r.r_name = 'EUROPE'
  AND ps.ps_supplycost =
  (
      SELECT MIN(ps2.ps_supplycost)
      FROM partsupp ps2
      INNER JOIN supplier s2
          ON s2.s_suppkey = ps2.ps_suppkey
      INNER JOIN nation n2
          ON s2.s_nationkey = n2.n_nationkey
      INNER JOIN region r2
          ON n2.n_regionkey = r2.r_regionkey
      WHERE ps2.ps_partkey = p.p_partkey
        AND r2.r_name = 'EUROPE'
  )
ORDER BY
    s.s_acctbal DESC,
    n.n_name,
    s.s_name,
    p.p_partkey
OPTION (MAXDOP 2);