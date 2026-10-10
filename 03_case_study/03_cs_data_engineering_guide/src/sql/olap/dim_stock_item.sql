-- Dimension: Stock Item (SCD Type 2)
-- Grain: One row per stock item per validity period

-- Create sequence for Surrogate Key if it doesn't exist
CREATE SEQUENCE IF NOT EXISTS asb_olap.seq_stock_item_sk START 1;

-- Create the dimension table if it doesn't exist
CREATE TABLE IF NOT EXISTS asb_olap.dim_stock_item (
    stock_item_sk INTEGER PRIMARY KEY,
    stock_item_id BIGINT,
    stock_item_name VARCHAR,
    color VARCHAR,
    unit_package VARCHAR,
    outer_package VARCHAR,
    brand VARCHAR,
    size VARCHAR,
    lead_time_days BIGINT,
    is_chiller_stock BIGINT,
    tax_rate DOUBLE,
    unit_price DOUBLE,
    recommended_retail_price DOUBLE,
    typical_weight_per_unit DOUBLE,
    
    -- SCD Type 2 Columns
    valid_from DATE,
    valid_to DATE,
    is_current BOOLEAN
);

-- We need a staging table with the latest data from OLTP
CREATE TEMPORARY TABLE stg_stock_item AS
SELECT
    si.StockItemID AS stock_item_id,
    si.StockItemName AS stock_item_name,
    c.ColorName AS color,
    up.PackageTypeName AS unit_package,
    op.PackageTypeName AS outer_package,
    si.Brand AS brand,
    si.Size AS size,
    si.LeadTimeDays AS lead_time_days,
    si.IsChillerStock AS is_chiller_stock,
    si.TaxRate AS tax_rate,
    si.UnitPrice AS unit_price,
    si.RecommendedRetailPrice AS recommended_retail_price,
    si.TypicalWeightPerUnit AS typical_weight_per_unit
FROM warehouse.stock_items si
LEFT JOIN warehouse.colors c ON TRY_CAST(si.ColorID AS BIGINT) = c.ColorID
LEFT JOIN warehouse.package_types up ON si.UnitPackageID = up.PackageTypeID
LEFT JOIN warehouse.package_types op ON si.OuterPackageID = op.PackageTypeID;

-- 1. Identify changed records (Records that exist in dimension but have different attributes)
CREATE TEMPORARY TABLE changed_stock_items AS
SELECT s.*
FROM stg_stock_item s
JOIN asb_olap.dim_stock_item d ON s.stock_item_id = d.stock_item_id AND d.is_current = TRUE
WHERE s.stock_item_name != d.stock_item_name
   OR COALESCE(s.color, '') != COALESCE(d.color, '')
   OR COALESCE(s.brand, '') != COALESCE(d.brand, '')
   OR COALESCE(s.size, '') != COALESCE(d.size, '')
   OR s.unit_price != d.unit_price;

-- 2. Expire old records for changed items
UPDATE asb_olap.dim_stock_item
SET valid_to = CURRENT_DATE, is_current = FALSE
WHERE is_current = TRUE 
  AND stock_item_id IN (SELECT stock_item_id FROM changed_stock_items);

-- 3. Insert new records for changed items
INSERT INTO asb_olap.dim_stock_item
SELECT 
    nextval('asb_olap.seq_stock_item_sk'),
    stock_item_id, stock_item_name, color, unit_package, outer_package,
    brand, size, lead_time_days, is_chiller_stock, tax_rate, unit_price,
    recommended_retail_price, typical_weight_per_unit,
    CURRENT_DATE AS valid_from,
    DATE '9999-12-31' AS valid_to,
    TRUE AS is_current
FROM changed_stock_items;

-- 4. Insert entirely new records (don't exist in dimension at all)
INSERT INTO asb_olap.dim_stock_item
SELECT 
    nextval('asb_olap.seq_stock_item_sk'),
    s.stock_item_id, s.stock_item_name, s.color, s.unit_package, s.outer_package,
    s.brand, s.size, s.lead_time_days, s.is_chiller_stock, s.tax_rate, s.unit_price,
    s.recommended_retail_price, s.typical_weight_per_unit,
    DATE '1900-01-01' AS valid_from,
    DATE '9999-12-31' AS valid_to,
    TRUE AS is_current
FROM stg_stock_item s
LEFT JOIN asb_olap.dim_stock_item d ON s.stock_item_id = d.stock_item_id
WHERE d.stock_item_id IS NULL;

-- Cleanup temporary tables
DROP TABLE stg_stock_item;
DROP TABLE changed_stock_items;
