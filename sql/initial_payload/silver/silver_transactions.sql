-- ======================
--  Snowlfake Session 
-- ======================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA SILVER; 
-- ==============================================================================================
--                              Data Profiling 
-- ==============================================================================================
-- Before jumping into data profiling inspect table columns and the datatype
-- it has stored.
DESC TABLE BRONZE.BRONZE_transactions;
-- ===================
-- 1: TRANSACTIONS_ID
-- ===================
-- 1: Check NULLS 
SELECT COUNT(*) AS TOTAL_NULLS
FROM BRONZE.BRONZE_TRANSACTIONS
WHERE TRANSACTION_ID IS NULL;
-- ----------------------
-- Expected result: None
-- ---------------------
-- 2:Duplicates 
-- ------------
SELECT 
COUNT(*) AS TOTAL_TRANSACTION_IDs,
COUNT(DISTINCT transaction_id) AS UNIQUE_TRANSACTION_IDs 
FROM BRONZE.BRONZE_TRANSACTIONS;
-- ---------------------
-- Expected Result: None
-- ---------------------
-- =========================
-- 2: SOURCE_ACCOUNT_ID
-- ========================= 
-- Check Nulls 
SELECT COUNT(*) AS total_Nulls
FROM BRONZE.BRONZE_TRANSACTIONS
WHERE SOURCE_ACCOUNT_ID IS NULL;
-- ---------------------------
-- Expected Result: None 
-- ---------------------------
-- 2: Duplicates 
-- -------------------------------------------------
-- Duplicates are suppose to be present as 
-- an account can perform more than one transactions.
-- ----------------------------------------------------

-- =====================================
-- 3: DESTINATION_ACCOUNT_ID
-- =====================================
-- 1: Check Nulls 
SELECT COUNT(*) AS total_Nulls
FROM BRONZE.BRONZE_TRANSACTIONS
WHERE DESTINATION_ACCOUNT_ID IS NULL;
-- ----------------------------------------------------------------
-- Expected result: Nulls present. T
-- Transactions can have no destination account id as 
-- some transactions might be to a merchant or an Atm withdrawal.
-- It can be confirmed by the following queries.
-- ---------------------------------------------------------------
SELECT  TRANSACTION_ID,MERCHANT_ID,TRANSACTION_TYPE
FROM BRONZE.BRONZE_TRANSACTIONS
WHERE DESTINATION_ACCOUNT_ID IS NULL;
-- ---------------------------------------
SELECT 
(SELECT COUNT(*) 
FROM BRONZE.BRONZE_TRANSACTIONS
WHERE DESTINATION_ACCOUNT_ID IS NULL) AS TOTAL_NULL_ROWS,
(SELECT COUNT(*)
FROM BRONZE.BRONZE_TRANSACTIONS
WHERE TRANSACTION_TYPE LIKE 'ATM%'
OR TRANSACTION_TYPE ='PURCHASE')  AS TOTAL_PURHCASES_AND_WITHDRAWALS;
-- ------------------------------------------------------------------------------------------------------
-- Flagged. for QoL transformation
-- RESULT: Query 1 gave us the what type of transactions have null destination Accounts.
--        Query 2 solidifies the earlier statements by matching both the Nulls and transaction_type counts
---------------------------------------------------------------------------------------------------------
-- =========================
-- 4: Merchant_id
-- ========================+
--1: Check Nulls
SELECT COUNT(*) AS total_null_rows 
FROM BRONZE.BRONZE_TRANSACTIONS 
WHERE MERCHANT_ID IS NULL;
-- -----------------------
-- Expected Result: Null rows found 
-- -------------------------------
-- Inspect the cause of Nulls
SELECT TRANSACTION_TYPE 
FROM BRONZE.BRONZE_TRANSACTIONS 
WHERE MERCHANT_ID IS NULL; 

SELECT 
(SELECT COUNT(*) FROM BRONZE.BRONZE_TRANSACTIONS WHERE MERCHANT_ID IS NULL) AS Total_merchant_nulls,
(SELECT COUNT(*) FROM BRONZE.BRONZE_TRANSACTIONS WHERE TRANSACTION_TYPE <> 'PURCHASE' ) AS total_atm_or_transfer_transactions;
-- --------------------------------------------------------------
-- Note: (FLagged for transformation)
-- Every Transaction_type is either a transfer or Atm withdrawal 
-- so nulls are supposed to be present if transaction_type is not 
-- a 'PURCHASE'. It can be further confirmed by using the follow-
-- -ing query.
-- -------------------------------------------------------------
SELECT COUNT(*) AS total_nulls 
FROM BRONZE.BRONZE_TRANSACTIONS 
WHERE MERCHANT_ID IS NULL AND 
TRANSACTION_TYPE = 'PURCHASE';

