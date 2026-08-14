-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- ===========================================
-- Create SAT_TRANSACTIONS TABLE 
-- ==========================================
CREATE TABLE IF NOT EXISTS SAT_TRANSACTION 
AS 
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
    FROM SILVER.SILVER_TRANSACTIONS AS ST 
    INNER JOIN HUB_TRANSACTION AS HT 
    ON 
    ST.TRANSACTION_ID = HT.TRANSACTION_ID;

-- =================================
-- VALIDATE 
-- =================================
SELECT *
FROM SAT_TRANSACTION
LIMIT 10;