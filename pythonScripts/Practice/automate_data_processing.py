import os
import glob
import pandas as pd

BASE_DIR = os.path.dirname(__file__)
DATASETS_FOLDER = os.path.join(BASE_DIR, '..', 'Datasets', 'stg')
OUTPUT_FOLDER = os.path.join(BASE_DIR, '..', 'Datasets', 'processed')


def ensure_output_folder():
    os.makedirs(OUTPUT_FOLDER, exist_ok=True)


def find_dataset_file(pattern):
    path_pattern = os.path.join(DATASETS_FOLDER, pattern)
    matches = sorted(glob.glob(path_pattern))
    if not matches:
        raise FileNotFoundError(f'No file found matching: {pattern}')
    return matches[-1]


def load_file(filepath):
    if filepath.lower().endswith('.csv'):
        return pd.read_csv(filepath)
    if filepath.lower().endswith('.parquet'):
        return pd.read_parquet(filepath)
    if filepath.lower().endswith('.json'):
        return pd.read_json(filepath, lines=False)
    if filepath.lower().endswith(('.xls', '.xlsx')):
        return pd.read_excel(filepath)
    raise ValueError(f'Unsupported file type: {filepath}')


def save_cleaned_data(df, name):
    ensure_output_folder()
    output_path = os.path.join(OUTPUT_FOLDER, f'{name}.csv')
    df.to_csv(output_path, index=False)
    return output_path


def normalize_columns(df):
    df = df.copy()
    df.columns = [str(col).strip().lower().replace(' ', '_').replace('-', '_') for col in df.columns]
    return df


def transform_store_data(df):
    df = normalize_columns(df)
    str_cols = df.select_dtypes(include=['object', 'string']).columns
    for col in str_cols:
        df[col] = df[col].astype('string').str.strip()

    numeric_columns = ['store_id', 'store_area_sqft', 'store_area', 'open_year', 'latitude', 'longitude']
    for col in numeric_columns:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')

    if 'open_date' in df.columns:
        df['open_date'] = pd.to_datetime(df['open_date'], dayfirst=True, errors='coerce')
        if 'open_year' not in df.columns:
            df['open_year'] = df['open_date'].dt.year
    elif 'open_year' in df.columns:
        df['open_year'] = pd.to_numeric(df['open_year'], errors='coerce').astype('Int64')

    for col in ['store_type', 'city', 'state', 'country']:
        if col in df.columns:
            df[col] = df[col].astype('string').str.title().fillna(pd.NA)

    if 'open_year' in df.columns:
        df['store_age_years'] = pd.to_numeric(df['open_year'], errors='coerce')
        df['store_age_years'] = pd.to_datetime(df['store_age_years'], format='%Y', errors='coerce').dt.year
        current_year = pd.Timestamp.today().year
        df['store_age_years'] = current_year - df['open_year']
        df['store_age_years'] = df['store_age_years'].where(df['store_age_years'] >= 0)

    if 'store_area_sqft' in df.columns:
        df['store_area_sqft'] = pd.to_numeric(df['store_area_sqft'], errors='coerce')
        df['store_area_sqm'] = (df['store_area_sqft'] * 0.092903).round(2)

    df = df.drop_duplicates()
    return df


def transform_orders_data(df):
    df = normalize_columns(df)
    df['order_date'] = pd.to_datetime(df['order_date'], dayfirst=True, errors='coerce')
    if 'quantity' in df.columns:
        df['quantity'] = pd.to_numeric(df['quantity'], errors='coerce')
    if 'revenue' in df.columns:
        df['revenue'] = pd.to_numeric(df['revenue'], errors='coerce')
    df['order_year'] = df['order_date'].dt.year
    df['order_month'] = df['order_date'].dt.to_period('M')
    df = df.drop_duplicates()
    return df


def transform_products_data(df):
    df = normalize_columns(df)
    for col in ['selling_price', 'purchase_price', 'cost_price', 'list_price']:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')
    if 'selling_price' in df.columns and 'purchase_price' in df.columns:
        df['margin_pct'] = ((df['selling_price'] - df['purchase_price']) / df['purchase_price'] * 100).round(2)
    df = df.drop_duplicates()
    return df


def transform_inventory_data(df):
    df = normalize_columns(df)
    if 'inventory_date' in df.columns:
        df['inventory_date'] = pd.to_datetime(df['inventory_date'], errors='coerce')
    for col in ['quantity', 'opening_stock', 'closing_stock']:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')
    df = df.drop_duplicates()
    return df


def transform_feedback_data(df):
    df = normalize_columns(df)
    if 'date' in df.columns:
        df['date'] = pd.to_datetime(df['date'], dayfirst=True, errors='coerce')
        df['year_month'] = df['date'].dt.to_period('M')
    if 'rating' in df.columns:
        df['rating'] = pd.to_numeric(df['rating'], errors='coerce')
    df = df.drop_duplicates()
    return df


def transform_customers_data(df):
    df = normalize_columns(df)
    str_cols = df.select_dtypes(include=['object', 'string']).columns
    for col in str_cols:
        df[col] = df[col].astype('string').str.strip()
    df = df.drop_duplicates()
    return df


def process_all_datasets():
    outputs = []

    store_file = find_dataset_file('store*.parquet')
    store_df = load_file(store_file)
    cleaned_store = transform_store_data(store_df)
    outputs.append(save_cleaned_data(cleaned_store, 'cleaned_stores'))

    orders_file = find_dataset_file('orders_*.csv')
    orders_df = load_file(orders_file)
    cleaned_orders = transform_orders_data(orders_df)
    outputs.append(save_cleaned_data(cleaned_orders, 'cleaned_orders'))

    products_file = find_dataset_file('products_*.csv')
    products_df = load_file(products_file)
    cleaned_products = transform_products_data(products_df)
    outputs.append(save_cleaned_data(cleaned_products, 'cleaned_products'))

    inventory_file = find_dataset_file('inventory_*.csv')
    inventory_df = load_file(inventory_file)
    cleaned_inventory = transform_inventory_data(inventory_df)
    outputs.append(save_cleaned_data(cleaned_inventory, 'cleaned_inventory'))

    feedback_file = find_dataset_file('customer_feedback*.csv')
    feedback_df = load_file(feedback_file)
    cleaned_feedback = transform_feedback_data(feedback_df)
    outputs.append(save_cleaned_data(cleaned_feedback, 'cleaned_feedback'))

    customer_file = find_dataset_file('customers_*.xlsx')
    customer_df = load_file(customer_file)
    cleaned_customers = transform_customers_data(customer_df)
    outputs.append(save_cleaned_data(cleaned_customers, 'cleaned_customers'))

    return outputs


def summary():
    cleaned_paths = process_all_datasets()
    print('Processed datasets saved to:', OUTPUT_FOLDER)
    for path in cleaned_paths:
        print(' -', path)


if __name__ == '__main__':
    try:
        summary()
    except Exception as exc:
        print('Error during automated data processing:', exc)
        raise