-- Expected Result : 0
-- -----------------------------------------------------------
-- ================================
-- 5: AMOUNT 
-- ===============================
-- 1: Check Nulls 
SELECT COUNT(*) AS total_nulls 
FROM BRONZE.BRONZE_TRANSACTIONS 
WHERE AMOUNT IS NULL;
-- 2: Check for negative balance 
SELECT COUNT(*) AS total_negative_balance_rows 
FROM BRONZE.BRONZE_TRANSACTIONS 
WHERE AMOUNT < 0;
-- Expected result = 0 ;
-- ----------------------------------------------------------
-- =========================
-- 6:CURRENCY
-- =========================
-- 1: CHECK NULLS 
SELECT COUNT(*) AS total_nulls 
FROM BRONZE.BRONZE_TRANSACTIONS 
WHERE CURRENCY IS NULL;
-- 2: Inspect data 
SELECT DISTINCT CURRENCY 
FROM BRONZE.BRONZE_TRANSACTIONS;
-- -----------------------------
-- Flagged:
-- unstandardized data FOUND 
-- -----------------------------
-- ===============================
-- 7: TRANSACTION_TYPE
-- ==============================
-- 1:Check Nulls 
SELECT COUNT(*) AS total_Null_values 
FROM BRONZE.BRONZE_TRANSACTIONS
WHERE TRANSACTION_TYPE IS NULL;
-- 2: Inspect 
SELECT DISTINCT TRANSACTION_TYPE 
FROM BRONZE.BRONZE_TRANSACTIONS;
-- ---------------------------------------
-- Expected results: Standardized  data 
-- --------------------------------------
-- =================================
-- 8: TRANSACTION_TIMESTAMP
-- =================================
-- 1: CHECK FOR NULLS 
SELECT COUNT(*) AS total_Null_values 
FROM BRONZE.BRONZE_TRANSACTIONS
WHERE TRANSACTION_TIMESTAMP IS NULL;
-- Expected Results: None.
-- =================================
-- 9: STATUS
-- =================================
-- 1: Check for Nulls 
SELECT COUNT(*) AS total_Null_values 
FROM BRONZE.BRONZE_TRANSACTIONS
WHERE STATUS IS NULL;
-- inspect data 
SELECT DISTINCT STATUS 
FROM BRONZE.BRONZE_TRANSACTIONS;

-- ----------------------------
-- Flagged:
-- Unstardardized data found
-- ----------------------------
-- ============================================================
-- Data Profiling Summary
-- ============================================================
-- ✓ No duplicate or null values found in transaction_id.
-- ✓ source_account_id contains no null values.
-- ✓ destination_account_id nulls are expected for PURCHASE
--   and ATM_WITHDRAWAL transactions.
-- ⚠ merchant_id nulls are expected for TRANSFER and
--   ATM_WITHDRAWAL transactions.
-- ✓ Amount column contains no null or negative values.
-- ⚠ Currency column contains unstandardized values and
--   requires standardization during the Silver transformation.
-- ✓ transaction_type contains no nulls and is already
--   standardized.
-- ✓ transaction_timestamp contains no null values.
-- ⚠ Status column contains unstandardized values and
--   requires standardization during the Silver transformation.
--
-- Overall Assessment:
-- The dataset has strong structural integrity. The only
-- transformations required are standardizing the Currency
-- and Status columns. All identified null values are valid
-- according to the business rules of the transaction model.
-- ============================================================
--      DATA TRANSFORMATION
-- ============================================================
-- ===========================================
-- Create surrogate_keys_for transaction_id
-- =========================================
CREATE OR REPLACE SEQUENCE Silver.transaction_key_seq
START=1
INCREMENT=1;
CREATE OR REPLACE TABLE SILVER.TRANSACTIONS_SURROGATE
AS 
    SELECT 
        transaction_key_seq.NEXTVAL AS transaction_key,
        transaction_id 
    FROM BRONZE.BRONZE_TRANSACTIONS;
