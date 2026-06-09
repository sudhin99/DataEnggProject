import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[2]
RAW_DIR = BASE_DIR / 'datasets' / 'Motor_Therfts' / 'Raw'
PROCESSED_DIR = BASE_DIR / 'datasets' / 'Motor_Therfts' / 'Processed'

OUTPUT_SUFFIX = '_cleaned.csv'


def normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df.columns = [
        str(col).strip().lower().replace(' ', '_').replace('-', '_')
        for col in df.columns
    ]
    return df


def clean_locations(df: pd.DataFrame) -> pd.DataFrame:
    df = normalize_columns(df)
    if 'location_id' in df.columns:
        df['location_id'] = pd.to_numeric(df['location_id'], errors='coerce').astype('Int64')
    for col in ['region', 'country']:
        if col in df.columns:
            df[col] = df[col].astype('string').str.strip().replace('', pd.NA)
    if 'population' in df.columns:
        df['population'] = (
            df['population']
            .astype('string')
            .str.replace(',', '', regex=False)
            .str.strip()
        )
        df['population'] = pd.to_numeric(df['population'], errors='coerce').astype('Int64')
    if 'density' in df.columns:
        df['density'] = pd.to_numeric(df['density'], errors='coerce')
    df = df.drop_duplicates()
    return df


def clean_make_details(df: pd.DataFrame) -> pd.DataFrame:
    df = normalize_columns(df)
    if 'make_id' in df.columns:
        df['make_id'] = pd.to_numeric(df['make_id'], errors='coerce').astype('Int64')
    if 'make_name' in df.columns:
        df['make_name'] = df['make_name'].astype('string').str.strip().replace('', pd.NA)
    if 'make_type' in df.columns:
        df['make_type'] = (
            df['make_type']
            .astype('string')
            .str.strip()
            .str.title()
            .replace({'Standard': 'Standard', 'Luxury': 'Luxury'})
        )
        df['make_type'] = df['make_type'].where(df['make_type'].isin(['Standard', 'Luxury']), pd.NA)
    df = df.drop_duplicates()
    return df


def clean_data_dictionary(df: pd.DataFrame) -> pd.DataFrame:
    df = normalize_columns(df)
    for col in df.columns:
        df[col] = df[col].astype('string').str.strip().replace('', pd.NA)
    required_columns = ['table', 'field']
    for col in required_columns:
        if col not in df.columns:
            raise ValueError(f'Expected column {col} in data dictionary file')
    df = df.dropna(subset=required_columns)
    df = df.drop_duplicates()
    return df


def clean_stolen_vehicles(df: pd.DataFrame) -> pd.DataFrame:
    df = normalize_columns(df)
    if 'vehicle_id' in df.columns:
        df['vehicle_id'] = pd.to_numeric(df['vehicle_id'], errors='coerce').astype('Int64')
    if 'make_id' in df.columns:
        df['make_id'] = pd.to_numeric(df['make_id'], errors='coerce').astype('Int64')
    if 'model_year' in df.columns:
        df['model_year'] = pd.to_numeric(df['model_year'], errors='coerce').astype('Int64')
    if 'location_id' in df.columns:
        df['location_id'] = pd.to_numeric(df['location_id'], errors='coerce').astype('Int64')
    for col in ['vehicle_type', 'vehicle_desc', 'color']:
        if col in df.columns:
            df[col] = df[col].astype('string').str.strip().replace('', pd.NA)
    if 'date_stolen' in df.columns:
        df['date_stolen'] = pd.to_datetime(df['date_stolen'], dayfirst=True, errors='coerce')
    df = df.drop_duplicates(subset=df.columns.tolist())
    if 'vehicle_id' in df.columns:
        df = df.drop_duplicates(subset=['vehicle_id'])
    return df


def save_cleaned(df: pd.DataFrame, source_path: Path) -> Path:
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    output_path = PROCESSED_DIR / (source_path.stem.replace('_uncleaned', '') + OUTPUT_SUFFIX)
    df.to_csv(output_path, index=False)
    return output_path


def main() -> None:
    file_map = {
        'locations_uncleaned.csv': clean_locations,
        'make_details_uncleaned.csv': clean_make_details,
        'stolen_vehicles_db_data_dictionary_uncleaned.csv': clean_data_dictionary,
        'stolen_vehicles_uncleaned.csv': clean_stolen_vehicles,
    }

    for file_name, cleaner in file_map.items():
        source_path = RAW_DIR / file_name
        if not source_path.exists():
            raise FileNotFoundError(f'Missing input file: {source_path}')
        df = pd.read_csv(source_path, dtype=str)
        cleaned = cleaner(df)
        output_path = save_cleaned(cleaned, source_path)
        print(f'Cleaned {source_path.name} -> {output_path.name}')


if __name__ == '__main__':
    main()
