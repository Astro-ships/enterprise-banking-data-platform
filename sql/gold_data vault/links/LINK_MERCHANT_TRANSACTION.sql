-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- ===========================================================
-- Create Link: Merchant ↔ Transaction
-- ===========================================================
-- This Link represents the existing relationship between a
-- transaction and a merchant. The relationship is sourced
-- from SILVER_TRANSACTIONS and connected to the corresponding
-- Merchant and Transaction Hubs.
--
-- Transactions without a merchant are excluded because
-- NOT_APPLICABLE indicates that the transaction does not
-- involve a merchant, such as transfers or ATM withdrawals.
-- ===========================================================

CREATE OR REPLACE TABLE GOLD.LINK_MERCHANT_TRANSACTION
AS
    SELECT 
            MD5(ST.TRANSACTION_ID || '|'|| HM.MERCHANT_ID) AS Link_merchant_transaction,
            HT.transaction_hk,
            HM.merchant_hk,
            current_timestamp() AS load_date,
            'SILVER_TRANSACTIONS' AS record_source
    FROM SILVER.SILVER_TRANSACTIONS AS ST 
    INNER JOIN HUB_MERCHANT AS HM 
    ON 
    ST.MERCHANT_ID=HM.MERCHANT_ID
    INNER JOIN hub_transaction AS HT 
    ON
    ST.TRANSACTION_ID = HT.TRANSACTION_ID
    WHERE ST.merchant_ID IS NOT NULL AND
    ST.MERCHANT_ID <> 'NOT_APPLICABLE';


-- ============================================
-- Validate 
-- ============================================
-- Compare the number of valid merchant relationships in the
-- Silver transaction data with the number of records created
-- in the Link. Matching counts confirm that all eligible
-- merchant relationships were successfully captured.
-- ===========================================================
-- 1:Count rows 
SELECT
        (SELECT COUNT (*) FROM SILVER.SILVER_TRANSACTIONS WHERE merchant_id IS NOT NULL AND merchant_id <> 'NOT_APPLICABLE') AS silver_merchant_count,
        (SELECT COUNT(*) FROM GOLD.LINK_MERCHANT_TRANSACTION) AS Link_merchant_transaction_count;

-- Expected result:
-- Silver merchant count = Link merchant transaction count


-- ===========================================================
-- Inspect Link Records
-- ===========================================================
-- Review a sample of the generated Link records to verify
-- that transaction and merchant Hub keys are correctly
-- associated with the relationship.
-- ===========================================================
SELECT *
FROM GOLD.LINK_MERCHANT_TRANSACTION
LIMIT 10;