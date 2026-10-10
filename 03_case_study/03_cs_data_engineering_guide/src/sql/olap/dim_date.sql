-- Dimension: Date
-- Grain: One row per date
CREATE OR REPLACE TABLE dim_date AS
WITH date_series AS (
    SELECT CAST(range AS DATE) AS date_val
    FROM range(DATE '2012-01-01', DATE '2020-12-31', INTERVAL 1 DAY)
)
SELECT 
    -- Surrogate Key (integer format like 20130101)
    CAST(strftime(date_val, '%Y%m%d') AS INTEGER) AS date_sk,
    
    date_val AS date,
    DAY(date_val) AS day,
    MONTH(date_val) AS month,
    QUARTER(date_val) AS quarter,
    YEAR(date_val) AS calendar_year,
    DAYOFWEEK(date_val) AS weekday, -- 0 = Sunday, 1 = Monday, etc.
    
    -- Fiscal Year logic (Starts November 1)
    CASE 
        WHEN MONTH(date_val) >= 11 THEN YEAR(date_val) + 1 
        ELSE YEAR(date_val) 
    END AS fiscal_year,
    
    ((MONTH(date_val) + 1) % 12) + 1 AS fiscal_month,
    
    CAST(CEIL( (((MONTH(date_val) + 1) % 12) + 1) / 3.0 ) AS INTEGER) AS fiscal_quarter

FROM date_series;
