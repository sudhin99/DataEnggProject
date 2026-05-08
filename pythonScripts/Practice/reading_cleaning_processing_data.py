import os
import glob
import pandas as pd
from datetime import date

base_dir = os.path.dirname(__file__)
datasets_folder = os.path.join(base_dir, '..', 'Datasets', 'stg')


def find_store_file(pattern='store*.parquet'):
    """Find the latest store file matching the given pattern."""
    path_pattern = os.path.join(datasets_folder, pattern)
    matches = sorted(glob.glob(path_pattern))
    if not matches:
        raise FileNotFoundError(f'No file found matching: {pattern} in {datasets_folder}')
    return matches[-1]


def load_store_data(pattern='store*.parquet', fallback_csv_patterns=None):
    """Load store data from a Parquet file, optionally falling back to CSV files."""
    filepath = None
    try:
        filepath = find_store_file(pattern)
    except FileNotFoundError:
        if fallback_csv_patterns:
            for csv_pattern in fallback_csv_patterns:
                try:
                    filepath = find_store_file(csv_pattern)
                    break
                except FileNotFoundError:
                    continue
        if filepath is None:
            raise

    if filepath.lower().endswith('.parquet'):
        df = pd.read_parquet(filepath)
    elif filepath.lower().endswith('.csv'):
        df = pd.read_csv(filepath)
    else:
        raise ValueError(f'Unsupported file type: {filepath}')

    df = clean_store_data(df)
    df.attrs['source_file'] = os.path.basename(filepath)
    return df


def clean_store_data(df):
    """Clean and normalize store data.

    The function performs the following steps:
    - normalize column names
    - trim string fields
    - parse numeric fields
    - parse date/year fields
    - drop exact duplicate rows
    - calculate store age when possible
    """
    df = df.copy()

    # Normalize columns
    df.columns = [str(col).strip().lower().replace(' ', '_').replace('-', '_') for col in df.columns]

    # Trim whitespace from string columns
    str_cols = df.select_dtypes(include=['object', 'string']).columns
    for col in str_cols:
        df[col] = df[col].astype('string').str.strip()

    # Common numeric columns to normalize
    numeric_columns = ['store_id', 'store_area_sqft', 'store_area', 'open_year', 'latitude', 'longitude']
    for col in numeric_columns:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')

    # Parse date columns if they exist
    if 'open_date' in df.columns:
        df['open_date'] = pd.to_datetime(df['open_date'], dayfirst=True, errors='coerce')
        if 'open_year' not in df.columns:
            df['open_year'] = df['open_date'].dt.year
    elif 'open_year' in df.columns:
        df['open_year'] = pd.to_numeric(df['open_year'], errors='coerce').astype('Int64')

    # Ensure store_id is present for deduplication and joining
    if 'store_id' not in df.columns:
        raise ValueError('Loaded store data must contain a store_id column')

    # Drop exact duplicate rows
    df = df.drop_duplicates()

    # Normalize category-like columns
    for col in ['store_type', 'city', 'state', 'country']:
        if col in df.columns:
            df[col] = df[col].astype('string').str.title().fillna(pd.NA)

    # Add derived columns
    if 'open_year' in df.columns:
        current_year = date.today().year
        df['store_age_years'] = current_year - df['open_year']
        df['store_age_years'] = df['store_age_years'].where(df['store_age_years'] >= 0)

    if 'store_area_sqft' in df.columns:
        df['store_area_sqft'] = pd.to_numeric(df['store_area_sqft'], errors='coerce')
        df['store_area_sqm'] = (df['store_area_sqft'] * 0.092903).round(2)

    return df


def summarize_store_data(df):
    """Return a small summary of the cleaned store data."""
    summary = {
        'rows': len(df),
        'columns': list(df.columns),
        'duplicate_store_ids': int(df['store_id'].duplicated().sum()) if 'store_id' in df.columns else None,
    }

    if 'store_type' in df.columns:
        summary['store_type_counts'] = df['store_type'].value_counts(dropna=False).to_dict()
    if 'city' in df.columns:
        summary['store_city_counts'] = df['city'].value_counts(dropna=False).to_dict()
    if 'store_area_sqft' in df.columns:
        summary['area_min_sqft'] = float(df['store_area_sqft'].min())
        summary['area_max_sqft'] = float(df['store_area_sqft'].max())
        summary['area_mean_sqft'] = float(df['store_area_sqft'].mean())
    return summary


if __name__ == '__main__':
    try:
        df = load_store_data(
            pattern='store*.parquet',
            fallback_csv_patterns=['Reliant_DigiTech_Store_Details.csv', '*store*details*.csv']
        )
        print('Loaded store data from:', df.attrs.get('source_file', 'unknown'))
        print('Rows:', len(df))
        print('Columns:', list(df.columns))
        print('Store type counts:')
        if 'store_type' in df.columns:
            print(df['store_type'].value_counts())
        print('Sample records:')
        print(df.head().to_string(index=False))
    except Exception as error:
        print('Error loading store data:', error)
        raise
