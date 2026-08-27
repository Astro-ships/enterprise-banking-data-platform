-- ==============================
-- Snowflake Session
-- ==============================
 
 USE ROLE ACCOUNTADMIN;
 USE WAREHOUSE compute_wh;
 USE DATABASE BANKING;
USE SCHEMA SILVER;
  -- =============================================
  -- CREATE STREAM
  -- =============================================
  CREATE OR REPLACE STREAM  BANKING.SILVER.LINK_TRANSACTION_STREAM
  ON TABLE SILVER.SILVER_TRANSACTIONS
  APPEND_ONLY=TRUE
  SHOW_INITIAL_ROWS=TRUE;
-- ===================================================
-- CREATE TASK 
-- ==================================================
SHOW COLUMNS IN TABLE BANKING.GOLD.LINK_ACCOUNT_TRANSACTION;

USE SCHEMA GOLD;
CREATE OR REPLACE TASK GOLD.LINK_TRANSACTION_TASK
WAREHOUSE=COMPUTE_WH
WHEN SYSTEM$STREAM_HAS_DATA(
    'BANKING.SILVER.LINK_TRANSACTION_STREAM'
)
AS 
INSERT INTO  GOLD.LINK_ACCOUNT_TRANSACTION
(
ACCOUNT_TRANSACTION_HK,
ACCOUNT_HK,
TRANSACTION_HK,
LOAD_DATE,
RECORD_SOURCE
)
-- ========================================
-- Transform
-- ========================================
SELECT 
    MD5(ST.SOURCE_ACCOUNT_ID || '|' || ST.TRANSACTION_ID) AS account_transaction_hk,
    HA.account_hk,
    HT.transaction_hk,
    current_timestamp() AS load_date,
    'SILVER.SILVER_TRANSACTIONS' AS record_source
-- ================================================
-- From the stream created earlier
-- ===============================================
FROM BANKING.SILVER.LINK_TRANSACTION_STREAM AS ST
INNER JOIN BANKING.GOLD.HUB_ACCOUNT AS HA 
ON 
ST.SOURCE_ACCOUNT_ID = HA.account_id 
INNER JOIN BANKING.GOLD.HUB_TRANSACTION AS HT 
ON 
ST.TRANSACTION_ID = HT.TRANSACTION_ID;
-- ========================================================
-- Suspend Taks Iniitally
-- ========================================================
ALTER TASK GOLD.LINK_TRANSACTION_TASK
SUSPEND;
-- ====================================================
-- Execute Manually
-- ====================================================
EXECUTE TASK GOLD.LINK_TRANSACTION_TASK;
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
        TASK_NAME => 'GOLD.LINK_TRANSACTION_TASK',
        RESULT_LIMIT => 20
    )
)
ORDER BY SCHEDULED_TIME DESC;
-- ================================================================
-- Verify
-- ===============================================================
SELECT 
(SELECT COUNT(*) FROM SILVER.SILVER_TRANSACTIONS) AS SILVER_TRANSACTION_COUNT,
(SELECT COUNT(*) FROM GOLD.LINK_ACCOUNT_TRANSACTION) AS GOLD_TRANSACTION_COUNT;

-- Expected Result: Equal Rows-
-- ===========================================
-- Inspect
-- ===========================================
SELECT * FROM GOLD.LINK_ACCOUNT_TRANSACTION
ORDER BY LOAD_DATE DESC
LIMIT 5;
