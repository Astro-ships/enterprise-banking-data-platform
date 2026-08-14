-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- ===================================
-- Create LINK_ACCOUNT_TRANSACTION
-- ====================================
-- ============================================================
-- NOTE:
-- SOURCE_ACCOUNT_ID and DESTINATION_ACCOUNT_ID both reference
-- the same business entity: an account. Therefore, both are
-- represented by HUB_ACCOUNT rather than creating separate
-- Hubs.
--
-- The current Link models the SOURCE_ACCOUNT_ID → TRANSACTION_ID
-- relationship. DESTINATION_ACCOUNT_ID remains available in the
-- Silver transaction data and can be modeled separately later
-- if the receiving-account role needs to be explicitly captured.
-- ============================================================
CREATE TABLE IF NOT EXISTS LINK_ACCOUNT_TRANSACTION
AS
SELECT 
    MD5(ST.SOURCE_ACCOUNT_ID || '|' || ST.TRANSACTION_ID) AS account_transaction_hk,
    HA.account_hk,
    HT.transaction_hk,
    current_timestamp() AS load_date,
    'SILVER.SILVER_TRANSACTIONS' AS record_source
FROM SILVER.SILVER_TRANSACTIONS AS ST
INNER JOIN HUB_ACCOUNT AS HA 
ON 
ST.SOURCE_ACCOUNT_ID = HA.account_id 
INNER JOIN HUB_TRANSACTION AS HT 
ON 
ST.TRANSACTION_ID = HT.TRANSACTION_ID;

-- ============================
-- Validate
-- ============================
SELECT * FROM LINK_ACCOUNT_TRANSACTION
LIMIT 10;