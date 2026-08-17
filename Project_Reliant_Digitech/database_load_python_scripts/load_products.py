"""
Load products data file into MySQL STG_PRODUCTS table.

Automatically finds files matching pattern: products_*.csv

Features:
- Checks FILE_LOAD_LOG to avoid duplicate loads
- Logs success/failure to FILE_LOAD_LOG
- Moves files to processed/ or failed/ folders

Usage:
    python load_products.py
"""

import sys
import os
import glob
import shutil
import pandas as pd
import mysql.connector
from config import DATABASE_BRONZE, MYSQL_CONFIG

def find_products_files():
    """Find all products files in stg folder."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    stg_folder = os.path.abspath(os.path.join(script_dir, '..', 'datasets', 'Reliant_Digitech', 'stg'))
    
    all_files = []
    for pattern in ['products_*.csv']:
        all_files.extend(sorted(glob.glob(os.path.join(stg_folder, pattern))))
    return all_files

def check_if_already_loaded(conn, file_name, table_name):
    """Check if file was already loaded successfully."""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT COUNT(1)
        FROM FILE_LOAD_LOG
        WHERE file_name = %s
          AND table_name = %s
          AND load_status = 'SUCCESS'
    """, (file_name, table_name))
    result = cursor.fetchone()[0] > 0
    cursor.close()
    return result

def log_file_load(conn, file_name, table_name, rows_loaded, status, error_msg=None):
    """Log file load result to FILE_LOAD_LOG table."""
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO FILE_LOAD_LOG
            (file_name, table_name, file_hash, rows_loaded, load_status, error_message)
        VALUES (%s, %s, NULL, %s, %s, %s)
    """, (file_name, table_name, rows_loaded, status, error_msg))
    conn.commit()
    cursor.close()

def load_products():
    """Load all products files into STG_PRODUCTS table."""
    
    # Find all files
    file_paths = find_products_files()
    if not file_paths:
        print("Error: No products files found (products_*.csv)")
        sys.exit(1)
        
    print(f"Found {len(file_paths)} products file(s)")
    
    # Setup
    datasets_folder = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'datasets', 'Reliant_Digitech'))
    processed_folder = os.path.join(datasets_folder, 'processed')
    failed_folder = os.path.join(datasets_folder, 'failed')
    os.makedirs(processed_folder, exist_ok=True)
    os.makedirs(failed_folder, exist_ok=True)
    
    # Connect to MySQL
    conn = mysql.connector.connect(
        host=MYSQL_CONFIG['host'],
        port=MYSQL_CONFIG['port'],
        user=MYSQL_CONFIG['user'],
        password=MYSQL_CONFIG['password'],
        database=DATABASE_BRONZE,
        use_pure=True
    )
    
    total_rows = success_count = failed_count = skipped_count = 0
    
    for file_path in file_paths:
        file_name = os.path.basename(file_path)
        print(f"\nProcessing {file_name}")
        
        # Check if already loaded
        if check_if_already_loaded(conn, file_name, 'STG_PRODUCTS'):
            print(f"  ⊗ Skipped: Already loaded successfully")
            skipped_count += 1
            continue
            
        try:
            # Read file
            df = pd.read_csv(file_path, dtype=str)
            print(f"  → Read {len(df):,} rows")
            
            # Prepare DataFrame
            df.columns = [col.upper() for col in df.columns]
            for col in ['LOADED_AT', 'IS_PROCESSED', 'SOURCE_FILE']:
                if col in df.columns:
                    df = df.drop(columns=[col])
            df['SOURCE_FILE'] = file_name
            df = df.where(pd.notnull(df), None)
            
            # Load to MySQL (all-or-nothing with transaction)
            rows = len(df)
            try:
                cursor = conn.cursor()
                columns = df.columns.tolist()
                placeholders = ', '.join(['%s'] * len(columns))
                columns_str = ', '.join(columns)
                query = f"INSERT INTO stg_products ({columns_str}) VALUES ({placeholders})"
                cursor.executemany(query, df.values.tolist())
                cursor.close()
                
                log_file_load(conn, file_name, 'STG_PRODUCTS', rows, 'SUCCESS')
                conn.commit()
                
                print(f"  ✓ Successfully loaded {rows:,} rows into STG_PRODUCTS")
                
                shutil.move(file_path, os.path.join(processed_folder, file_name))
                print("  → Moved to processed/")
                
                total_rows += rows
                success_count += 1
                
            except Exception:
                conn.rollback()
                raise
                
        except Exception as e:
            print(f"  ✗ Error: {e}")
            log_file_load(conn, file_name, 'STG_PRODUCTS', 0, 'FAILED', str(e))
            shutil.move(file_path, os.path.join(failed_folder, file_name))
            print("  → Moved to failed/")
            failed_count += 1
            
    conn.close()
    
    # Summary
    print(f"\n{'-'*60}")
    print("SUMMARY")
    print(f"{'-'*60}")
    print(f"Files processed successfully: {success_count}")
    print(f"Files skipped (already loaded): {skipped_count}")
    print(f"Files failed:                 {failed_count}")
    print(f"Total rows loaded:            {total_rows:,}")
    print(f"{'-'*60}")

if __name__ == '__main__':
    load_products()
