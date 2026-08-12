USE TPCH;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Q1_Cursor
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #Resultado
    (
        l_returnflag     CHAR(1),
        l_linestatus     CHAR(1),
        sum_qty          BIGINT,
        sum_base_price   DECIMAL(18,2),
        sum_disc_price   DECIMAL(18,2),
        sum_charge       DECIMAL(18,2),
        avg_qty          DECIMAL(18,2),
        avg_price        DECIMAL(18,2),
        avg_disc         DECIMAL(18,4),
        count_order      BIGINT
    );

    DECLARE
        @returnflag CHAR(1),
        @linestatus CHAR(1),
        @quantity DECIMAL(15,2),
        @extendedprice DECIMAL(15,2),
        @discount DECIMAL(15,2),
        @tax DECIMAL(15,2);

    -------------------------------------------------------------------------
    -- Acumuladores para A/F
    -------------------------------------------------------------------------

    DECLARE
        @AF_sum_qty BIGINT = 0,
        @AF_sum_base DECIMAL(18,2) = 0,
        @AF_sum_disc DECIMAL(18,2) = 0,
        @AF_sum_charge DECIMAL(18,2) = 0,
        @AF_total_disc DECIMAL(18,4) = 0,
        @AF_count BIGINT = 0;

    -------------------------------------------------------------------------
    -- Acumuladores para N/F
    -------------------------------------------------------------------------

    DECLARE
        @NF_sum_qty BIGINT = 0,
        @NF_sum_base DECIMAL(18,2) = 0,
        @NF_sum_disc DECIMAL(18,2) = 0,
        @NF_sum_charge DECIMAL(18,2) = 0,
        @NF_total_disc DECIMAL(18,4) = 0,
        @NF_count BIGINT = 0;

    -------------------------------------------------------------------------
    -- Acumuladores para N/O
    -------------------------------------------------------------------------

    DECLARE
        @NO_sum_qty BIGINT = 0,
        @NO_sum_base DECIMAL(18,2) = 0,
        @NO_sum_disc DECIMAL(18,2) = 0,
        @NO_sum_charge DECIMAL(18,2) = 0,
        @NO_total_disc DECIMAL(18,4) = 0,
        @NO_count BIGINT = 0;

    -------------------------------------------------------------------------
    -- Acumuladores para R/F
    -------------------------------------------------------------------------

    DECLARE
        @RF_sum_qty BIGINT = 0,
        @RF_sum_base DECIMAL(18,2) = 0,
        @RF_sum_disc DECIMAL(18,2) = 0,
        @RF_sum_charge DECIMAL(18,2) = 0,
        @RF_total_disc DECIMAL(18,4) = 0,
        @RF_count BIGINT = 0;

    DECLARE cLineItem CURSOR FOR

        SELECT
            l_returnflag,
            l_linestatus,
            l_quantity,
            l_extendedprice,
            l_discount,
            l_tax
        FROM LINEITEM
        WHERE l_shipdate <= DATEADD(DAY,-90,'1998-12-01');

    OPEN cLineItem;

    FETCH NEXT FROM cLineItem
    INTO
        @returnflag,
        @linestatus,
        @quantity,
        @extendedprice,
        @discount,
        @tax;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        IF @returnflag='A' AND @linestatus='F'
        BEGIN
            SET @AF_sum_qty += CAST(@quantity AS BIGINT);
            SET @AF_sum_base += @extendedprice;
            SET @AF_sum_disc += @extendedprice*(1-@discount);
            SET @AF_sum_charge += @extendedprice*(1-@discount)*(1+@tax);
            SET @AF_total_disc += @discount;
            SET @AF_count += 1;
        END
        ELSE IF @returnflag='N' AND @linestatus='F'
        BEGIN
            SET @NF_sum_qty += CAST(@quantity AS BIGINT);
            SET @NF_sum_base += @extendedprice;
            SET @NF_sum_disc += @extendedprice*(1-@discount);
            SET @NF_sum_charge += @extendedprice*(1-@discount)*(1+@tax);
            SET @NF_total_disc += @discount;
            SET @NF_count += 1;
        END
        ELSE IF @returnflag='N' AND @linestatus='O'
        BEGIN
            SET @NO_sum_qty += CAST(@quantity AS BIGINT);
            SET @NO_sum_base += @extendedprice;
            SET @NO_sum_disc += @extendedprice*(1-@discount);
            SET @NO_sum_charge += @extendedprice*(1-@discount)*(1+@tax);
            SET @NO_total_disc += @discount;
            SET @NO_count += 1;
        END
        ELSE IF @returnflag='R' AND @linestatus='F'
        BEGIN
            SET @RF_sum_qty += CAST(@quantity AS BIGINT);
            SET @RF_sum_base += @extendedprice;
            SET @RF_sum_disc += @extendedprice*(1-@discount);
            SET @RF_sum_charge += @extendedprice*(1-@discount)*(1+@tax);
            SET @RF_total_disc += @discount;
            SET @RF_count += 1;
        END

        FETCH NEXT FROM cLineItem
        INTO
            @returnflag,
            @linestatus,
            @quantity,
            @extendedprice,
            @discount,
            @tax;

    END

    CLOSE cLineItem;
    DEALLOCATE cLineItem;

    INSERT INTO #Resultado
    VALUES
    (
        'A','F',
        @AF_sum_qty,
        @AF_sum_base,
        @AF_sum_disc,
        @AF_sum_charge,
        @AF_sum_qty*1.0/@AF_count,
        @AF_sum_base/@AF_count,
        @AF_total_disc/@AF_count,
        @AF_count
    ),
    (
        'N','F',
        @NF_sum_qty,
        @NF_sum_base,
        @NF_sum_disc,
        @NF_sum_charge,
        @NF_sum_qty*1.0/@NF_count,
        @NF_sum_base/@NF_count,
        @NF_total_disc/@NF_count,
        @NF_count
    ),
    (
        'N','O',
        @NO_sum_qty,
        @NO_sum_base,
        @NO_sum_disc,
        @NO_sum_charge,
        @NO_sum_qty*1.0/@NO_count,
        @NO_sum_base/@NO_count,
        @NO_total_disc/@NO_count,
        @NO_count
    ),
    (
        'R','F',
        @RF_sum_qty,
        @RF_sum_base,
        @RF_sum_disc,
        @RF_sum_charge,
        @RF_sum_qty*1.0/@RF_count,
        @RF_sum_base/@RF_count,
        @RF_total_disc/@RF_count,
        @RF_count
    );

    SELECT *
    FROM #Resultado
    ORDER BY
        l_returnflag,
        l_linestatus;

END;
GO



DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

EXEC dbo.usp_Q1_Cursor;