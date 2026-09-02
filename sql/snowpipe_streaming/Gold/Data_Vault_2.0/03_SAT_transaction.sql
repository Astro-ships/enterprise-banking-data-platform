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
CREATE OR REPLACE STREAM  BANKING.SILVER.SAT_TRANSACTION_STREAM
ON TABLE SILVER.SILVER_TRANSACTIONS
APPEND_ONLY=TRUE;
-- ===================================================
-- CREATE TASK 
-- ==================================================
SHOW COLUMNS IN TABLE BANKING.GOLD.SAT_TRANSACTION;

USE SCHEMA GOLD;
CREATE OR REPLACE TASK GOLD.SAT_TRANSACTION_TASK
    WAREHOUSE=COMPUTE_WH
    AFTER BANKING.GOLD.LINK_TRANSACTION_TASK
AS 
INSERT INTO  BANKING.GOLD.SAT_TRANSACTION(
TRANSACTION_HK,
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
            HT.TRANSACTION_HK,
            ST.SOURCE_ACCOUNT_ID,
            ST.DESTINATION_ACCOUNT_ID,
            ST.MERCHANT_ID,
            ST.AMOUNT,
            ST.CURRENCY,
            ST.TRANSACTION_TYPE,
            ST.TRANSACTION_TIMESTAMP,
            ST.STATUS
    FROM BANKING.SILVER.SAT_TRANSACTION_STREAM AS ST 
    INNER JOIN HUB_TRANSACTION AS HT 
    ON 
    ST.TRANSACTION_ID = HT.TRANSACTION_ID;
-- ========================================================
-- Suspend Taks Iniitally
-- ========================================================
ALTER TASK GOLD.SAT_TRANSACTION_TASK
SUSPEND;