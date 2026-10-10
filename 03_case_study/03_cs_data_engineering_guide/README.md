# Data Engineering Take-Home Case Study 3: Wide World Importers

## 1. Solution Overview
This project builds an end-to-end Extract, Load, and Transform (ELT) pipeline for Wide World Importers (WWI). It ingests highly normalized operational (OLTP) data from raw CSV files into a DuckDB database and transforms it into an analytics-ready dimensional model (Star Schema) using SQL. The pipeline handles data quality checks and supports historical tracking through Slowly Changing Dimensions (SCD Type 2).

## 2. Technology Stack & Prerequisites
- **Python 3.11+**: Orchestration and data ingestion.
- **DuckDB**: In-memory analytical database chosen for its extreme speed, simplicity, and zero-dependency setup (no Docker required). It handles both OLTP staging and OLAP transformation natively.
- **Pandas/DuckDB SDK**: Used to read CSV files and interact with DuckDB.

## 3. Setup Instructions
1. Clone this repository and navigate to this folder: cd 03_cs_data_engineering_guide.
2. Create and activate a virtual environment:
   - Windows: python -m venv env & .\env\Scripts\activate
   - Linux/Mac: python3 -m venv env & source env/bin/activate
3. Install dependencies: pip install -r requirements.txt

## 4. One-Click Execution
The entire pipeline (Extraction, OLTP Load, OLAP Transformation, Data Quality, and Business Queries) can be executed using one script:
`ash
python run_pipe.py
`
*Note: The script automatically handles downloading the raw CSV files via the Kaggle API (src/00_download_csv.py), so no manual downloading is required.*

## 5. Pipeline Architecture Diagram
\\\mermaid
flowchart LR
    A[Raw CSVs (Kaggle)] -->|Extract & Load| B[(asb_oltp.duckdb)]
    B -->|Transform & SCD| C[(asb_olap.duckdb)]
    C -->|Validate| D[Data Quality Checks]
    C -->|Query| E[Business Questions Output]
\\\

## 6. Dimensional Model (Star Schema)
\\\mermaid
erDiagram
    fact_sale ||--o{ dim_date : "Invoice Date"
    fact_sale ||--o{ dim_customer : "Customer"
    fact_sale ||--o{ dim_employee : "Salesperson"
    fact_sale ||--o{ dim_stock_item : "Item"
    
    fact_order ||--o{ dim_date : "Order Date"
    fact_order ||--o{ dim_customer : "Customer"
    fact_order ||--o{ dim_employee : "Salesperson"
    fact_order ||--o{ dim_stock_item : "Item"
\\\

### Fact-Table Grain Definitions
- **act_order**: One row per customer order line (sales.order_lines joined to sales.orders).
- **act_sale**: One row per customer invoice line (sales.invoice_lines joined to sales.invoices).

### Source-to-Target Table Mapping
| Target OLAP Table | OLTP Source Tables | Type |
|---|---|---|
| dim_city | pplication.cities, pplication.state_provinces, pplication.countries | SCD Type 1 |
| dim_employee | pplication.people | SCD Type 1 |
| dim_customer | sales.customers, sales.customer_categories, sales.buying_groups | SCD Type 1 |
| dim_stock_item | warehouse.stock_items, warehouse.colors, warehouse.package_types | **SCD Type 2** |
| dim_date | *Generated via DuckDB sequence* | Static |
| act_order | sales.orders, sales.order_lines | Fact |
| act_sale | sales.invoices, sales.invoice_lines, sales.orders | Fact |

## 7. Slowly Changing Dimensions (SCD) Approach
- **SCD Type 2** is implemented on dim_stock_item. We track historical changes (e.g., price changes, brand changes). When an update is detected, the old record is "expired" (is_current = FALSE and alid_to set to current date), and a new record is inserted with a new surrogate key.
- **SCD Type 1** is used for dim_customer, dim_employee, and dim_city to simplify the model. Historical tracking wasn't deemed critical for these entities in the initial scope.

## 8. Preventing Duplicates (Idempotency)
Re-running the pipeline does not create duplicates:
- Fact tables are recreated (CREATE OR REPLACE) reading directly from the source.
- Dimension tables using SCD Type 1 are recreated.
- The SCD Type 2 dimension (dim_stock_item) explicitly compares incoming data with existing is_current=TRUE records and only processes updates if actual changes occurred.

## 9. Solution Questions & Future Scalability
1. **Why DuckDB?**: It allows treating local CSVs as a database, supports complex analytical SQL, and requires zero infrastructure. Python orchestration is robust and platform-agnostic.
2. **Scaling to Millions of Records/Hour**: If we required hourly updates for millions of records, I would move away from full-load CREATE OR REPLACE scripts. I would implement **incremental loads (CDC - Change Data Capture)**, perhaps using a tool like dbt or Apache Spark/Airflow, and partition the fact tables by date in a distributed warehouse (like Snowflake or BigQuery).

## 10. Data Quality Checks
Basic data quality rules are executed in src/03_data_quality.py:
- Primary keys are non-null.
- Unique business keys do not contain duplicates.
- Fact tables successfully resolve foreign keys to dimensions.
- Valid numerical boundaries (e.g., invoiced quantity >= 0).
- Only one current record exists per item in SCD Type 2.
