-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- =====================================
-- Create HUB_ACCOUNT
-- =====================================
CREATE TABLE IF NOT EXISTS HUB_ACCOUNT
AS 
    SELECT 
            MD5(account_id) AS  account_hk,
            account_id,
            current_timestamp() AS load_date,
            'SILVER.SILVER_ACCOUNTS' AS load_source
    FROM SILVER.SILVER_ACCOUNTS;
-- ===============================
-- Validate Table
-- ===============================
SELECT * FROM GOLD.HUB_ACCOUNT
LIMIT 500;
