USE TPCH;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Q18_Cursor
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #Resultado
    (
        c_name          VARCHAR(25),
        c_custkey       INT,
        o_orderkey      INT PRIMARY KEY,
        o_orderdate     DATE,
        o_totalprice    DECIMAL(15,2),
        total_quantity  DECIMAL(15,2)
    );

    DECLARE
        @c_name         VARCHAR(25),
        @c_custkey      INT,
        @o_orderkey     INT,
        @o_orderdate    DATE,
        @o_totalprice   DECIMAL(15,2),
        @l_quantity     DECIMAL(15,2);

    DECLARE cQ18 CURSOR FOR

        SELECT
            c.c_name,
            c.c_custkey,
            o.o_orderkey,
            o.o_orderdate,
            o.o_totalprice,
            l.l_quantity
        FROM customer c
        INNER JOIN orders o
            ON c.c_custkey = o.o_custkey
        INNER JOIN lineitem l
            ON o.o_orderkey = l.l_orderkey
        WHERE o.o_orderkey IN
        (
            SELECT
                l2.l_orderkey
            FROM lineitem l2
            GROUP BY l2.l_orderkey
            HAVING SUM(l2.l_quantity) > 312
        );

    OPEN cQ18;

    FETCH NEXT FROM cQ18
    INTO
        @c_name,
        @c_custkey,
        @o_orderkey,
        @o_orderdate,
        @o_totalprice,
        @l_quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        UPDATE #Resultado
           SET total_quantity = total_quantity + @l_quantity
         WHERE o_orderkey = @o_orderkey;

        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO #Resultado
            (
                c_name,
                c_custkey,
                o_orderkey,
                o_orderdate,
                o_totalprice,
                total_quantity
            )
            VALUES
            (
                @c_name,
                @c_custkey,
                @o_orderkey,
                @o_orderdate,
                @o_totalprice,
                @l_quantity
            );
        END;

        FETCH NEXT FROM cQ18
        INTO
            @c_name,
            @c_custkey,
            @o_orderkey,
            @o_orderdate,
            @o_totalprice,
            @l_quantity;

    END

    CLOSE cQ18;
    DEALLOCATE cQ18;

    SELECT TOP (100)
        c_name,
        c_custkey,
        o_orderkey,
        o_orderdate,
        o_totalprice,
        total_quantity
    FROM #Resultado
    ORDER BY
        o_totalprice DESC,
        o_orderdate;

END;
GO


DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

EXEC dbo.usp_Q18_Cursor;