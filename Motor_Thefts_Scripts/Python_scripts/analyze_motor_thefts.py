import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[2]
PROCESSED_DIR = BASE_DIR / 'datasets' / 'Motor_Therfts' / 'Processed'


def load_data() -> pd.DataFrame:
    stolen_path = PROCESSED_DIR / 'stolen_vehicles_cleaned.csv'
    location_path = PROCESSED_DIR / 'locations_cleaned.csv'

    stolen = pd.read_csv(stolen_path, dtype=str)
    locations = pd.read_csv(location_path, dtype=str)

    stolen['date_stolen'] = pd.to_datetime(stolen['date_stolen'], errors='coerce')
    stolen['model_year'] = pd.to_numeric(stolen['model_year'], errors='coerce').astype('Int64')
    stolen['vehicle_id'] = pd.to_numeric(stolen['vehicle_id'], errors='coerce').astype('Int64')
    stolen['make_id'] = pd.to_numeric(stolen['make_id'], errors='coerce').astype('Int64')
    stolen['location_id'] = pd.to_numeric(stolen['location_id'], errors='coerce').astype('Int64')

    locations['location_id'] = pd.to_numeric(locations['location_id'], errors='coerce').astype('Int64')
    locations['population'] = pd.to_numeric(locations['population'], errors='coerce').astype('Int64')
    locations['density'] = pd.to_numeric(locations['density'], errors='coerce')

    merged = stolen.merge(locations, on='location_id', how='left', suffixes=('', '_region'))
    return stolen, merged


def theft_weekday_summary(stolen: pd.DataFrame) -> pd.DataFrame:
    """Return counts of stolen vehicles by weekday."""
    df = stolen.dropna(subset=['date_stolen']).copy()
    df['weekday'] = df['date_stolen'].dt.day_name()
    counts = df['weekday'].value_counts().rename_axis('weekday').reset_index(name='count')
    return counts.sort_values('count', ascending=False)


def most_least_stolen_weekdays(stolen: pd.DataFrame) -> dict:
    counts = theft_weekday_summary(stolen)
    if counts.empty:
        return {}
    return {
        'most_often': counts.iloc[0].to_dict(),
        'least_often': counts.iloc[-1].to_dict(),
        'weekday_counts': counts,
    }


def vehicle_type_counts(stolen: pd.DataFrame) -> pd.DataFrame:
    """Return overall counts per vehicle type."""
    counts = stolen['vehicle_type'].fillna('Unknown').value_counts().rename_axis('vehicle_type').reset_index(name='count')
    return counts


def vehicle_type_by_region(merged: pd.DataFrame) -> pd.DataFrame:
    """Return counts of vehicle types grouped by region."""
    df = merged.copy()
    df['region'] = df['region'].fillna('Unknown')
    df['vehicle_type'] = df['vehicle_type'].fillna('Unknown')
    counts = (
        df.groupby(['region', 'vehicle_type'])
          .size()
          .reset_index(name='count')
          .sort_values(['region', 'count'], ascending=[True, False])
    )
    return counts


def average_stolen_vehicle_age(stolen: pd.DataFrame) -> pd.DataFrame:
    """Compute average vehicle age at time of theft."""
    df = stolen.dropna(subset=['date_stolen', 'model_year']).copy()
    df['stolen_year'] = df['date_stolen'].dt.year
    df['age_at_theft'] = df['stolen_year'] - df['model_year']
    df = df[df['age_at_theft'].notna()]
    summary = df['age_at_theft'].mean()
    return summary


def average_age_by_vehicle_type(stolen: pd.DataFrame) -> pd.DataFrame:
    """Compute average age of stolen vehicles by vehicle type."""
    df = stolen.dropna(subset=['date_stolen', 'model_year']).copy()
    df['stolen_year'] = df['date_stolen'].dt.year
    df['age_at_theft'] = df['stolen_year'] - df['model_year']
    df = df[df['age_at_theft'].notna()].copy()
    df['vehicle_type'] = df['vehicle_type'].fillna('Unknown')
    grouped = (
        df.groupby('vehicle_type')['age_at_theft']
          .mean()
          .round(2)
          .reset_index()
          .sort_values('age_at_theft', ascending=False)
    )
    return grouped


def region_theft_characteristics(merged: pd.DataFrame) -> dict:
    """Return theft counts and region characteristics."""
    df = merged.copy()
    df['region'] = df['region'].fillna('Unknown')
    region_counts = (
        df.groupby(['region', 'country', 'population', 'density'])
          .size()
          .reset_index(name='stolen_count')
          .sort_values('stolen_count', ascending=False)
    )

    most = region_counts.iloc[0].to_dict() if not region_counts.empty else {}
    least = region_counts.iloc[-1].to_dict() if not region_counts.empty else {}

    return {
        'most_stolen_region': most,
        'least_stolen_region': least,
        'region_summary': region_counts,
    }


def run_analysis() -> None:
    _, merged = load_data()
    stolen = merged.drop(columns=['region', 'country', 'population', 'density'])

    weekday = most_least_stolen_weekdays(merged)
    vehicle_counts = vehicle_type_counts(merged)
    vehicle_by_region = vehicle_type_by_region(merged)
    avg_age = average_stolen_vehicle_age(merged)
    avg_age_by_type = average_age_by_vehicle_type(merged)
    region_summary = region_theft_characteristics(merged)

    print('\n=== Weekday Theft Summary ===')
    print('Most often stolen:', weekday.get('most_often'))
    print('Least often stolen:', weekday.get('least_often'))
    print('\nFull weekday counts:')
    print(weekday.get('weekday_counts').to_string(index=False))

    print('\n=== Vehicle Type Theft Summary ===')
    print(vehicle_counts.to_string(index=False))

    print('\n=== Vehicle Type Theft by Region ===')
    print(vehicle_by_region.to_string(index=False))

    print('\n=== Average Stolen Vehicle Age ===')
    print('Overall average age at theft:', round(avg_age, 2) if avg_age is not None else 'N/A')
    print('\nAverage age by vehicle type:')
    print(avg_age_by_type.to_string(index=False))

    print('\n=== Region Theft Characteristics ===')
    print('Most stolen region:', region_summary['most_stolen_region'])
    print('Least stolen region:', region_summary['least_stolen_region'])
    print('\nRegion characteristics:')
    print(region_summary['region_summary'].to_string(index=False))


if __name__ == '__main__':
    run_analysis()
