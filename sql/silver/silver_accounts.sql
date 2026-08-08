-- ==========================================================================================================================================================================
--                                                              Configure Snowflake Session
-- ==========================================================================================================================================================================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA SILVER;
-- ==========================================================================================================================================================================
--                                                                      Data Profiling
-- ==========================================================================================================================================================================
-- > Inspect table and its data type
DESC TABLE BRONZE.BRONZE_ACCOUNTS;

-- =====================================
-- 1: Account_id
-- =====================================
--  Check nulls
-- --------------
SELECT COUNT(*) AS total_nulls          
FROM BRONZE.BRONZE_ACCOUNTS             
WHERE account_id IS NULL; 
-------------------
-- Expected Result:
-- No nulls found  
------------------            
-- -------------
-- Duplicates
-- ------------
SELECT
     COUNT(*) AS total_ids,
     COUNT(DISTINCT account_id) AS unique_ids 
FROM BRONZE.BRONZE_ACCOUNTS;
-- =============================
-- 2:Customer_id:
-- ============================
-- Check Nulls
-- --------------
SELECT COUNT(*) AS total_nulls          
FROM BRONZE.BRONZE_ACCOUNTS             
WHERE CUSTOMER_ID IS NULL; 
-------------------
-- Expected Result:
-- No nulls found  
------------------
-- -------------
-- Duplicates
-- ----------------------------------------------------------------------
-- Duplicates are expected  as one customer can have more than 1 account
-- --------------------------------------------------------------------
-- ========================
-- 3: ACCOUNT_NUMBER
-- ========================
-- Check Nulls
-- ----------
SELECT COUNT(*) AS total_nulls          
FROM BRONZE.BRONZE_ACCOUNTS             
WHERE account_number IS NULL; 
-- --------------------
-- Duplicates 
-- --------------------
SELECT
     COUNT(*) AS total_accounts,
     COUNT(DISTINCT account_number) AS unique_accounts 
FROM BRONZE.BRONZE_ACCOUNTS;
-------------------
-- No duplicates 
-- =======================
-- 4: ACCOUNT_TYPE
-- =======================
-- Inspect
SELECT DISTINCT ACCOUNT_TYPE
FROM BRONZE.BRONZE_ACCOUNTS;
-- ---------------------------------------------
-- Result:
-- flagged: Unstardardized data and nulls found.
-- ---------------------------------------------
-- ====================
-- 5: CURRENCY
-- ==================== 
-- Inspect 
SELECT DISTINCT CURRENCY
FROM BRONZE.BRONZE_ACCOUNTS;
-- ---------------------------------------------
-- Result:
-- flagged: Unstardardized data and nulls found.
-- ---------------------------------------------
-- ====================
-- 6: COUNTRY
-- ====================
-- Inspect 
SELECT DISTINCT COUNTRY
FROM BRONZE.BRONZE_ACCOUNTS;
-- ---------------------------------------------
-- Result:
-- Standardized data with no nulls found
-- ---------------------------------------------
-- ====================
-- 7: OPENING_DATE
-- ====================
-- Check Nulls
-- --------------
SELECT COUNT(*) AS total_nulls          
FROM BRONZE.BRONZE_ACCOUNTS             
WHERE OPENING_DATE IS NULL;
-------------------
-- Expected Result:
-- No nulls found  
------------------
 -- ====================
-- 8: STATUS
-- ====================
-- Inspect
SELECT DISTINCT STATUS 
FROM BRONZE.BRONZE_ACCOUNTS;
-- ---------------------------------------------
-- Result:
-- flagged: Unstardardized data and nulls found.
-- ---------------------------------------------
 -- ====================
-- 9: BALANCE
-- ===========================
-- Check for Negative balance.
-- ---------------------------
SELECT COUNT(*) AS total_negative_balance 
FROM BRONZE.BRONZE_ACCOUNTS
WHERE BALANCE < 0;
-- No negative Balance found
----------------------------
-- Check Nulls
-- ----------
SELECT COUNT(*) AS total_negative_balance 
FROM BRONZE.BRONZE_ACCOUNTS
WHERE BALANCE IS  NULL;
-- No nulls found.

-- ==========================================================
-- Data Profiling Summary
-- ----------------------------------------------------------
-- account_id
--   • No nulls
--   • No duplicates
--
-- customer_id
--   • No nulls
--   • Duplicate values expected (one customer can own
--     multiple accounts)
--
-- account_number
--   • No nulls
--   • No duplicates
--
-- account_type
--   • Inconsistent formatting detected
--   • Null values detected
--
-- currency
--   • Inconsistent formatting detected
--   • Null values detected
--
-- country
--   • Standardized
--   • No nulls
--
-- opening_date
--   • No nulls
--
-- status
--   • Inconsistent formatting detected
--   • Null values detected
--
-- balance
--   • No nulls
--   • No negative balances
--
-- ----------------------------------------------------------
-- Planned Silver Transformations
-- ----------------------------------------------------------
-- • Standardize account_type values
-- • Standardize currency values
-- • Standardize status values
-- • Handle null values in account_type and status
-- • Preserve account_id as the business key
-- ==========================================================

