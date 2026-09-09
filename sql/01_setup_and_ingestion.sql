-- 1. Set admin role and ensure compute/storage infrastructure exists
USE ROLE ACCOUNTADMIN;

CREATE WAREHOUSE IF NOT EXISTS INTERVIEW_WH 
    WITH WAREHOUSE_SIZE = 'XSMALL' 
    AUTO_SUSPEND = 60  
    AUTO_RESUME = TRUE;

CREATE DATABASE IF NOT EXISTS MEDIA_DB;
CREATE SCHEMA IF NOT EXISTS MEDIA_DB.PUBLIC;

-- 2. Set active session context
USE WAREHOUSE INTERVIEW_WH;
USE DATABASE MEDIA_DB;
USE SCHEMA PUBLIC;

-- 3. Create the table using fully qualified name
CREATE OR REPLACE TABLE MEDIA_DB.PUBLIC.RAW_CAMPAIGN_LOGS (
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    payload VARIANT
);

-- 4. Insert mock ad campaign payload
INSERT INTO MEDIA_DB.PUBLIC.RAW_CAMPAIGN_LOGS (payload)
SELECT PARSE_JSON('{
    "campaign": "Fall_Promo_2026",
    "market": "Atlanta",
    "metrics": {
        "budget": 50000.00,
        "spend": 54200.00,
        "impressions": 1250000
    }
}');

-- 5. Query the JSON data
SELECT 
    payload:campaign::STRING AS campaign_name,
    payload:market::STRING AS market,
    payload:metrics:budget::NUMERIC(10,2) AS budget,
    payload:metrics:spend::NUMERIC(10,2) AS spend,
    (payload:metrics:spend::NUMERIC(10,2) / NULLIF(payload:metrics:budget::NUMERIC(10,2), 0)) * 100 AS pacing_pct
FROM MEDIA_DB.PUBLIC.RAW_CAMPAIGN_LOGS;

-- 6. Create Dynamic Table to automate transformation (Replaces Domo Magic ETL)
CREATE OR REPLACE DYNAMIC TABLE MEDIA_DB.PUBLIC.FACT_CAMPAIGN_PACING
    TARGET_LAG = '1 minute'
    WAREHOUSE = INTERVIEW_WH
AS
SELECT 
    campaign_name,
    market,
    budget,
    spend,
    pacing_pct,
    CASE 
        WHEN pacing_pct > 100 THEN 'OVER_BUDGET'
        WHEN pacing_pct < 85 THEN 'UNDER_PACING'
        ELSE 'ON_PACING'
    END AS pacing_status
FROM (
    SELECT 
        payload:campaign::STRING AS campaign_name,
        payload:market::STRING AS market,
        payload:metrics:budget::NUMERIC(10,2) AS budget,
        payload:metrics:spend::NUMERIC(10,2) AS spend,
        (payload:metrics:spend::NUMERIC(10,2) / NULLIF(payload:metrics:budget::NUMERIC(10,2), 0)) * 100 AS pacing_pct
    FROM MEDIA_DB.PUBLIC.RAW_CAMPAIGN_LOGS
);

-- 7. Query the dynamic table
SELECT * FROM MEDIA_DB.PUBLIC.FACT_CAMPAIGN_PACING;

-- 8. Test real-time pipeline automation by inserting a second JSON payload
INSERT INTO MEDIA_DB.PUBLIC.RAW_CAMPAIGN_LOGS (payload)
SELECT PARSE_JSON('{
    "campaign": "Winter_Campaign_2026",
    "market": "Savannah",
    "metrics": {
        "budget": 30000.00,
        "spend": 21000.00,
        "impressions": 800000
    }
}');

-- 9. Query the dynamic table to verify the new row is automatically transformed
SELECT * FROM MEDIA_DB.PUBLIC.FACT_CAMPAIGN_PACING;