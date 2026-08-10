-- ===========================================================
-- Configue Snowflake Session
-- ===========================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE banking;
USE SCHEMA GOLD;
-- ===========================================
-- Create SAT_MERCHANT TABLE 
-- ==========================================
SHOW COLUMNS IN TABLE SILVER.SILVER_MERCHANTS;

CREATE TABLE IF NOT EXISTS SAT_MERCHANT
AS 
    SELECT 
            HM.MERCHANT_HK,
            SM.merchant_name,
            SM.CITY,
            SM.country
    FROM SILVER.SILVER_MERCHANTS AS SM 
    INNER JOIN HUB_MERCHANT AS HM 
    ON 
    SM.MERCHANT_ID = HM.MERCHANT_ID;

-- =================================
-- VALIDATE 
-- =================================
SELECT *
FROM SAT_MERCHANT
LIMIT 10;