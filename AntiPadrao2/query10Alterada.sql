USE TPCH;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Q10_Cursor
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #Resultado
    (
        c_custkey      INT PRIMARY KEY,
        c_name         VARCHAR(25),
        revenue        DECIMAL(18,2),
        c_acctbal      DECIMAL(15,2),
        n_name         CHAR(25),
        c_address      VARCHAR(40),
        c_phone        CHAR(15),
        c_comment      VARCHAR(117)
    );

    DECLARE
        @c_custkey INT,
        @c_name VARCHAR(25),
        @revenue DECIMAL(18,2),
        @c_acctbal DECIMAL(15,2),
        @n_name CHAR(25),
        @c_address VARCHAR(40),
        @c_phone CHAR(15),
        @c_comment VARCHAR(117);

    DECLARE cQ10 CURSOR FOR

        SELECT
            c.c_custkey,
            c.c_name,
            l.l_extendedprice * (1 - l.l_discount),
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
        WHERE o.o_orderdate >= '1994-01-01'
          AND o.o_orderdate < DATEADD(MONTH,3,'1994-01-01')
          AND l.l_returnflag='R';

    OPEN cQ10;

    FETCH NEXT FROM cQ10
    INTO
        @c_custkey,
        @c_name,
        @revenue,
        @c_acctbal,
        @n_name,
        @c_address,
        @c_phone,
        @c_comment;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        UPDATE #Resultado
           SET revenue = revenue + @revenue
         WHERE c_custkey = @c_custkey;

        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO #Resultado
            (
                c_custkey,
                c_name,
                revenue,
                c_acctbal,
                n_name,
                c_address,
                c_phone,
                c_comment
            )
            VALUES
            (
                @c_custkey,
                @c_name,
                @revenue,
                @c_acctbal,
                @n_name,
                @c_address,
                @c_phone,
                @c_comment
            );
        END

        FETCH NEXT FROM cQ10
        INTO
            @c_custkey,
            @c_name,
            @revenue,
            @c_acctbal,
            @n_name,
            @c_address,
            @c_phone,
            @c_comment;

    END

    CLOSE cQ10;
    DEALLOCATE cQ10;

    SELECT TOP (20)
        c_custkey,
        c_name,
        revenue,
        c_acctbal,
        n_name,
        c_address,
        c_phone,
        c_comment
    FROM #Resultado
    ORDER BY revenue DESC;

END;
GO

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

EXEC dbo.usp_Q10_Cursor;