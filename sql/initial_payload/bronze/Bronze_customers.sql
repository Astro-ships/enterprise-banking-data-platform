-- ==========================================================
-- Bronze Layer Transformation
-- ==========================================================
-- The RAW layer stores incoming semi-structured JSON data
-- using Snowflake VARIANT to preserve the original source
-- records and support schema evolution.
--
-- The Bronze layer extracts fields from VARIANT into strongly
-- typed columns to provide:
--   - consistent schemas for downstream processing
--   - improved query performance
--   - easier data quality validation
--   - clear data contracts between pipeline layers
--
-- This layer performs the initial parsing from semi-structured
-- JSON into relational tables while preserving the original
-- records in the RAW layer.
-- ==========================================================
-- ==================|
-- Configure Session
-- ==================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE BANKING;
USE SCHEMA BRONZE; 
-- =======================
-- Customers bronze table
-- =======================
CREATE OR REPLACE TABLE BRONZE.BRONZE_CUSTOMERS
AS 
SELECT 
        RAW_RECORD:customer_id::STRING AS customer_id,
        RAW_RECORD:first_name::STRING AS first_name,
        RAW_RECORD:last_name::STRING AS last_name,
        RAW_RECORD:date_of_birth::DATE AS date_of_birth,
        RAW_RECORD:country::STRING AS country,
        RAW_RECORD:city::STRING AS city,
        RAW_RECORD:address::STRING AS address,
        RAW_RECORD:postal_code::STRING AS postal_code,
        RAW_RECORD:email::STRING AS email,
        RAW_RECORD:phone_number::STRING AS phone_number,
        RAW_RECORD:customer_since::DATE AS customer_since
FROM RAW.RAW_CUSTOMERS;
-- ======================
-- Validate data
-- ====================
SELECT * FROM BRONZE_CUSTOMERS
LIMIT 5;

