-- ======================
--  Snowlfake Session 
-- ======================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA SILVER; 
-- ==========================================================================
-- Data Profiling 
-- ==========================================================================
-- Before jumping into data profiling inspect table columns and the datatype
-- it has stored.
DESC TABLE BRONZE.BRONZE_CUSTOMERS;

-- Data Profiling Summary
-- ----------------------
-- Duplicate rows        : None
-- Duplicate customer_id : None
-- Null values           : None
-- Postal code issues    : 505 (0.5%)
-- Phone formatting      : Inconsistent
 
-- ===========================
-- 1: Check for Duplicate data 
-- ---------------------------
SELECT 
        COUNT(*) AS TOTAL_ROWS,
        (SELECT 
                COUNT(*) 
        FROM (SELECT DISTINCT  CUSTOMER_ID,
                                FIRST_NAME,
                                LAST_NAME,
                                DATE_OF_BIRTH,
                                COUNTRY,
                                CITY,
                                ADDRESS,
                                POSTAL_CODE,
                                EMAIL,
                                PHONE_NUMBER,
                                CUSTOMER_SINCE
                                FROM BRONZE.BRONZE_CUSTOMERS)) AS unique_rows
FROM BRONZE.BRONZE_CUSTOMERS;

-- Result: No duplicates found 

-- ------------------------------------
-- 2: Check For duplicates in customer_id 
-- ------------------------------------
SELECT  
COUNT(*) AS TOTAL_IDS,
COUNT(DISTINCT customer_id) AS total_unique_ids 
FROM BRONZE.BRONZE_CUSTOMERS;

-- No duplicates 
-- =================================================================
-- 3: Inspect columns for Nulls
-- =================================================================
-- put each column name in place of <column name to check for Nulls>
SELECT 
    COUNT(*) AS total_Nulls
FROM bronze.bronze_customers
WHERE <column_name> IS NULL;

-- Expected Result : No nulls
-- -------------------------- 
-- Inspect country and city 
-- -------------------------

SELECT DISTINCT 
                COUNTRY,
                CITY 
FROM BRONZE.BRONZE_CUSTOMERS;
-- --------------------------------------
-- Expected Result: Values - Standardized 
-- --------------------------------------
-- 4: Inspect postal code 
-- -------------------------------------
SELECT 
    COUNT(*) AS TOTAL_VALUES,
    LENGTH(postal_code) AS prefix_length
FROM BRONZE.BRONZE_CUSTOMERS
GROUP BY prefix_length
ORDER BY prefix_length;
-- -------------------------------------------------------------------
--  Unstardardized prefix length of 4 digits found = 505/100000
-- -------------------------------------------------------------------
-- Check which country and ciy postal codes are affected 
SELECT Postal_code,country, city
FROM BRONZE.BRONZE_CUSTOMERS
WHERE LENGTH(postal_code)=4;
-- ===============================================================
-- NOTE: (flagged for transformation)
-- ===============================================================
-- 505 records contain a 4-digit postal code instead of the expected
-- 5 digits. Because this dataset was synthetically generated, this
-- is a known quality issue introduced during generation.
--
-- Two possible strategies:
-- 1. Recover the missing leading zero using LPAD().
-- 2. Flag the record as invalid for review.
--
-- Only one approach should be applied during transformation.
-- ===============================================================
-- ======================
-- Inspect phone numbers
-- =====================
SELECT PHONE_NUMBER FROM BRONZE_CUSTOMERS LIMIT 10;
-- ===============================================================
-- NOTE: (Flagged for transformation)
-- ===============================================================
-- Phone numbers contain inconsistent formatting including:
--   - dashes (-)
--   - periods (.)
--   - extensions (x####)
--
-- Since the generated data does not consistently align phone
-- numbers with country-specific numbering plans, only formatting
-- normalization will be performed.
--
-- Country codes will not be inferred or modified.
-- ===============================================================
-- [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]

-- =========================================================
--  DATA TRANSFORMATION AND TABLE CREATIONG
-- =========================================================



-- =========================================================
-- Surrogate Key Generation
-- =========================================================
-- Create a surrogate key sequence for the customer dimension.
-- Surrogate keys provide warehouse-managed identifiers that are
-- independent of source-system business keys (customer_id).
-- This improves consistency for joins and supports dimensional
-- modeling and future data integration.
CREATE SEQUENCE IF NOT EXISTS customer_key_seq
  START =1
  INCREMENT = 1;

CREATE TABLE IF NOT EXISTS  customer_surrogate
AS
SELECT 
        customer_key_seq.NEXTVAL as customer_key,
        customer_id 
FROM  BRONZE.BRONZE_customers;

-- =============================================================
-- DATA TRANSFORMATION
-- ==============================================================

-- 1: Postal_code:
--    Two ways to deal with this column:
--    1): Adding Zero at the start of every postal_code 
--        which has a prefix length less than 5

