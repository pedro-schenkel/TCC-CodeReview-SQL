DBCC DROPCLEANBUFFERS; -- Limpa o cache de dados
DBCC FREEPROCCACHE; -- Limpa os planos de execução

USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT TOP (20)
    c.c_custkey,
    c.c_name,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue,
    c.c_acctbal,
    n.n_name,
    c.c_address,
    c.c_phone,
    c.c_comment
FROM customer c
INNER JOIN orders o
    ON c.c_custkey = o.o_custkey
INNER JOIN lineitem l
    ON l.l_orderkey = o.o_orderkey
INNER JOIN nation n
    ON c.c_nationkey = n.n_nationkey
WHERE YEAR(o.o_orderdate) = 1994
  AND MONTH(o.o_orderdate) BETWEEN 1 AND 3
  AND l.l_returnflag = 'R'
GROUP BY
    c.c_custkey,
    c.c_name,
    c.c_acctbal,
    c.c_phone,
    n.n_name,
    c.c_address,
    c.c_comment
ORDER BY
    revenue DESC
OPTION (MAXDOP 2);