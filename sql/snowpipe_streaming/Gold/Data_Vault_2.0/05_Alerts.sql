-- ================================================================
-- SUSPICIOUS TRANSACTION ALERT
-- Detect newly inserted transactions with amount >= 100,000
-- ================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE BANKING;
USE SCHEMA GOLD;


-- ================================================================
-- 1. ENABLE CHANGE TRACKING
-- ================================================================

ALTER TABLE BANKING.GOLD.SAT_TRANSACTION
SET CHANGE_TRACKING = TRUE;


-- ================================================================
-- 2. CREATE ALERT LOG TABLE
-- ================================================================

CREATE TABLE IF NOT EXISTS BANKING.GOLD.SUSPICIOUS_TRANSACTION_ALERT_LOG (
    TRANSACTION_HK          VARCHAR(32),
    SOURCE_ACCOUNT_ID       VARCHAR,
    DESTINATION_ACCOUNT_ID  VARCHAR,
    MERCHANT_ID             VARCHAR,
    AMOUNT                  FLOAT,
    CURRENCY                VARCHAR,
    TRANSACTION_TYPE        VARCHAR,
    TRANSACTION_TIMESTAMP   TIMESTAMP_NTZ,
    STATUS                  VARCHAR,
    DETECTED_AT             TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);


-- ================================================================
-- 3. CREATE ALERT ON NEW DATA
-- ================================================================
--
-- The alert fires only when new rows are inserted into
-- SAT_TRANSACTION.
--
-- The condition checks the new rows for:
--
--     AMOUNT >= 100000
--
-- RESULT_SCAN(GET_CONDITION_QUERY_UUID())
-- retrieves the rows returned by the alert condition so that
-- those suspicious rows can be written to the alert log.
--
-- ================================================================

CREATE OR REPLACE ALERT BANKING.GOLD.SUSPICIOUS_TRANSACTION_ALERT
    WAREHOUSE = COMPUTE_WH

IF (
    EXISTS (
        SELECT
            TRANSACTION_HK,
            SOURCE_ACCOUNT_ID,
            DESTINATION_ACCOUNT_ID,
            MERCHANT_ID,
            AMOUNT,
            CURRENCY,
            TRANSACTION_TYPE,
            TRANSACTION_TIMESTAMP,
            STATUS
        FROM BANKING.GOLD.SAT_TRANSACTION
        WHERE AMOUNT >= 100000
    )
)

THEN
    INSERT INTO BANKING.GOLD.SUSPICIOUS_TRANSACTION_ALERT_LOG (
        TRANSACTION_HK,
        SOURCE_ACCOUNT_ID,
        DESTINATION_ACCOUNT_ID,
        MERCHANT_ID,
        AMOUNT,
        CURRENCY,
        TRANSACTION_TYPE,
        TRANSACTION_TIMESTAMP,
        STATUS
    )
    SELECT
        TRANSACTION_HK,
        SOURCE_ACCOUNT_ID,
        DESTINATION_ACCOUNT_ID,
        MERCHANT_ID,
        AMOUNT,
        CURRENCY,
        TRANSACTION_TYPE,
        TRANSACTION_TIMESTAMP,
        STATUS
    FROM TABLE(
        RESULT_SCAN(
            SNOWFLAKE.ALERT.GET_CONDITION_QUERY_UUID()
        )
    );

-- ================================================================
-- 4. RESUME ALERT
-- ================================================================
--
-- Alerts are suspended when created.
--
-- ================================================================

ALTER ALERT BANKING.GOLD.SUSPICIOUS_TRANSACTION_ALERT RESUME;
-- ===============================================================
-- Inspect the log table for suspicious transactions
-- ===============================================================

SELECT * FROM BANKING.GOLD.SUSPICIOUS_TRANSACTION_ALERT_LOG;

-- ================================================================
--  to clear log history
-- ================================================================
TRUNCATE TABLE BANKING.GOLD.SUSPICIOUS_TRANSACTION_ALERT_LOG;

--- =================================================
-- Email Notifications Can also be implemented 
-- ==================================================

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE NOTIFICATION INTEGRATION SUSPICIOUS_TRANSACTION_EMAIL
    TYPE = EMAIL
    ENABLED = TRUE
    DEFAULT_RECIPIENTS = ('your_verified_email@example.com')
    DEFAULT_SUBJECT = '🚨 Suspicious Banking Transaction Detected';