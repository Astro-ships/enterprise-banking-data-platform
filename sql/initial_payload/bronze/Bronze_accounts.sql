-- =============================
-- Configure Snowflake Session 
-- ============================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE BANKING;
USE SCHEMA BRONZE;
-- =========================
-- CREATE BRONZE TABLE 
-- =========================
CREATE OR REPLACE TABLE BRONZE.BRONZE_ACCOUNTS 
AS 
SELECT 
        RAW_RECORD:account_id::STRING AS account_id,
        RAW_RECORD:customer_id::STRING AS customer_id,
        RAW_RECORD:account_number::STRING AS account_number,
        RAW_RECORD:account_type::STRING AS account_type,
        RAW_RECORD:currency::STRING AS currency,
        RAW_RECORD:country::STRING AS country,
        RAW_RECORD:opening_date::DATE AS opening_date,
        RAW_RECORD:status::STRING AS status,
        RAW_RECORD:balance::FLOAT AS balance
FROM RAW.RAW_ACCOUNTS;
-- ==============================
-- Validate table
-- ============================
SELECT * FROM bronze_accounts limit 5;