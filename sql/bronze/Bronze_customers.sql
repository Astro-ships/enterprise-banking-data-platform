-- ==========================================================
-- Bronze Layer Transformation
-- ==========================================================
-- The RAW layer stores incoming JSON events using Snowflake
-- VARIANT to preserve the original source structure.
--
-- The Bronze layer intentionally converts VARIANT fields into
-- strongly typed columns to provide:
--   - consistent schemas for downstream transformations
--   - improved query performance
--   - easier data quality validation
--   - clearer data contracts
--
-- VARIANT is retained only in RAW to support schema evolution
-- and preserve the original ingested records.
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
(
    customer_id VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    date_of_birth DATE,
    country VARCHAR,
    city VARCHAR,
    address VARCHAR,
    postal_code VARCHAR,
    email VARCHAR,
    phone_number VARCHAR,
    customer_since DATE
);
-- ===========================================
-- Insert values into bronze.bronze_customers
-- ==========================================
INSERT INTO BRONZE.BRONZE_CUSTOMERS
SELECT
    RAW_RECORD['customer_id']::VARCHAR,
    RAW_RECORD['first_name']::VARCHAR,
    RAW_RECORD['last_name']::VARCHAR,
    TRY_TO_DATE(RAW_RECORD['date_of_birth']::VARCHAR),
    RAW_RECORD['country']::VARCHAR,
    RAW_RECORD['city']::VARCHAR,
    RAW_RECORD['address']::VARCHAR,
    RAW_RECORD['postal_code']::VARCHAR,
    RAW_RECORD['email']::VARCHAR,
    RAW_RECORD['phone_number']::VARCHAR,
    TRY_TO_DATE(RAW_RECORD['customer_since']::VARCHAR)
FROM RAW.RAW_CUSTOMERS;
-- ======================
-- Validate data
-- ====================
SELECT * FROM BRONZE_CUSTOMERS
LIMIT 5;

-- ==========================================================
-- Development Note
-- ==========================================================
-- During development, the customer Bronze transformation
-- exhibited inconsistent behavior when using CTAS directly
-- from the VARIANT column, while the same approach worked
-- correctly for the other entities (Accounts, Merchants,
-- Transactions).
--
-- The Bronze schema remains identical to the intended design.
-- This implementation is temporary and will be revisited while
-- investigating the underlying cause.
-- ==========================================================