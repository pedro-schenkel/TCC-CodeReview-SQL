USE TPCH;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Q10_ImplicitConversion
(
    @StartDate  NVARCHAR(20),
    @EndDate    NVARCHAR(20),
    @ReturnFlag NVARCHAR(10)
)
AS
BEGIN
    SET NOCOUNT ON;

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
    WHERE o.o_orderdate >= @StartDate
      AND o.o_orderdate < @EndDate
      AND l.l_returnflag = @ReturnFlag
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
END;
GO


DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

USE TPCH;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

EXEC dbo.usp_Q10_ImplicitConversion
    @StartDate  = '1994-01-01',
    @EndDate    = '1994-04-01',
    @ReturnFlag = 'R';
GO