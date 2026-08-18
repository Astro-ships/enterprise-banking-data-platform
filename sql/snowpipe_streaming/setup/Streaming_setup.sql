-- ===============================
-- Configure Snowflake Session
-- ===============================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE BANKING;
CREATE SCHEMA RAW_STREAMING;
USE SCHEMA RAW_STREAMING;
-- ==============================================