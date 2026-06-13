import pandas as pd
from sqlalchemy import create_engine

# Database Connection String
connection_string = 'mysql+pymysql://root:your_password@localhost/RELIANT_DWH_'

def load_customers():
    """Simple customer data load to MySQL"""
    
    # Step 1: Read data to dataframe
    file_path = 'Datasets/stg/customers_*.xlsx'  # Adjust path as needed
    print(f"Reading file: {file_path}")
    df = pd.read_excel(file_path)
    print(f"✓ Read {len(df)} rows")
    
    # Prepare data
    df.columns = [col.upper() for col in df.columns]
    
    # Step 2: Load dataframe to SQL
    engine = create_engine(connection_string)
    df.to_sql('STG_CUSTOMERS', engine, if_exists='replace', index=False)
    print(f"✓ Loaded {len(df)} rows into STG_CUSTOMERS")

if __name__ == "__main__":
    load_customers()
