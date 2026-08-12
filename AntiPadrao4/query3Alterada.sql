USE TPCH;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Q3_ImplicitConversion
(
    @MarketSegment NVARCHAR(20),
    @OrderDate     NVARCHAR(20),
    @ShipDate      NVARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

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
    WHERE c.c_mktsegment = @MarketSegment
      AND o.o_orderdate < @OrderDate
      AND l.l_shipdate > @ShipDate
    GROUP BY
        l.l_orderkey,
        o.o_orderdate,
        o.o_shippriority
    ORDER BY
        revenue DESC,
        o.o_orderdate
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

EXEC dbo.usp_Q3_ImplicitConversion
    @MarketSegment = N'BUILDING',
    @OrderDate     = N'1995-03-15',
    @ShipDate      = N'1995-03-15';