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
CREATE TABLE IF NOT EXISTS merchant_lookup (
   INCORRECT_NAME VARCHAR,
   CORRECT_NAME VARCHAR
);

INSERT INTO TABLE merchant_lookup(INCORRECT_NAME,CORRECT_NAME)
VALUES
("Amazon.com", "Amazon"),
("Wal-Mart", "walmart" ),
("K.F.C.","KFC"),
("Apple App Store","Apple"),
("pso","Pakistan State Oil"),
("Steam Store","Steam"),
("Daraz.pk","Daraz"),
("AMZN","Amazon"),
("TotalEnergies","Total Energies"),
("Star bucks","Starbucks")
("APPLE STORE","Apple"),
("H and M","H&M")