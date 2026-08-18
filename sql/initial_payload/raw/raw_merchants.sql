--- ===================================
-- Configure Snowflake Session 
-- ==================================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE BANKING;
USE SCHEMA RAW;
-- ============================================
-- Create table using Snowflake Variant Feature
-- ============================================

CREATE OR REPLACE TABLE RAW_MERCHANTS(
    RAW_RECORD VARIANT
);

-- ============================
-- Load data into merchants 
-- ==========================
COPY INTO RAW_MERCHANTS  
FROM @bank_stage/merchants.ndjson.gz
FILE_FORMAT=json_format;