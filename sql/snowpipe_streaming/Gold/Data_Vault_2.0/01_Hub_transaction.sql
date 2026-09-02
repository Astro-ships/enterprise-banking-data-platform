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
  CREATE OR REPLACE STREAM  BANKING.SILVER.SILVER_HUB_TRANSACTION_STREAM
  ON TABLE SILVER.SILVER_TRANSACTIONS
  APPEND_ONLY=TRUE;

  -- ===========================================
  -- Create TASK For Hub Transaction
  -- ===========================================
  SHOW COLUMNS IN TABLE GOLD.HUB_TRANSACTION;
  USE SCHEMA GOLD;
  CREATE OR REPLACE TASK GOLD.GOLD_LOAD_HUB_TRANSACTION 
  WAREHOUSE=COMPUTE_WH
  WHEN SYSTEM$STREAM_HAS_DATA(
    'BANKING.SILVER.SILVER_HUB_TRANSACTION_STREAM'
  )
  AS 
  INSERT INTO GOLD.HUB_TRANSACTION (
TRANSACTION_HK,
TRANSACTION_ID,
LOAD_DATE,
LOAD_SOURCE

  )
-- ======================================
-- Transform data 
-- =======================================
    SELECT 
        MD5(transaction_id)  AS transaction_hk,
        transaction_id,
        current_timestamp() AS load_date,
        'SILVER.SILVER_TRANSACTIONS' AS load_source
FROM BANKING.SILVER.SILVER_HUB_TRANSACTION_STREAM AS ST
-- ==========================================================================================
-- Only insert this transaction if a matching transaction doesn't already exist in the Hub.
-- ==========================================================================================
WHERE NOT EXISTS(
    SELECT 1 FROM GOLD.HUB_TRANSACTION AS HT 
    WHERE HT.TRANSACTION_HK=MD5(ST.TRANSACTION_ID)
        AND HT.TRANSACTION_ID = ST.TRANSACTION_ID
);
-- ========================================================
-- SUSPEND TASK INITIALLY
-- ======================================================== 
ALTER TASK GOLD.GOLD_LOAD_HUB_TRANSACTION 
SUSPEND;