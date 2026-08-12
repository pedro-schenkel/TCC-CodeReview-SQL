DBCC DROPCLEANBUFFERS; -- Limpa o cache de dados
DBCC FREEPROCCACHE; -- Limpa os planos de execução

USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    l_returnflag,
    l_linestatus,
    SUM(CAST(l_quantity AS BIGINT)) AS sum_qty,
    SUM(l_extendedprice) AS sum_base_price,
    SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
    SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
    AVG(CAST(l_quantity AS BIGINT)) AS avg_qty,
    AVG(l_extendedprice) AS avg_price,
    AVG(l_discount) AS avg_disc,
    COUNT_BIG(*) AS count_order
FROM dbo.LINEITEM
WHERE year(l_shipdate)<= '1998' -- adicionado year
GROUP BY
    l_returnflag,
    l_linestatus
ORDER BY
    l_returnflag,
    l_linestatus
OPTION (MAXDOP 2);