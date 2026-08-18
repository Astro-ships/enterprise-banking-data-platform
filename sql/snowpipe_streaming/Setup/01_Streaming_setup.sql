-- ===============================
-- Configure Snowflake Session
-- ===============================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE BANKING;
CREATE SCHEMA RAW_STREAMING;
USE SCHEMA RAW_STREAMING;
-- ================================
-- Create Streaming Landing Table
-- ===============================
CREATE TABLE IF NOT EXISTS RAW_STREAMING.TRANSACTIONS ( 
    PAYLOAD VARIANT,
    INGESTED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- Verify Table Definition
-- ==============================
DESC TABLE BANKING.RAW_STREAMING.TRANSACTIONS;