-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- =====================================
-- Create HUB_TRANSACTIONS
-- =====================================
CREATE TABLE IF NOT EXISTS HUB_TRANSACTION
AS 
    SELECT 
        MD5(transaction_id)  AS transaction_hk,
        transaction_id,
        current_timestamp() AS load_date,
        'SILVER.SILVER_TRANSACTIONS' AS load_source
FROM SILVER.SILVER_TRANSACTIONS;

-- ===============================
-- Validate Table
-- ===============================
SELECT * FROM GOLD.HUB_TRANSACTION
LIMIT 500;