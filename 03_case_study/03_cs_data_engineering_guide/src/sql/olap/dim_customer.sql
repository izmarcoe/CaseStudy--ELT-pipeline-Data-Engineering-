-- Dimension: Customer
-- Grain: One row per customer
CREATE OR REPLACE TABLE dim_customer AS
SELECT
    -- Surrogate Key generated sequentially
    ROW_NUMBER() OVER(ORDER BY c.CustomerID) AS customer_sk,
    
    -- Business Key
    c.CustomerID AS customer_id,
    
    -- Attributes
    c.CustomerName AS customer_name,
    cc.CustomerCategoryName AS customer_category,
    bg.BuyingGroupName AS buying_group,
    c.DeliveryCityID AS delivery_city_id,
    TRY_CAST(c.CreditLimit AS DOUBLE) AS credit_limit,
    c.AccountOpenedDate AS account_opened_date,
    c.StandardDiscountPercentage AS standard_discount_percentage

FROM sales.customers c
LEFT JOIN sales.customer_categories cc 
    ON c.CustomerCategoryID = cc.CustomerCategoryID
LEFT JOIN sales.buying_groups bg 
    ON TRY_CAST(c.BuyingGroupID AS BIGINT) = bg.BuyingGroupID;