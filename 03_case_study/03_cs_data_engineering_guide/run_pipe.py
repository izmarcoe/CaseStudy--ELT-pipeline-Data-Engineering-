import subprocess
import sys

def run_script(script_path):
    print(f"=====================================")
    print(f"Running {script_path}...")
    print(f"=====================================")
    result = subprocess.run([sys.executable, script_path])
    if result.returncode != 0:
        print(f"Error: {script_path} failed with return code {result.returncode}")
        sys.exit(result.returncode)
    print(f"Success: {script_path} completed successfully.\n")

if __name__ == "__main__":
    scripts_to_run = [
        "src/00_download_csv.py",
        "src/01_ingest_csv.py",
        "src/02_ingest_olap.py",
        "src/03_data_quality.py",
        "src/04_business_questions.py"
    ]
    
    for script in scripts_to_run:
        run_script(script)
        
    print("Pipeline execution completed successfully!")
