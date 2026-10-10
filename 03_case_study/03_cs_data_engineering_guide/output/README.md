# Business Questions Results (Output Summary)

This folder contains the CSV outputs for the analytical business questions required by the take-home case study. Below is a quick summary of the top-level insights so you can quickly review the results of the Star Schema.

### 1. Sales & Profit by Fiscal Year/Month (\1_sales_by_month_fy.csv\)
*   **Insight:** Sales remain highly seasonal. For example, early FY 2013 showed steady growth, with Fiscal Month 3 (January) achieving **.3M** in sales and **.89M** in profit, dipping slightly in Month 4, and rebounding in Month 5 and 6 (over **.6M** in sales).
*   *Note: Wide World Importers uses a November 1st Fiscal Year start date. This logic was implemented in \dim_date\.*

### 2. Top Performing Products (\2_top_products.csv\)
*   **Insight:** Packaging materials and machinery dominate the profit margins. 
*   **#1 Profit Driver:** \20 mm Double sided bubble wrap 50m\ (.14M in sales, **.29M in profit**)
*   **#1 Revenue Driver:** \Air cushion machine (Blue)\ (**.7M** in sales, .43M in profit)

### 3. Top Customers & Categories (\3_top_customers.csv\)
*   **Insight:** "Novelty Shops" are the dominant customer category for revenue.
*   **Top Customer:** \Tailspin Toys (Inguadona, MN)\ generated over **** in revenue, closely followed by \Tailspin Toys (Minidoka, ID)\ and \Mauno Laurila\.

### 4. Sales by Location (\4_sales_by_location.csv\)
*   **Insight:** Revenue is distributed across specific delivery cities without a single extreme outlier, though cities like ID 31685 and 33832 lead the pack with over **+** in sales each.

### 5. Top Salespeople (\5_top_salespeople.csv\)
*   **Insight:** The sales team is highly competitive and evenly matched at the top.
*   **#1 Salesperson:** \Archer Lamble\ with **.6M** in sales.
*   **#2 Salesperson:** \Kayla Woodcock\ with **.1M** in sales.

---
*All files in this directory were generated programmatically via the src/04_business_questions.py script running against the sb_olap.duckdb Data Warehouse.*
