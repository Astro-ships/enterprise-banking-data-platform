-- ===============================
-- Configure Snowflake Session
-- ===============================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE BANKING;
USE SCHEMA SILVER;
-- =================================
-- Create Task
-- =================================
SHOW COLUMNS IN TABLE SILVER.SILVER_TRANSACTIONS;
-- ----------------------------------

CREATE OR REPLACE TASK BANKING.SILVER.LOAD_SILVER_TRANSACTIONS 
WAREHOUSE=COMPUTE_WH
WHEN SYSTEM$STREAM_HAS_DATA(
    'BANKING.BRONZE.BRONZE_TRANSACTION_STREAM'
)
AS 
INSERT INTO BANKING.SILVER.SILVER_TRANSACTIONS(
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
-- ========================================
-- USE THE TRANSFORMATION TECHNIQUE ALREADY
-- USED IN INITITAL PAYLOAD (copy and paste)
-- ========================================
    SELECT 
            BT.TRANSACTION_ID,
            BT.SOURCE_ACCOUNT_ID,
   COALESCE(BT.DESTINATION_ACCOUNT_ID,'NOT_APPLICABLE') AS DESTINATION_ACCOUNT_ID,
   COALESCE(BT.MERCHANT_ID,'NOT_APPLICABLE') AS MERCHANT_ID,
            BT.AMOUNT,
   COALESCE(CL.CORRECT_VALUE,BT.CURRENCY) AS CURRENCY,
            BT.TRANSACTION_TYPE,
            TRANSACTION_TIMESTAMP,
    COALESCE(SL.CORRECT_VALUE,TRIM(BT.STATUS)) AS STATUS
    FROM BANKING.BRONZE.BRONZE_TRANSACTION_STREAM  AS BT
    
    LEFT JOIN SILVER.ACCOUNT_CURRENCY_LOOKUP AS CL
    ON 
    BT.currency = cl.INCORRECT_VALUE
    LEFT JOIN SILVER.STATUS_LOOKUP AS SL
    ON
    TRIM(BT.STATUS) = SL.INCORRECT_VALUE;
-- =============================================================
-- Keep the Task suspended initially
-- =============================================================
ALTER TASK BANKING.SILVER.LOAD_SILVER_TRANSACTIONS 
SUSPEND;
-- ===============================================================
-- Test manually 
-- ===============================================================
EXECUTE TASK BANKING.SILVER.LOAD_SILVER_TRANSACTIONS;
-- ===============================================================
-- Check Task History
-- ===============================================================
SELECT
    NAME,
    STATE,
    ERROR_CODE,
    ERROR_MESSAGE,
    QUERY_ID,
    SCHEDULED_TIME,
    COMPLETED_TIME
FROM TABLE(
    SNOWFLAKE.INFORMATION_SCHEMA.TASK_HISTORY(
        TASK_NAME => 'LOAD_SILVER_TRANSACTIONS',
        RESULT_LIMIT => 10
    )
)
ORDER BY SCHEDULED_TIME DESC;

SELECT GET_DDL(
    'TASK',
    'BANKING.SILVER.LOAD_SILVER_TRANSACTIONS'
);
-- ==============================================================================
-- Validate
-- ==============================================================================
SELECT 
(SELECT COUNT(*) FROM BRONZE.BRONZE_TRANSACTIONS) AS BRONZE_COUNT,
(SELECT COUNT(*) FROM SILVER.SILVER_TRANSACTIONS) AS SILVER_COUNT;
-- ===============================================================================
-- Check for quality the data thats being transformed
-- ===============================================================================
SELECT DISTINCT CURRENCY

FROM SILVER.SILVER_TRANSACTIONS;
SELECT DISTINCT STATUS FROM SILVER.SILVER_TRANSACTIONS;

-- ===============================================================================
-- Resume Task to automatically append rows
-- ==============================================================================
ALTER TASK SILVER.LOAD_SILVER_TRANSACTIONS
RESUME;
-- ===========================================================================