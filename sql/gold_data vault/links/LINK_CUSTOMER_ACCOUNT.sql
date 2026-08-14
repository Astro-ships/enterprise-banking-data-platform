-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- ====================================================
-- Create Link_customer_account
-- ====================================================
-- ============================================================
-- Link: Customer → Account
-- ============================================================
-- This Link stores the relationship between a customer and
-- their account. The relationship comes from SILVER_ACCOUNTS,
-- where CUSTOMER_ID and ACCOUNT_ID already exist together.
-- ============================================================
CREATE TABLE IF NOT EXISTS GOLD.LINK_CUSTOMER_ACCOUNT 
AS 
    SELECT
        MD5(SA.CUSTOMER_ID|| '|'||SA.ACCOUNT_ID) AS customer_account_hk,
        HC.customer_hk,
        HA.account_hk,
        current_timestamp() AS load_date,
        'SILVER_ACCOUNTS' AS record_source 
    FROM SILVER.SILVER_ACCOUNTS AS SA
    INNER JOIN GOLD.HUB_CUSTOMER AS HC
    ON 
    SA.CUSTOMER_ID=HC.CUSTOMER_ID
    INNER JOIN GOLD.HUB_ACCOUNT AS HA
    ON 
    SA.ACCOUNT_ID = HA.ACCOUNT_ID;
 -- ===========================
 -- VAlidate
 -- ===========================
 SELECT * FROM GOLD.LINK_CUSTOMER_ACCOUNT
 LIMIT 10;