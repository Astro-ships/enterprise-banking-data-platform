-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- =====================================
-- Create HUB_MERCHANT
-- =====================================
CREATE TABLE IF NOT EXISTS HUB_MERCHANT
AS 
    SELECT 
        MD5(MERCHANT_ID)  AS merchant_hk,
        merchant_id,
        current_timestamp() AS load_date,
        'SILVER.SILVER_MERCHANTS' AS load_source
FROM SILVER.SILVER_MERCHANTS;

-- ===============================
-- Validate Table
-- ===============================
SELECT * FROM GOLD.HUB_MERCHANT
LIMIT 500;