import duckdb
import os

def run_business_questions(conn):
    print("Running Business Questions...")
    
    queries = {
        '1_sales_by_month_fy': '''
            SELECT d.fiscal_year, d.fiscal_month, SUM(f.extended_amount_excluding_tax) as total_sales, SUM(f.invoiced_quantity) as qty_sold, SUM(f.profit) as total_profit
            FROM fact_sale f
            JOIN dim_date d ON f.invoice_date_sk = d.date_sk
            GROUP BY d.fiscal_year, d.fiscal_month
            ORDER BY d.fiscal_year, d.fiscal_month;
        ''',
        '2_top_products': '''
            SELECT s.stock_item_name, SUM(f.extended_amount_excluding_tax) as total_sales, SUM(f.profit) as total_profit
            FROM fact_sale f
            JOIN dim_stock_item s ON f.stock_item_sk = s.stock_item_sk
            GROUP BY s.stock_item_name
            ORDER BY total_profit DESC LIMIT 10;
        ''',
        '3_top_customers': '''
            SELECT c.customer_name, c.customer_category, SUM(f.extended_amount_excluding_tax) as total_revenue
            FROM fact_sale f
            JOIN dim_customer c ON f.customer_sk = c.customer_sk
            GROUP BY c.customer_name, c.customer_category
            ORDER BY total_revenue DESC LIMIT 10;
        ''',
        '4_sales_by_location': '''
            SELECT c.delivery_city_id, SUM(f.extended_amount_excluding_tax) as total_sales
            FROM fact_sale f
            JOIN dim_customer c ON f.customer_sk = c.customer_sk
            GROUP BY c.delivery_city_id
            ORDER BY total_sales DESC LIMIT 10;
        ''',
        '5_top_salespeople': '''
            SELECT e.full_name, SUM(f.extended_amount_excluding_tax) as total_sales
            FROM fact_sale f
            JOIN dim_employee e ON f.salesperson_sk = e.employee_sk
            WHERE e.is_salesperson = 1
            GROUP BY e.full_name
            ORDER BY total_sales DESC;
        '''
    }
    
    for name, query in queries.items():
        print(f"Executing {name}...")
        # Remove trailing semicolon for the COPY statement
        clean_query = query.strip().rstrip(';')
        # Use DuckDB's native CSV export to avoid Pandas/Numpy dependency
        conn.sql(f"COPY ({clean_query}) TO 'output/{name}.csv' (HEADER, DELIMITER ',');")
        
    print("Business questions executed and saved to output/ folder.")

if __name__ == "__main__":
    conn = duckdb.connect("asb_olap.duckdb")
    run_business_questions(conn)
