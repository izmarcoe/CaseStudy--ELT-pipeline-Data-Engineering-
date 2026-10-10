import duckdb
import sys

def check_data_quality(conn):
    print("Starting Data Quality Checks...")
    errors = 0
    
    checks = [
        {
            "name": "PK not null (fact_sale)",
            "query": "SELECT COUNT(*) FROM fact_sale WHERE invoice_line_id IS NULL;",
            "expected": 0
        },
        {
            "name": "Unique Business Keys (dim_city)",
            "query": "SELECT COUNT(*) FROM (SELECT city_id, COUNT(*) FROM dim_city GROUP BY city_id HAVING COUNT(*) > 1) t;",
            "expected": 0
        },
        {
            "name": "Fact records resolve to dimensions (fact_sale -> dim_customer)",
            "query": "SELECT COUNT(*) FROM fact_sale WHERE customer_sk = -1;",
            "expected": 0
        },
        {
            "name": "Quantities are reasonable (fact_sale)",
            "query": "SELECT COUNT(*) FROM fact_sale WHERE invoiced_quantity < 0;",
            "expected": 0
        },
        {
            "name": "Only one current SCD Type 2 record (dim_stock_item)",
            "query": "SELECT COUNT(*) FROM (SELECT stock_item_id, COUNT(*) FROM dim_stock_item WHERE is_current = TRUE GROUP BY stock_item_id HAVING COUNT(*) > 1) t;",
            "expected": 0
        }
    ]
    
    for check in checks:
        result = conn.sql(check["query"]).fetchone()[0]
        if result == check["expected"]:
            print(f"[PASS] {check['name']}")
        else:
            print(f"[FAIL] {check['name']} - Expected {check['expected']}, got {result}")
            errors += 1
            
    if errors > 0:
        print(f"Data Quality Checks Failed with {errors} errors.")
        sys.exit(1)
    else:
        print("All Data Quality Checks Passed!")

if __name__ == "__main__":
    conn = duckdb.connect("asb_olap.duckdb")
    check_data_quality(conn)
