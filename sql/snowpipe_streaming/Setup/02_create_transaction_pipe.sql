-- ==============================
-- Snowflake Session
-- ==============================
 
 USE ROLE ACCOUNTADMIN;
 USE WAREHOUSE compute_wh;
 USE DATABASE BANKING;
 USE SCHEMA RAW_STREAMING;
 -- =========================================
 -- Confighure Snowflake Snowpipe Session
 -- ========================================

CREATE OR REPLACE PIPE BANKING.RAW_STREAMING.TRANSACTION_PIPE
AS
COPY INTO BANKING.RAW_STREAMING.TRANSACTIONS
    (PAYLOAD, INGESTED_AT)
FROM (
    SELECT
        $1:PAYLOAD,
        CURRENT_TIMESTAMP()
    FROM TABLE(
        DATA_SOURCE(TYPE => 'STREAMING')
    )
);

-- ======================
-- Verify snowpipe 
-- ======================

DESC PIPE RAW_STREAMING.TRANSACTION_PIPE;