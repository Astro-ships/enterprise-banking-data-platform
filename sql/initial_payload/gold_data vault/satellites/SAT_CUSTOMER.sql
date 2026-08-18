-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- ===========================================
-- Create SAT_CUSTOMER TABLE 
-- ==========================================
SHOW COLUMNS IN TABLE SILVER.SILVER_CUSTOMERS;
CREATE OR REPLACE TABLE SAT_CUSTOMER
AS 
SELECT 
        HC.CUSTOMER_HK,
        SA.FIRST_NAME,
        SA.LAST_NAME,
        SA.DATE_OF_BIRTH,
        SA.COUNTRY,
        SA.CITY,
        SA.ADDRESS,
        SA.POSTAL_CODE,
        SA.POSTAL_CODE_STATUS,
        SA.EMAIL,
        SA.PHONE_NUMBER,
        SA.CUSTOMER_SINCE
FROM SILVER.SILVER_CUSTOMERS AS SA 
INNER JOIN HUB_CUSTOMER AS HC 
ON 
SA.CUSTOMER_ID =HC.CUSTOMER_ID;

-- ==================================
-- Validate table
-- =================================
SELECT *
FROM SAT_CUSTOMER 
LIMIT 10;