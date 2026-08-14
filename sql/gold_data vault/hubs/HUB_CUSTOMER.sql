-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- =====================================
-- Create HUB_CUSTOMER
-- =====================================
CREATE TABLE IF NOT EXISTS HUB_CUSTOMER 
AS 
    SELECT 
        MD5(customer_id)  AS customer_hk,
        customer_id,
        current_timestamp() AS load_date,
        'SILVER.SILVER_CUSTOMERS' AS load_source
FROM SILVER.SILVER_CUSTOMERS;
-- ===============================
-- Validate Table
-- ===============================
SELECT * FROM GOLD.HUB_CUSTOMER
LIMIT 500;