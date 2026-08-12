DBCC DROPCLEANBUFFERS; -- Limpa o cache de dados
DBCC FREEPROCCACHE; -- Limpa os planos de execução

USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT TOP (10)
    l.l_orderkey,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue,
    o.o_orderdate,
    o.o_shippriority
FROM customer c
INNER JOIN orders o
    ON c.c_custkey = o.o_custkey
INNER JOIN lineitem l
    ON l.l_orderkey = o.o_orderkey
WHERE c.c_mktsegment= 'BUILDING'
  AND o.o_orderdate < '1995-03-15'
  AND l.l_shipdate > '1995-03-15'
GROUP BY
    l.l_orderkey,
    o.o_orderdate,
    o.o_shippriority
ORDER BY
    revenue DESC,
    o.o_orderdate
OPTION (MAXDOP 2);