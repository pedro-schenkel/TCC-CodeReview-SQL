USE TPCH;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Q1_ImplicitConversion
(
    @ShipDate NVARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

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
    WHERE l_shipdate <= DATEADD(DAY, -90, @ShipDate)
    GROUP BY
        l_returnflag,
        l_linestatus
    ORDER BY
        l_returnflag,
        l_linestatus
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

EXEC dbo.usp_Q1_ImplicitConversion
    @ShipDate = '1998-12-01';
GO