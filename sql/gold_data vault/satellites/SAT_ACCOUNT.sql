-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- ===========================================
-- Create SAT_ACCOUNT TABLE 
-- ==========================================
CREATE OR REPLACE TABLE  SAT_ACCOUNT
AS 
SELECT
        HB.account_hk,
        SA.ACCOUNT_NUMBER,
        SA.ACCOUNT_TYPE,
        SA.CURRENCY,
        SA.COUNTRY,
        SA.OPENING_DATE,
        SA.STATUS,
        SA.BALANCE,
        current_timestamp() AS LOAD_DATE,
        'SILVER.SILVER_ACCOUNTS' AS RECORD_SOURCE

FROM SILVER.SILVER_ACCOUNTS AS SA 
INNER JOIN HUB_ACCOUNT AS HB 
ON
SA.ACCOUNT_ID = HB.ACCOUNT_ID;
-- =========================
--  Validate
-- ===========================
SELECT * FROM 
SAT_ACCOUNT 
LIMIT 10;