-- 1:Currency
-- CREATE a lookup table 
CREATE OR REPLACE TABLE SILVER.ACCOUNT_CURRENCY_LOOKUP(
    incorrect_value VARCHAR,
    correct_value VARCHAR
) ;
INSERT INTO SILVER.ACCOUNT_CURRENCY_LOOKUP (incorrect_value,correct_value)
VALUES
      ('Malaysian Ringgit','MYR'),
      ('U.S. Dollar','USD'),
      ('Pakistani Rupee','PKR'),
      ('gbp','GBP'),
      ('US Dollar','USD'),
      ('usd','USD'),
      ('Gbp','GBP'),
      ('British Pound','GBP'),
      ('Pak Rupee','PKR'),
      ('pkr','PKR'),
      ('Indian Rupee','INR');

-- use lookup table to remove unstardardize data 
SELECT DISTINCT COALESCE(
                CL.CORRECT_VALUE,BT.CURRENCY) AS currency 
FROM BRONZE.BRONZE_TRANSACTIONS AS BT 
LEFT JOIN SILVER.ACCOUNT_CURRENCY_LOOKUP AS CL 
ON
BT.currency = cl.INCORRECT_VALUE;

-- ========================
-- 2:Status 
-- ========================
SELECT DISTINCT STATUS FROM BRONZE.BRONZE_TRANSACTIONS;
-- Create a lookup table 
CREATE OR REPLACE TABLE SILVER.STATUS_LOOKUP 
(
    incorrect_value VARCHAR,
    correct_value VARCHAR 
);
INSERT INTO SILVER.STATUS_LOOKUP(incorrect_value,correct_value)
VALUES
        ('penDing','Pending'),
        (' penDing','Pending'),('success','Success'),('pending','Pending'),
        ('failed','Failed'),('reversed','Reversed'),('SucESs','Success');
-- use lookup table to remove unstardardize data 
SELECT DISTINCT 
        COALESCE(SL.correct_value,TRIM(BT.STATUS)) AS STATUS
FROM BRONZE.BRONZE_TRANSACTIONS AS BT 
LEFT JOIN SILVER.STATUS_LOOKUP AS SL 
ON 
TRIM(BT.STATUS)=SL.incorrect_value;

-- ==========================
-- 3: MERCHANT_Id
-- ==========================
-- Rectify merchant_id Nulls 

SELECT COALESCE(merchant_id,'NOT_APPLICABLE')
FROM BRONZE.BRONZE_TRANSACTIONS
LIMIT 100;

-- ==========================
-- 4: Destination_account_id
-- ==========================
-- Rectify destination_account_id
--  Nulls 
SELECT COALESCE(destination_account_id,'NOT_APPLICABLE')
FROM BRONZE.BRONZE_TRANSACTIONS
LIMIT 100;

-- ==========================================================
-- CREATE TABLE 
-- ==========================================================
CREATE OR REPLACE TABLE SILVER.silver_transactions 
AS 
    SELECT 
            BT.TRANSACTION_ID,
            BT.SOURCE_ACCOUNT_ID,
   COALESCE(BT.DESTINATION_ACCOUNT_ID,'NOT_APPLICABLE') AS DESTINATION_ACCOUNT_ID,
   COALESCE(BT.MERCHANT_ID,'NOT_APPLICABLE') AS MERCHANT_ID,
            BT.AMOUNT,
   COALESCE(CL.CORRECT_VALUE,BT.CURRENCY) AS CURRENCY,
            BT.TRANSACTION_TYPE,
            TRANSACTION_TIMESTAMP,
    COALESCE(SL.CORRECT_VALUE,TRIM(BT.STATUS)) AS STATUS
    FROM BRONZE.BRONZE_TRANSACTIONS AS BT
    
    LEFT JOIN SILVER.ACCOUNT_CURRENCY_LOOKUP AS CL
    ON 
    BT.currency = cl.INCORRECT_VALUE
    LEFT JOIN SILVER.STATUS_LOOKUP AS SL
    ON
    TRIM(BT.STATUS) = SL.INCORRECT_VALUE;

    -- ==============================================================
    --  Validate table 
    -- ==============================================================
    -- 1: ROW_COUNT 
    SELECT
        (SELECT COUNT(*) FROM BRONZE.BRONZE_TRANSACTIONS) AS Bronze_count,
        (SELECT COUNT(*) FROM SILVER.SILVER_TRANSACTIONS) AS SILVER_count;
    -- --------------------
    SELECT * FROM SILVER_TRANSACTIONS
    LIMIT 10;