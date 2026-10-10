-- Fact: Sale
-- Grain: One row per customer invoice line
CREATE OR REPLACE TABLE fact_sale AS
SELECT
    -- Degenerate Dimensions (Business Keys)
    il.InvoiceLineID AS invoice_line_id,
    i.InvoiceID AS invoice_id,
    i.OrderID AS order_id,
    
    -- Dimension Keys
    CAST(STRFTIME(i.InvoiceDate, '%Y%m%d') AS INTEGER) AS invoice_date_sk,
    COALESCE(dc.customer_sk, -1) AS customer_sk,
    COALESCE(de.employee_sk, -1) AS salesperson_sk,
    COALESCE(dsi.stock_item_sk, -1) AS stock_item_sk,
    
    -- Measures
    il.Quantity AS invoiced_quantity,
    il.UnitPrice AS unit_price,
    il.TaxRate AS tax_rate,
    il.TaxAmount AS tax_amount,
    il.ExtendedPrice AS extended_amount_excluding_tax,
    (il.ExtendedPrice + il.TaxAmount) AS extended_amount_including_tax,
    il.LineProfit AS profit,
    
    -- Time measures (days between events)
    DATE_DIFF('day', o.OrderDate, i.InvoiceDate) AS days_order_to_invoice,
    DATE_DIFF('day', i.InvoiceDate, CAST(i.ConfirmedDeliveryTime AS DATE)) AS days_invoice_to_delivery

FROM sales.invoice_lines il
JOIN sales.invoices i 
    ON il.InvoiceID = i.InvoiceID
LEFT JOIN sales.orders o 
    ON i.OrderID = o.OrderID
-- Resolve Surrogate Keys
LEFT JOIN asb_olap.dim_customer dc 
    ON i.CustomerID = dc.customer_id
LEFT JOIN asb_olap.dim_employee de 
    ON i.SalespersonPersonID = de.employee_id
LEFT JOIN asb_olap.dim_stock_item dsi 
    ON il.StockItemID = dsi.stock_item_id AND dsi.is_current = TRUE;
