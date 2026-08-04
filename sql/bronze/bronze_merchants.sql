-- ===========================
-- Configure Snowflake Session
-- ===========================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE BANKING;
USE SCHEMA BRONZE;
-- ===========================
--  Create table
-- ===========================

CREATE OR REPLACE TABLE BRONZE.bronze_merchants
AS 
SELECT 
        RAW_RECORD:merchant_id::STRING AS merchant_id,
        RAW_RECORD:merchant_name::STRING AS merchant_name,
        RAW_RECORD:country::STRING AS country,
        RAW_RECORD:city::STRING AS city
FROM RAW.RAW_MERCHANTS;
-- =========================
--  Validate table
-- =========================
SELECT * FROM BRONZE.BRONZE_MERCHANTS
LIMIT 5;
