"""
Load date dimension data file into MySQL STG_DATE_DIM table.

Automatically finds files matching pattern: date_dim_*.csv

Features:
- Checks FILE_LOAD_LOG to avoid duplicate loads
- Logs success/failure to FILE_LOAD_LOG
- Moves files to processed/ or failed/ folders

Usage:
    python load_date_dim.py
"""

import sys
import os
import glob
import shutil
import pandas as pd
from sqlalchemy import create_engine, text
from config import DATABASE_BRONZE, get_connection_string

def find_date_dim_files():
    """Find all date dimension files in stg folder."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    stg_folder = os.path.abspath(os.path.join(script_dir, '..', '..', 'Datasets', 'stg'))
    
    all_files = []
    for pattern in ['date_dim_*.csv']:
        all_files.extend(sorted(glob.glob(os.path.join(stg_folder, pattern))))
    return all_files

def check_if_already_loaded(conn, file_name, table_name):
    """Check if file was already loaded successfully."""
    query = text("""
        SELECT COUNT(1)
        FROM FILE_LOAD_LOG
        WHERE file_name = :file_name
          AND table_name = :table_name
          AND load_status = 'SUCCESS'
    """)
    result = conn.execute(query, {'file_name': file_name, 'table_name': table_name})
    return result.scalar() > 0

def log_file_load(conn, file_name, table_name, rows_loaded, status, error_msg=None):
    """Log file load result to FILE_LOAD_LOG table."""
    query = text("""
        INSERT INTO FILE_LOAD_LOG
            (file_name, table_name, file_hash, rows_loaded, load_status, error_message)
        VALUES (:file_name, :table_name, NULL, :rows_loaded, :status, :error_msg)
    """)
    conn.execute(query, {
        'file_name': file_name,
        'table_name': table_name,
        'rows_loaded': rows_loaded,
        'status': status,
        'error_msg': error_msg
    })
    conn.commit()

def load_date_dim():
    """Load all date dimension files into STG_DATE_DIM table."""
    # Find all files
    file_paths = find_date_dim_files()
    if not file_paths:
        print("Error: No date dimension files found (date_dim_*.csv)")
        sys.exit(1)
        
    print(f"Found {len(file_paths)} date dimension file(s)")
    
    # Setup
    datasets_folder = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'Datasets'))
    processed_folder = os.path.join(datasets_folder, 'processed')
    failed_folder = os.path.join(datasets_folder, 'failed')
    
    os.makedirs(processed_folder, exist_ok=True)
    os.makedirs(failed_folder, exist_ok=True)
    
    engine = create_engine(get_connection_string(DATABASE_BRONZE))
    total_rows = success_count = failed_count = skipped_count = 0
    
    for file_path in file_paths:
        file_name = os.path.basename(file_path)
        print(f"\nProcessing: {file_name}")
        
        # Check if already loaded
        with engine.connect() as conn:
            if check_if_already_loaded(conn, file_name, 'STG_DATE_DIM'):
                print(f"  ⊗ Skipped: Already loaded successfully")
                skipped_count += 1
                continue
                
        try:
            # Read file
            df = pd.read_csv(file_path, dtype=str)
            print(f"  → Read {len(df):,} rows")
            
            # Prepare DataFrame
            df.columns = [col.upper() for col in df.columns]
            for col in ['LOADED_AT', 'IS_PROCESSED', 'SOURCE_FILE', 'ROW_HASH']:
                if col in df.columns:
                    df = df.drop(columns=[col])
                    
            df['SOURCE_FILE'] = file_name
            df = df.where(pd.notnull(df), None)
            
            # Load to MySQL (all-or-nothing with transaction)
            rows = len(df)
            with engine.begin() as conn:
                df.to_sql(name='stg_date_dim', con=conn, if_exists='append', index=False)
                log_file_load(conn, file_name, 'STG_DATE_DIM', rows, 'SUCCESS')
                
            print(f"  ✓ Successfully loaded {rows:,} rows into STG_DATE_DIM")
            
            shutil.move(file_path, os.path.join(processed_folder, file_name))
            print("  → Moved to processed/")
            
            total_rows += rows
            success_count += 1
            
        except Exception as e:
            print(f"  X Error: {e}")
            
            with engine.connect() as conn:
                log_file_load(conn, file_name, 'STG_DATE_DIM', 0, 'FAILED', str(e))
                
            shutil.move(file_path, os.path.join(failed_folder, file_name))
            print("  → Moved to failed/")
            failed_count += 1
            
    engine.dispose()
    
    # Summary
    print(f"\n{'='*60}")
    print("SUMMARY")
    print(f"{'='*60}")
    print(f"Files processed successfully: {success_count}")
    print(f"Files skipped (already loaded): {skipped_count}")
    print(f"Files failed:                 {failed_count}")
    print(f"Total rows loaded:            {total_rows:,}")
    print(f"{'='*60}")

if __name__ == '__main__':
    load_date_dim()
