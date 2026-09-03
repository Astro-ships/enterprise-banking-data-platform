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
  APPEND_ONLY=TRUE;
-- ===================================================
-- CREATE TASK 
-- ==================================================
SHOW COLUMNS IN TABLE BANKING.GOLD.LINK_ACCOUNT_TRANSACTION;

USE SCHEMA GOLD;
CREATE OR REPLACE TASK GOLD.LINK_TRANSACTION_TASK
    WAREHOUSE=COMPUTE_WH
    AFTER BANKING.GOLD.GOLD_LOAD_HUB_TRANSACTION
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
-- Alter task to run imediately
-- ========================================================
ALTER TASK GOLD.LINK_TRANSACTION_TASK
RESUME;
