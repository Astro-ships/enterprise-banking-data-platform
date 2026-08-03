-- ===================================
-- Configure Snowflake Session 
-- ==================================
USE WAREHOUSE compute_wh;
USE DATABASE BANKING;
USE SCHEMA RAW;
-- ============================================
-- Create table using Snowflake Variant Feature
-- ============================================

CREATE TABLE IF NOT EXISTS RAW_CUSTOMERS(
    RAW_RECORD VARIANT
);

-- ============================
-- Load data into customers 
-- ==========================

COPY INTO RAW_CUSTOMERS  
FROM @bank_stage/customers.ndjson.gz
FILE_FORMAT=json_format;