import pandas as pd
import os
import glob
import matplotlib.pyplot as plt
import openpyxl

datasets_folder = os.path.join(os.path.dirname(__file__), '..', 'Datasets', 'stg')

def find_file(pattern):
    matches = sorted(glob.glob(os.path.join(datasets_folder, pattern)))
    if not matches:
        raise FileNotFoundError(f'No file found matching: {pattern}')
    return matches[-1]

# =========================================================================
# Step 1: Read the files
# =========================================================================

customers = pd.read_excel(find_file('customers_*.xlsx'))

print("Step 1: File loaded successfully!")
print("Customers :", len(customers), "rows")
print("Columns   :", list(customers.columns))

# =========================================================================
# Step 2: Show sample records
# =========================================================================

def show_sample():
    print("\n--- First 5 Customer Records ---")
    print(customers.head(5).to_string(index=False))

# =========================================================================
# Step 3: Customers by city
# =========================================================================

def customers_by_city():
    print("\n--- Customer Count by City ---")
    city_count = customers['city'].value_counts()
    for city, count in city_count.items():
        print(f" {city:<15} -> {count:,} customers")

# =========================================================================
# Step 4: Chart - Monthly signups for year 2025
# =========================================================================

def signup_2025_monthly_chart():
    customers['signup_date'] = pd.to_datetime(customers['signup_date'])
    df_2025 = customers[customers['signup_date'].dt.year == 2025]
    monthly = df_2025.groupby(df_2025['signup_date'].dt.month)['customer_id'].count().reindex(range(1, 13), fill_value=0)
    monthly.index = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

    monthly.plot(kind='bar', figsize=(10, 5), color='#4472C4', title='New Customer Signups - Month-wise (2025)')
    plt.xlabel('Month')
    plt.ylabel('Signups')
    plt.xticks(rotation=0)
    plt.tight_layout()

    charts_folder = os.path.join(os.path.dirname(__file__), '..', 'charts')
    os.makedirs(charts_folder, exist_ok=True)
    plt.savefig(os.path.join(charts_folder, 'customer_signups_2025.png'), dpi=150)
    plt.show()
    print("Chart saved: charts/customer_signups_2025.png")

# =========================================================================
# Run all steps
# =========================================================================

show_sample()
customers_by_city()
signup_2025_monthly_chart()
