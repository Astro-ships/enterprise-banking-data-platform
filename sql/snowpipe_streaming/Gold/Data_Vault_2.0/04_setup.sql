-- ================================================================
-- ENTERPRISE BANKING DATA PLATFORM
-- STREAMING PIPELINE - GOLD VERIFICATION / EXECUTION
-- ================================================================
--
-- WORKING ARCHITECTURE:
--
-- Python Event Generator
--        |
--        v
-- Snowpipe Streaming
--        |
--        v
-- RAW_STREAMING.TRANSACTIONS
--        |
--        v
-- Bronze Stream / Bronze Task
--        |
--        v
-- BRONZE.BRONZE_TRANSACTIONS
--        |
--        v
-- Bronze Stream / Silver Task
--        |
--        v
-- SILVER.SILVER_TRANSACTIONS
--        |
--        +-----------------------------+
--        |             |               |
--        v             v               v
-- HUB STREAM       LINK STREAM      SAT STREAM
--        |             |               |
--        v             v               v
-- HUB TASK         LINK TASK        SAT TASK
--        |             |               |
--        v             v               v
-- HUB_TRANSACTION  LINK_ACCOUNT_    SAT_TRANSACTION
--                  TRANSACTION
--
-- IMPORTANT:
-- Hub, Link and Satellite use THREE INDEPENDENT STREAMS.
-- Each stream maintains its own consumption offset.
--
-- The three Gold Tasks are intentionally independent
-- stream-triggered tasks:
--
--     WHEN SYSTEM$STREAM_HAS_DATA(...)
--
-- The Stream determines whether new data is available.
-- The INSERT ... SELECT determines what data is inserted.
--
-- ================================================================


-- ================================================================
-- 1. CONFIGURE SNOWFLAKE SESSION
-- ================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE BANKING;
USE SCHEMA GOLD;


-- ================================================================
-- 2. STREAM STATUS CHECK
-- ================================================================
--
-- Before testing the Gold layer, verify whether each independent
-- Silver Stream contains unconsumed changes.
--
-- TRUE  = new/unconsumed rows are available
-- FALSE = no unconsumed rows are currently available
--
-- During a fresh streaming test, all three should normally become
-- TRUE after a new transaction reaches SILVER.
--
-- ================================================================

SELECT
    SYSTEM$STREAM_HAS_DATA(
        'BANKING.SILVER.SILVER_HUB_TRANSACTION_STREAM'
    ) AS HUB_STREAM,

    SYSTEM$STREAM_HAS_DATA(
        'BANKING.SILVER.LINK_TRANSACTION_STREAM'
    ) AS LINK_STREAM,

    SYSTEM$STREAM_HAS_DATA(
        'BANKING.SILVER.SAT_TRANSACTION_STREAM'
    ) AS SAT_STREAM;


-- ================================================================
-- 3. MANUAL GOLD TEST
-- ================================================================
--
-- Only the ROOT task is manually executed.
-- Link and Satellite are child tasks and will run automatically
-- after their predecessor completes successfully.
-- 
-- ================================================================

EXECUTE TASK BANKING.GOLD.GOLD_LOAD_HUB_TRANSACTION;

-- ================================================================
-- 4. VERIFY STREAM CONSUMPTION
-- ================================================================
--
-- After the Tasks have successfully consumed their streams,
-- the corresponding streams should report FALSE.
--
-- Expected:
--
--     HUB_STREAM  = FALSE
--     LINK_STREAM = FALSE
--     SAT_STREAM  = FALSE
--
-- ================================================================

SELECT
    SYSTEM$STREAM_HAS_DATA(
        'BANKING.SILVER.SILVER_HUB_TRANSACTION_STREAM'
    ) AS HUB_STREAM,

    SYSTEM$STREAM_HAS_DATA(
        'BANKING.SILVER.LINK_TRANSACTION_STREAM'
    ) AS LINK_STREAM,

    SYSTEM$STREAM_HAS_DATA(
        'BANKING.SILVER.SAT_TRANSACTION_STREAM'
    ) AS SAT_STREAM;


-- ================================================================
-- 5. VERIFY GOLD TASK EXECUTION
-- ================================================================
--
-- Check whether the three Gold Tasks completed successfully.
--
-- STATE = SUCCEEDED means Snowflake successfully executed the Task.
--
-- ================================================================