-- ==================================================================================================================================================
--                                                                  TRANSFORMATION
-- ==================================================================================================================================================
---------------------------------------
-- 1: Standardize Account_type Values 
---------------------------------------
-- Create a lookup table 
CREATE OR REPLACE TABLE SILVER.ACCOUNT_lookup (
    incorrect_value VARCHAR,
    correct_value VARCHAR
);
INSERT INTO SILVER.ACCOUNT_lookup (incorrect_value,correct_value)
VALUES

('saving','Savings'),
('Saving','Savings'),
('CURRENT','Current'),
('curreng','current'),
('CUrentg','current'),
('Curentg','Current'),
('Curreng','Current');

SELECT DISTINCT
    COALESCE(
    COALESCE(AL.CORRECT_VALUE,INITCAP(TRIM(LOWER(BA.ACCOUNT_TYPE)))),'Undefined'
    )
FROM BRONZE.BRONZE_ACCOUNTS AS BA 
LEFT JOIN SILVER.ACCOUNT_lookup AS AL 
ON 
INITCAP(TRIM(LOWER(BA.ACCOUNT_TYPE)))=AL.INCORRECT_VALUE;
-- Investigating Nulls 
SELECT STATUS,BALANCE,ACCOUNT_NUMBER,Account_type
FROM BRONZE.BRONZE_ACCOUNTS
WHERE ACCOUNT_TYPE IS NULL;
-- Note:
-- Most of the status of accounts are frozen or dormant, or have zero balance. 
-- We have to first standardize status to fix the nulls.
-- Further Improve upon this in table creation section.
-- --------------------------------------------------------
-- 3: Standardize currency values
-- ------------------------------------------------------

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

---------------------
SELECT DISTINCT
      COALESCE(CL.CORRECT_VALUE,TRIM(BA.CURRENCY)) AS  CURRENCY
FROM BRONZE.BRONZE_ACCOUNTS AS BA 
LEFT JOIN SILVER.ACCOUNT_CURRENCY_LOOKUP AS CL 
ON
TRIM(BA.CURRENCY)=CL.INCORRECT_VALUE;
-- -------------------------------------------------
-- 4: Standatdize Status 
-- ------------------------------------------------
CREATE OR REPLACE TABLE SILVER.ACCOUNT_STATUS_LOOKUP 
(incorrect_value VARCHAR ,
correct_value VARCHAR);
INSERT INTO SILVER.ACCOUNT_STATUS_LOOKUP (incorrect_value,correct_value)
VALUES 
      ('ACT','Active'),
      ('non-active','Dormant'),
      ('DORMANT','Dormant'),
      ('closed','Closed'),
      ('Non-Active','Dormant'),
      ('frozen','Frozen'),
      ('Act','Active'),
      ('active','Active'),
      ('ACTIVE','Active'),
      ('CLOSED','Closed'),
      ('FROZEN','Frozen'),
      ('dormant','Dormant');
-- -------------------------------------------------------
-- Now standardize data and replace Nulls with 'undefined'.
-- -------------------------------------------------------
SELECT DISTINCT
    COALESCE(
            COALESCE(SL.CORRECT_VALUE,TRIM(BA.STATUS)),'undefined'
    ) AS status
FROM BRONZE.BRONZE_ACCOUNTS AS BA 
LEFT JOIN SILVER.ACCOUNT_STATUS_LOOKUP AS SL
ON 
TRIM(BA.STATUS)=SL.INCORRECT_VALUE;

-- ================================
-- Create Table 
-- ================================
CREATE OR REPLACE TABLE SILVER.SILVER_ACCOUNTS
AS 
SELECT 
        ACCOUNT_ID,
        CUSTOMER_ID,
        ACCOUNT_NUMBER,
 COALESCE(
        COALESCE(AL.CORRECT_VALUE,INITCAP(TRIM(LOWER(BA.ACCOUNT_TYPE)))),'Undefined'
    ) AS ACCOUNT_TYPE,
        COALESCE(CL.CORRECT_VALUE,TRIM(BA.CURRENCY)) AS  CURRENCY,
        COUNTRY,
        OPENING_DATE,
    COALESCE(
        COALESCE(SL.CORRECT_VALUE,TRIM(BA.STATUS)),'undefined'
    ) AS STATUS,
        BALANCE
FROM BRONZE.BRONZE_ACCOUNTS AS BA 
LEFT JOIN SILVER.ACCOUNT_STATUS_LOOKUP AS SL 
ON
TRIM(BA.STATUS)=SL.INCORRECT_VALUE
LEFT JOIN SILVER.ACCOUNT_lookup AS AL 
ON 
INITCAP(TRIM(LOWER(BA.ACCOUNT_TYPE)))=AL.INCORRECT_VALUE
LEFT JOIN SILVER.ACCOUNT_CURRENCY_LOOKUP AS CL 
ON
TRIM(BA.CURRENCY)=CL.INCORRECT_VALUE;

 -- ======================================
 -- Validate 
 -- ======================================
 -- CHECK ROW COUNTS
 SELECT 
        (SELECT COUNT(*) FROM BRONZE.BRONZE_ACCOUNTS) AS Bronze_count,
        (SELECT COUNT(*) FROM SILVER.SILVER_ACCOUNTS) AS Silver_count;
-- ---------------
SELECT * FROM SILVER_ACCOUNTS
LIMIT 10;