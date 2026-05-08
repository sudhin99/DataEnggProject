import pandas as pd
import os
import glob

datasets_folder = os.path.join(os.path.dirname(__file__), '..', 'Datasets', 'stg')

def find_file(pattern):
    matches = sorted(glob.glob(os.path.join(datasets_folder, pattern)))
    if not matches:
        raise FileNotFoundError(f'No file found matching: {pattern}')
    return matches[-1]

# ================================================================
# Step 1: Read the file
# ================================================================
# store details are available as parquet files in the Datasets/stg folder

file_path = find_file('store_details_*.parquet')
df = pd.read_parquet(file_path)

print(f"Step 1: File loaded successfully! ({os.path.basename(file_path)})")
print("Total rows   :", len(df))
print("Total columns:", len(df.columns))
print("Column names :", list(df.columns))

# ================================================================
# Step 2: Look at all records (only 10 stores)
# ================================================================

def show_all_stores():
    print("\n--- All Stores ---")
    print(df.to_string(index=False))

# ================================================================
# Step 3: Store type breakdown
# ================================================================

def store_type_breakdown():
    print("\n--- Stores by Type ---")
    type_count = df['store_type'].value_counts()
    for store_type, count in type_count.items():
        print(f" {store_type:<15} -> {count} stores")

    print("\n--- Stores by City ---")
    city_count = df['city'].value_counts()
    for city, count in city_count.items():
        print(f" {city:<15} -> {count} stores")

    print("\n--- Stores by State ---")
    state_count = df['state'].value_counts()
    for state, count in state_count.items():
        print(f" {state:<10} -> {count} stores")

# ================================================================
# Step 4: Store area analysis
# ================================================================

def store_area_analysis():
    print("\n--- Store Area (sqft) Summary ---")
    print("Smallest store :", df['store_area_sqft'].min(), "sqft")
    print("Largest store  :", df['store_area_sqft'].max(), "sqft")
    print("Average area   :", df['store_area_sqft'].mean(), "sqft")

    print("\n--- Store Area by Type ---")
    area_by_type = df.groupby('store_type')['store_area_sqft'].mean().round(0).sort_values(ascending=False)
    for store_type, avg_area in area_by_type.items():
        print(f" {store_type:<15} -> Avg {avg_area:,.0f} sqft")

    print("\n--- All Stores Sorted by Area (Largest First) ---")
    sorted_df = df.sort_values('store_area_sqft', ascending=False)
    for _, row in sorted_df.iterrows():
        print(f" {row['store_name']:<45} -> {row['store_area_sqft']:,} sqft")

# ================================================================
# Step 5: How old are the stores?
# ================================================================

def store_age_analysis():
    from datetime import date

    current_year = date.today().year

    # Calculate how many years each store has been open
    df['store_age_years'] = current_year - df['open_year']

    print("\n--- Store Age (years open) ---")
    for _, row in df.sort_values('open_year').iterrows():
        print(f" {row['store_name']:<45} -> Opened {row['open_year']} ({row['store_age_years']} years)")

    print("\n--- Oldest and Newest Store ---")
    oldest = df[ df['open_year'] == df['open_year'].min() ].iloc[0]
    newest = df[ df['open_year'] == df['open_year'].max() ].iloc[0]
    print(f" Oldest  -> {oldest['store_name']} (opened {oldest['open_year']})")
    print(f" Newest  -> {newest['store_name']} (opened {newest['open_year']})")

# ================================================================
# Run all steps
# ================================================================

show_all_stores()
store_type_breakdown()
store_area_analysis()
store_age_analysis()
