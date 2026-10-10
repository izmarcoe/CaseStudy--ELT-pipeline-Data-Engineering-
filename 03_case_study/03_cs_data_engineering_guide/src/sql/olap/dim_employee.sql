-- Dimension: Employee
-- Grain: One row per employee
CREATE OR REPLACE TABLE dim_employee AS
SELECT
    -- Surrogate Key (SK) generated sequentially
    ROW_NUMBER() OVER(ORDER BY PersonID) AS employee_sk,
    
    -- Business Key
    PersonID AS employee_id,
    
    -- Employee Attributes
    FullName AS full_name,
    PreferredName AS preferred_name,
    IsSalesperson AS is_salesperson

FROM application.people
WHERE IsEmployee = 1;