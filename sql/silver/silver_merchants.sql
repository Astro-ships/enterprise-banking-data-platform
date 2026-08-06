-- =============================
--  Configure Snowflake Session
-- =============================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA SILVER;
-- ======================================
-- Data Profiling
-- ======================================
-- > Inspect table and its data type
DESC TABLE BRONZE.BRONZE_MERCHANTS;

-- ==========================================================
-- Data Profiling Summary
-- ----------------------------------------------------------
-- Duplicate merchant rows    : None
-- Duplicate merchant_id      : None
-- Null values                : None
-- Merchant name formatting   : Inconsistent (flagged)
-- City                       : Standardized
-- Country                    : Standardized
-- ----------------------------------------------------------
-- ========================
-- 1: Inspect For Nulls
SELECT COUNT(*) AS TOTAL_NULLS
FROM BRONZE.BRONZE_MERCHANTS
WHERE <columnname> IS NULL;
-- Result: No Nulls found in any column

-- =====================================
-- Inspect duplicates 
-- ===================================
-- 1: merchant_id 
SELECT COUNT(*) AS TOTAL_IDS,
COUNT(DISTINCT merchant_id) AS UNIQUE_IDS 
FROM BRONZE.BRONZE_MERCHANTS;
-- No duplicates in primary key
-- ===========================================
-- 2: inspect columns for unstandardized data
-- ==========================================
SELECT DISTINCT MERCHANT_NAME
FROM BRONZE.BRONZE_MERCHANTS;
-- Flagged: Unstandardized data found 
-- ---------------------------------------
SELECT DISTINCT city 
FROM BRONZE.BRONZE_MERCHANTS;
-- Standardized 
-- --------------------------------------------
SELECT DISTINCT COUNTRY
FROM BRONZE.BRONZE_MERCHANTS;
-- Result: DATA standardized
-- ----------------------------------------------------------
-- Planned Silver Transformations
-- ----------------------------------------------------------
-- • Standardize merchant_name formatting
-- • Trim leading/trailing whitespace
-- • Normalize capitalization
-- • Preserve merchant_id as the business key
-- • Generate warehouse surrogate key
-- ==========================================================
-- Transformation
-- ===========================================================
-- ----------------------------------------------------------
-- Merchant Name Lookup Table
-- ==========================================================
-- Some merchant names were intentionally generated with
-- spelling mistakes and inconsistent formatting to simulate
-- real-world data quality issues.
--
-- Instead of correcting each value with a long CASE statement,
-- all known corrections are stored in this lookup table.
--
-- During the Silver transformation, merchant names will be
-- matched against this table. If a correction exists, the
-- standardized merchant name will be used; otherwise, the
-- cleaned original value will be kept.
-- ==========================================================
SELECT DISTINCT MERCHANT_NAME FROM BRONZE.BRONZE_MERCHANTS;
CREATE OR REPLACE TABLE  merchant_lookup (
    incorrect_name VARCHAR,
    correct_name   VARCHAR
);
INSERT INTO merchant_lookup (incorrect_name, correct_name)
VALUES
('Amazon.com', 'Amazon'),
('Wal-Mart', 'Walmart'),
('K.F.C.', 'KFC'),
('Apple App Store', 'Apple'),
('pso', 'PSO'),
('Steam Store', 'Steam'),
('Daraz.pk', 'Daraz'),
('AMZN', 'Amazon'),
('TotalEnergies', 'Total Energies'),
('Star bucks', 'Starbucks'),
('APPLE STORE', 'Apple'),
('H and M', 'H&M'),
('Am azon', 'Amazon'),
('McDonalds', 'McDonald''s'),
('CoffeeHouse', 'Coffee House'),
('Fresh Mart', 'FreshMart'),
('TechWorld', 'Tech World'),
('CVS', 'CVS Pharmacy'),
('Cost Co', 'Costco'),
('Netflix Inc.', 'Netflix'),
('Shell Petrol', 'Shell'),
('E-bay', 'eBay'),
('Ebay','eBay'),
('Pso','PSO'),
('Amzn','Amazon'),
('Daraz.Pk','Daraz'),
('Playstation Store','Playstation'),
('Pia','PIA'),
('Cvs','CVS Pharmacy'),
('Kfc','KFC'),
('Cvs Pharmacy','CVS Pharmacy'),
('Mcdonalds','Mcdonald''s'),
('Xbox Store','XBOX'),
('Bp','BP'),
('Pizzahit','Pizza Hut'),
('Freshmart','FreshMart'),
('H And M','H&M'),
('E-Bay','eBay'),
('Am Azon','Amazon'),
('At&T','AT&T'),
('Apple Store','Apple'),
('H&M Store','H&M'),
('Ikea','IKEA'),
('Pakistan State Oil','PSO'),
('Totalenergies','Total Energies'),
('Steam Store','Steam'),
('burger king','Burger King'),
('pso','PSO'),('ADIDAS','Adidas');


-- ============================================
-- Transformation
-- ============================================

SELECT DISTINCT
   COALESCE(
      ml.correct_name,INITCAP(TRIM(LOWER(bm.merchant_name)))
   ) AS merchant_name
FROM BRONZE.BRONZE_MERCHANTS AS bm 
LEFT JOIN merchant_lookup AS ml
ON 
INITCAP(TRIM(LOWER(bm.merchant_name))) = ml.incorrect_name;
-- Note: 
-- Most of the inconsistencies are almost rectified. If further more inconsistency is found,
-- just update the lookup table.
-- ================================================================
-- Creating Surrogate key
-- =============================================================
CREATE OR REPLACE SEQUENCE merchant_key_sq 
START = 1
INCREMENT = 1;
CREATE OR REPLACE TABLE merchant_surrogate 
AS 
   SELECT DISTINCT
            merchant_key_sq.NEXTVAL AS merchant_key,
            merchant_id 
   FROM BRONZE.BRONZE_MERCHANTS;
-- ========================================================
--  Create table: Silver_merchants 
-- ========================================================
CREATE OR REPLACE TABLE SILVER.silver_merchants 
AS 
SELECT 
         ms.merchant_key,
         bm.merchant_id,
COALESCE(ml.correct_name , INITCAP(TRIM(LOWER(bm.merchant_name)))) AS merchant_name,
         bm.city,
         bm.country
FROM BRONZE.BRONZE_MERCHANTS AS bm
INNER JOIN merchant_surrogate AS ms 
ON 
   bm.merchant_id=ms.merchant_id
LEFT JOIN merchant_lookup as ml 
ON 
INITCAP(TRIM(LOWER(bm.merchant_name))) = ml.incorrect_name;

-- ==========================================================
--  Validate table 
-- ==========================================================

SELECT
      (SELECT COUNT(*)  FROM BRONZE.BRONZE_MERCHANTS) AS bronze_rows,
      (SELECT COUNT(*) FROM SILVER_MERCHANTS) AS  silver_rows;
-- ------------------------------------------
SELECT * FROM SILVER_MERCHANTS
ORDER BY merchant_key
LIMIT 10;