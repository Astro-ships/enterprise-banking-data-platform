-- ===================================
-- Configure Snowflake Session 
-- ==================================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE BANKING;
USE SCHEMA RAW;
-- ============================================
-- Create table using Snowflake Variant Feature
-- ============================================

CREATE TABLE IF NOT EXISTS RAW_TRANSACTIONS(
    RAW_RECORD VARIANT
);

-- ============================
-- Load data into transactions 
-- ===========================

COPY INTO RAW_MERCHANTS 
FROM @bank_stage/transactions.ndjson.gz
FILE_FORMAT=json_format;