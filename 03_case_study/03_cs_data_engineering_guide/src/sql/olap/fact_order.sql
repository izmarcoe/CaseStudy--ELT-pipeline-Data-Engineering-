-- Fact: Order
-- Grain: One row per customer order line
CREATE OR REPLACE TABLE fact_order AS
SELECT
    -- Degenerate Dimensions (Business Keys)
    ol.OrderLineID AS order_line_id,
    o.OrderID AS order_id,
    
    -- Dimension Keys (Foreign Keys)
    CAST(STRFTIME(o.OrderDate, '%Y%m%d') AS INTEGER) AS order_date_sk,
    COALESCE(dc.customer_sk, -1) AS customer_sk,
    COALESCE(de.employee_sk, -1) AS salesperson_sk,
    COALESCE(dsi.stock_item_sk, -1) AS stock_item_sk,
    
    -- Measures
    ol.Quantity AS ordered_quantity,
    ol.UnitPrice AS unit_price,
    ol.TaxRate AS tax_rate,
    (ol.Quantity * ol.UnitPrice) AS extended_amount_excluding_tax,
    (ol.Quantity * ol.UnitPrice) * (1 + (ol.TaxRate / 100.0)) AS extended_amount_including_tax,
    
    -- Additional attributes
    CASE WHEN o.BackorderOrderID IS NOT NULL AND o.BackorderOrderID != '' THEN 1 ELSE 0 END AS is_backorder

FROM sales.order_lines ol
JOIN sales.orders o 
    ON ol.OrderID = o.OrderID
-- Resolve Surrogate Keys from Dimension tables in the OLAP database
LEFT JOIN asb_olap.dim_customer dc 
    ON o.CustomerID = dc.customer_id
LEFT JOIN asb_olap.dim_employee de 
    ON o.SalespersonPersonID = de.employee_id
LEFT JOIN asb_olap.dim_stock_item dsi 
    ON ol.StockItemID = dsi.stock_item_id AND dsi.is_current = TRUE;
