DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;

USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT TOP (20)
    c.c_custkey,
    c.c_name,

    (
        SELECT SUM(l2.l_extendedprice * (1 - l2.l_discount))
        FROM orders o2
        INNER JOIN lineitem l2
            ON l2.l_orderkey = o2.o_orderkey
        WHERE o2.o_custkey = c.c_custkey
          AND o2.o_orderdate >= '1994-01-01'
          AND o2.o_orderdate < DATEADD(MONTH,3,CAST('1994-01-01' AS DATETIME))
          AND l2.l_returnflag = 'R'
    ) AS revenue,

    c.c_acctbal,
    n.n_name,
    c.c_address,
    c.c_phone,
    c.c_comment

FROM customer c
INNER JOIN nation n
    ON c.c_nationkey = n.n_nationkey

WHERE EXISTS
(
    SELECT 1
    FROM orders o
    INNER JOIN lineitem l
        ON l.l_orderkey = o.o_orderkey
    WHERE o.o_custkey = c.c_custkey
      AND o.o_orderdate >= '1994-01-01'
      AND o.o_orderdate < DATEADD(MONTH,3,CAST('1994-01-01' AS DATETIME))
      AND l.l_returnflag = 'R'
)

ORDER BY revenue DESC
OPTION (MAXDOP 2);


-- Para cada cliente é realizado uma subconsulta do select, subconsulta correlacionada.