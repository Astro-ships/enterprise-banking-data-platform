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
CREATE TABLE IF NOT EXISTS RAW_ACCOUNTS(
    RAW_RECORD VARIANT
);

-- ============================
-- Load data into accounts
-- ==========================

COPY INTO RAW_ACCOUNTS 
FROM @bank_stage/accounts.ndjson.gz
FILE_FORMAT=json_format;