SELECT
    NAME,
    STATE,
    SCHEDULED_FROM,
    SCHEDULED_TIME,
    COMPLETED_TIME,
    QUERY_ID,
    ERROR_CODE,
    ERROR_MESSAGE
FROM TABLE(
    SNOWFLAKE.INFORMATION_SCHEMA.TASK_HISTORY(
        RESULT_LIMIT => 20
    )
)
WHERE NAME IN (
    'GOLD_LOAD_HUB_TRANSACTION',
    'LINK_TRANSACTION_TASK',
    'SAT_TRANSACTION_TASK'
)
ORDER BY SCHEDULED_TIME DESC;


-- ================================================================
-- 6. VERIFY ROW COUNTS
-- ================================================================
--
-- The Gold tables should match the Silver transaction count
-- when every Silver transaction has successfully propagated
-- through the Gold Data Vault layer.
--
-- Expected:
--
--     SILVER_TRANSACTION_COUNT
--             =
--     HUB_COUNT
--             =
--     LINK_COUNT
--             =
--     SAT_TRANSACTION_COUNT
--
-- ================================================================

SELECT
    (
        SELECT COUNT(*)
        FROM BANKING.SILVER.SILVER_TRANSACTIONS
    ) AS SILVER_TRANSACTION_COUNT,

    (
        SELECT COUNT(*)
        FROM BANKING.GOLD.HUB_TRANSACTION
    ) AS HUB_COUNT,

    (
        SELECT COUNT(*)
        FROM BANKING.GOLD.LINK_ACCOUNT_TRANSACTION
    ) AS LINK_COUNT,

    (
        SELECT COUNT(*)
        FROM BANKING.GOLD.SAT_TRANSACTION
    ) AS SAT_TRANSACTION_COUNT;


-- ================================================================
-- 7. AUTOMATIC STREAMING MODE
-- ================================================================
--
-- Once the manual test is confirmed to be working:
--
--     Python Event Generator
--             |
--             v
--     Snowpipe Streaming
--             |
--             v
--          RAW
--             |
--             v
--          BRONZE
--             |
--             v
--          SILVER
--             |
--       +-----+-----+
--       |     |     |
--       v     v     v
--      HUB   LINK  SAT
--
-- The Gold Tasks can be resumed so Snowflake automatically
-- monitors their respective Streams.
--
-- Each Task is independently triggered by:
--
--     WHEN SYSTEM$STREAM_HAS_DATA(...)
--
-- ================================================================

ALTER TASK BANKING.GOLD.GOLD_LOAD_HUB_TRANSACTION RESUME;



-- ================================================================
-- 8. AUTOMATIC MODE VERIFICATION
-- ================================================================
--
-- After the Tasks are resumed:
--
-- 1. Start the Python transaction generator.
-- 2. Allow new transactions to flow through RAW -> BRONZE -> SILVER.
-- 3. Each Silver Stream should detect the new rows.
-- 4. Each Gold Task should automatically execute.
--
-- No EXECUTE TASK commands are required in automatic mode.
--
-- ================================================================

SHOW TASKS IN SCHEMA BANKING.GOLD;


-- ================================================================
-- 9. FINAL VALIDATION
-- ================================================================
--
-- Use this after allowing new streaming transactions to flow.
--
-- The four transaction counts should remain aligned.
--
-- ================================================================

SELECT
    (SELECT COUNT(*) FROM BANKING.RAW_STREAMING.TRANSACTIONS ) AS RAW_TRANSACTION_COUNT,
    (SELECT COUNT(*) FROM BANKING.BRONZE.BRONZE_TRANSACTIONS) AS BRONZE_TRANSACTION_COUNT,
    (SELECT COUNT(*)FROM BANKING.SILVER.SILVER_TRANSACTIONS) AS SILVER_TRANSACTION_COUNT,
    (SELECT COUNT(*)FROM BANKING.GOLD.HUB_TRANSACTION) AS GOLD_HUB_COUNT,
    (SELECT COUNT(*) FROM BANKING.GOLD.LINK_ACCOUNT_TRANSACTION) AS GOLD_LINK_COUNT,
    (SELECT COUNT(*)FROM BANKING.GOLD.SAT_TRANSACTION) AS GOLD_SAT_TRANSACTION_COUNT;


-- ================================================================
-- END OF GOLD STREAMING VERIFICATION
-- ================================================================