SELECT LPAD(POSTAL_CODE,5,'0') AS postal_code
FROM BRONZE.BRONZE_CUSTOMERS;
--    2): Flag the record as invalid for downstream review.

SELECT postal_code,
        CASE 
            WHEN LENGTH(POSTAL_CODE) < 5 THEN 'Invalid_postal_code'
            ELSE 'Valid_postal_code' END AS STATUS
FROM BRONZE.BRONZE_CUSTOMERS;

-- ==============================================
-- 2: Phone number has 'dashes','dots','+', Remove
--    those by the using the following query. 
-- ================================================

SELECT 
        REGEXP_REPLACE(SPLIT_PART(PHONE_NUMBER,'x',1),'[^0-9+]','') AS phone_number
FROM BRONZE.BRONZE_CUSTOMERS 
LIMIT 100;

-- Implement the transformation to create table
-- ------------------------------------------------
-- Create Silver Layer table with surrogate keys 
-- ===============================================

CREATE SEQUENCE IF NOT EXISTS customer_key_seq
  START =1
  INCREMENT = 1;

CREATE TABLE IF NOT EXISTS  customer_surrogate
AS
SELECT 
        customer_key_seq.NEXTVAL as customer_key,
        customer_id 
FROM  BRONZE.BRONZE_customers;

CREATE OR REPLACE TABLE  SILVER.SILVER_CUSTOMERS 
AS 
SELECT 
         cs.customer_key,
         bc.customer_id,
         bc.FIRST_NAME,
         bc.LAST_NAME,
         bc.DATE_OF_BIRTH,
         bc.COUNTRY,
         bc.CITY,
         bc.ADDRESS,
        CASE 
            WHEN LENGTH(bc.POSTAL_CODE) = 4 
                THEN LPAD(bc.postal_code,5,'0')
            ELSE bc.postal_code END AS postal_code,
-- =========================================
-- optional QoL improvement
        CASE 
            WHEN LENGTH(bc.postal_code) = 4
                THEN 'Corrected'
        ELSE 'Valid'
        END AS postal_code_status,
 -- ---------------------------------- ============    
                                bc.EMAIL,
        REGEXP_REPLACE(SPLIT_PART(
                                bc.PHONE_NUMBER,'x',1),'[^0-9+]','') AS phone_number,
                                bc.CUSTOMER_SINCE

FROM BRONZE.bronze_customers AS bc 
INNER JOIN CUSTOMER_SURROGATE AS cs
ON 
bc.customer_id=cs.customer_id;
-- =========================================
--  Validate table 
-- =========================================

SELECT 
        (SELECT COUNT(*)FROM BRONZE.BRONZE_CUSTOMERS) AS TOTAL_ROWS_BRONZE_CUSTOMERS,
        (SELECT COUNT(*) FROM SILVER.SILVER_CUSTOMERS) AS TOTAL_ROWS_SILVER_CUSTOMERS;

-- ------------------------------ 
SELECT * FROM 
SILVER.SILVER_CUSTOMERS
LIMIT 30;