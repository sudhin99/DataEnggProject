import pandas as pd
from sqlalchemy import create_engine, text

# Database Connection String
connection_string = 'mysql+pymysql://root:MyNewPass%401@localhost/RELIANT_DWH_BRONZE'

def load_customers():
    """Simple customer data load to MySQL"""
    
    # Step 1: Read data to dataframe
    file_path = r'C:\Users\1e\Documents\workspace\DataEnggProject\datasets\Reliant_Digitech\stg\customers_20260424_135553.xlsx'  
    print(f"Reading file: {file_path}")
    df = pd.read_excel(file_path)
    print(f"✓ Read {len(df)} rows")
    
    # Prepare data
    df.columns = [col.upper() for col in df.columns]
    
    # Step 2: Load dataframe to SQL
    engine = create_engine(connection_string)
    with engine.begin() as conn:
        conn.execute(text("TRUNCATE TABLE STG_CUSTOMERS;"))
    print(f"Truncated table STG_CUSTOMERS")
    df.to_sql('STG_CUSTOMERS', engine, if_exists='append', index=False)
    print(f"✓ Loaded {len(df)} rows into STG_CUSTOMERS")

if __name__ == "__main__":
    load_customers()
