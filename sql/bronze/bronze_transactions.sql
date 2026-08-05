-- ==========================
-- Snowflake Session
-- ==========================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA BRONZE;
-- ====================
-- Create Table
-- ==================
CREATE OR REPLACE TABLE BRONZE.bronze_transactions 
AS 
    SELECT 
            RAW_RECORD:transactions_id::STRING AS transactions_id,
            RAW_RECORD:source_account_id::STRING AS source_account_id,
            RAW_RECORD:destination_account_id::STRING AS destination_account_id,
            RAW_RECORD:merchant_id::STRING AS merchant_id,
            RAW_RECORD:amount::FLOAT AS amount,
            RAW_RECORD:currency::STRING AS currency,
            RAW_RECORD:transaction_type::STRING AS transaction_type,
            RAW_RECORD:transaction_timestamp::datetime AS transaction_timestamp,
            RAW_RECORD:status::STRING AS status
FROM RAW.RAW_TRANSACTIONS;

-- ================
-- Validate table
-- =============== 
SELECT * FROM bronze_transactions
LIMIT 5;