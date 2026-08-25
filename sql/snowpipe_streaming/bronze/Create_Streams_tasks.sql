-- ===================================
-- Configure Snowflake Session 
-- ===================================
USE ROLE ACCOUNTADMIN;
USE DATABASE BANKING;
USE SCHEMA RAW_STREAMING;
USE WAREHOUSE COMPUTE_WH;
-- =====================================
-- Create a Snowflake Stream 
-- =====================================
-- Note: Run Streaming_run.py to append rows to the table before 
-- creating Stream
CREATE OR REPLACE STREAM BANKING.RAW_STREAMING.TRANSACTIONS_STREAM
ON TABLE BANKING.RAW_STREAMING.TRANSACTIONS
SHOW_INITIAL_ROWS = TRUE
APPEND_ONLY=TRUE;
-- ========================================================
-- Verify 
-- ========================================================
SELECT
    PAYLOAD,
    INGESTED_AT,
    METADATA$ACTION,
    METADATA$ISUPDATE,
    METADATA$ROW_ID
FROM BANKING.RAW_STREAMING.TRANSACTIONS_STREAM;
-- ===================================================
-- Change Schema
-- ==================================================
USE SCHEMA BRONZE;
-- ===============================================
-- Create Stream
-- ==============================================
CREATE OR REPLACE TASK BANKING.BRONZE.LOAD_BRONZE_TRANSACTIONS
WAREHOUSE=COMPUTE_WH
WHEN SYSTEM$STREAM_HAS_DATA(
    'BANKING.RAW_STREAMING.TRANSACTIONS_STREAM'
)
AS
INSERT INTO BANKING.BRONZE.BRONZE_TRANSACTIONS(
    TRANSACTION_ID,
    SOURCE_ACCOUNT_ID,
    DESTINATION_ACCOUNT_ID,
    MERCHANT_ID,
    AMOUNT,
    CURRENCY,
    TRANSACTION_TYPE,
    TRANSACTION_TIMESTAMP,
    STATUS
)
    SELECT 
            PAYLOAD:transaction_id::STRING AS transaction_id,
            PAYLOAD:source_account_id::STRING AS source_account_id,
            PAYLOAD:destination_account_id::STRING AS destination_account_id,
            PAYLOAD:merchant_id::STRING AS merchant_id,
            PAYLOAD:amount::FLOAT AS amount,
            PAYLOAD:currency::STRING AS currency,
            PAYLOAD:transaction_type::STRING AS transaction_type,
            PAYLOAD:transaction_timestamp::datetime AS transaction_timestamp,
            PAYLOAD:status::STRING AS status
FROM RAW_STREAMING.TRANSACTIONS_STREAM;
-- =================================================================
-- SUSPEND THE TASK INITIALLY TO VALIDATE
-- ================================================================
ALTER TASK BANKING.BRONZE.LOAD_BRONZE_TRANSACTIONS
SUSPEND;
-- ========================================================================================
-- Manually Run task 
-- =======================================================================================
EXECUTE TASK BANKING.BRONZE.LOAD_BRONZE_TRANSACTIONS;
-- ==============================================================
-- COUNT ROWS FOR CONFIRMATION
-- =============================================================
SELECT
        (SELECT COUNT(*)FROM RAW.RAW_TRANSACTIONS) AS RAW_TRANSACTION_ROW_COUNTS,
        (SELECT COUNT(*) FROM BRONZE.BRONZE_TRANSACTIONS) AS BRONZE_TRANSACTION_COUNTS;

-- ==========================================================================
-- Check Execution History For Any Errors
-- ========================================================================

SELECT
    NAME,
    STATE,
    SCHEDULED_TIME,
    COMPLETED_TIME,
    QUERY_ID,
    ERROR_CODE,
    ERROR_MESSAGE,
    SCHEDULED_FROM
FROM TABLE(
    SNOWFLAKE.INFORMATION_SCHEMA.TASK_HISTORY(
        TASK_NAME => 'LOAD_BRONZE_TRANSACTIONS',
        RESULT_LIMIT => 20
    )
)
ORDER BY SCHEDULED_TIME DESC;

-- =================================================================
-- RESUME TASK
-- ================================================================
ALTER TASK BANKING.BRONZE.LOAD_BRONZE_TRANSACTIONS
RESUME;