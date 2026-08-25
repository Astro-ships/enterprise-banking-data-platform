-- ===============================
-- Configure Snowflake Session
-- ===============================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE BANKING;
USE SCHEMA BRONZE;

-- ===============================
-- Create Stream on Bronze
-- ===============================

CREATE OR REPLACE STREAM BANKING.BRONZE.BRONZE_TRANSACTION_STREAM
ON TABLE BANKING.BRONZE.BRONZE_TRANSACTIONS
APPEND_ONLY=TRUE
SHOW_INITIAL_ROWS=TRUE;
-- ===========================================
-- Verify Efficiency of the stream
-- ==========================================
------------------------------------------
SELECT SYSTEM$STREAM_HAS_DATA(
    'BANKING.BRONZE.BRONZE_TRANSACTION_STREAM'
);