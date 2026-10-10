-- Dimension: City
-- Grain: One row per city
CREATE OR REPLACE TABLE dim_city AS
SELECT
    -- Surrogate Key (SK) generated sequentially
    ROW_NUMBER() OVER(ORDER BY ci.CityID) AS city_sk,
    
    -- Business Key (from source)
    ci.CityID AS city_id,
    
    -- City Attributes
    ci.CityName AS city_name,
    ci.Latitude AS latitude,
    ci.Longitude AS longitude,
    ci.LatestRecordedPopulation AS city_population,
    
    -- State/Province Attributes
    sp.StateProvinceName AS state_province,
    sp.SalesTerritory AS sales_territory,
    
    -- Country Attributes
    co.CountryName AS country,
    co.Continent AS continent,
    co.Region AS region,
    co.Subregion AS subregion

FROM application.cities AS ci
LEFT JOIN application.state_provinces AS sp 
    ON ci.StateProvinceID = sp.StateProvinceID
LEFT JOIN application.countries AS co 
    ON sp.CountryID = co.CountryID;