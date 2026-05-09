import os
import glob
import pandas as pd
import requests
import numpy as np

# Set up the datasets folder path
datasets_folder = os.path.join(os.path.dirname(__file__), '..', 'Datasets', 'stg')

def find_file(pattern):
    matches = sorted(glob.glob(os.path.join(datasets_folder, pattern)))
    if not matches:
        raise FileNotFoundError(f'No file found matching: {pattern}')
    return matches[-1]

# =============================================================================
# Step 1: Load products data
# =============================================================================

products = pd.read_csv(find_file('products_*.csv'))

print("Products loaded:", len(products), "rows")
print("Columns        :", list(products.columns))

# =============================================================================
# Step 2: Fetch live INR -> USD rate from Frankfurter API
# =============================================================================

# Example API response structure:
# {
#   "date": "2025-05-09",
#   "rates": { "USD": 0.012, "EUR": 0.011 }
# }

url = "https://api.frankfurter.app/latest?from=INR&to=USD,EUR"

print("\nCalling Frankfurter API...")
response = requests.get(url, timeout=10)

if response.status_code != 200:
    print(f"API call failed - status: {response.status_code}")
    exit()

data = response.json()
usd_rate = data['rates']['USD']
eur_rate = data['rates']['EUR']

print(f"Rates fetched successfully! (as of {data['date']})")
print(f"  1 INR = {usd_rate} USD")
print(f"  1 INR = {eur_rate} EUR")

# =============================================================================
# Step 3: Perform Currency Conversion (Implicitly implied by later steps)
# =============================================================================
products['mrp_usd'] = products['mrp'] * usd_rate
products['mrp_eur'] = products['mrp'] * eur_rate

# =============================================================================
# Step 4: Display the converted prices
# =============================================================================

print("\n--- Product Prices with Currency Conversion ---\n")

display_cols = ['product_name', 'category', 'mrp', 'mrp_usd', 'mrp_eur']
print(products[display_cols].to_string(index=False))

# =============================================================================
# Step 5: Show most expensive products in USD
# =============================================================================

print("\n--- Top 5 Most Expensive Products (in USD) ---")
top5 = products.sort_values('mrp_usd', ascending=False).head(5)
for _, row in top5.iterrows():
    print(f" {row['product_name']:<30} ₹{row['mrp']:,} = ${row['mrp_usd']:,}")

# =============================================================================
# Step 6: Statistics using NumPy
# =============================================================================

mrp_array = np.array(products['mrp'])
usd_array = np.array(products['mrp_usd'])

print("\n--- MRP Statistics (numpy) ---")
print(f" Mean MRP   : ₹{np.mean(mrp_array):,.2f} = ${np.mean(usd_array):,.2f}")
print(f" Median MRP : ₹{np.median(mrp_array):,.2f} = ${np.median(usd_array):,.2f}")
print(f" Std Dev    : ₹{np.std(mrp_array):,.2f} = ${np.std(usd_array):,.2f}")
print(f" Min MRP    : ₹{np.min(mrp_array):,.2f} = ${np.min(usd_array):,.2f}")
print(f" Max MRP    : ₹{np.max(mrp_array):,.2f} = ${np.max(usd_array):,.2f}")

# =============================================================================
# Step 7: NumPy - Price bucket counts using np.digitize
# =============================================================================

# np.digitize() assigns each price to a bucket based on defined thresholds
# Think of it like putting products into price shelves in a store

buckets = [0, 2000, 10000, 30000, 60000, np.inf]
bucket_names = ['Budget (<2K)', 'Economy (2K-10K)', 'Mid (10K-30K)', 'Premium (30K-60K)', 'Luxury (60K+)']

bucket_index = np.digitize(mrp_array, buckets) - 1
products['price_bucket'] = [bucket_names[i] for i in bucket_index]

print("\n--- Products by Price Bucket (numpy digitize) ---")
print(products['price_bucket'].value_counts().to_string())

# =============================================================================
# Step 8: Save to CSV
# =============================================================================

output_folder = os.path.join(os.path.dirname(__file__), '..', 'data_output')
os.makedirs(output_folder, exist_ok=True)
output_path = os.path.join(output_folder, 'products_with_usd.csv')
products.to_csv(output_path, index=False)
print(f"\nSaved: data_output/products_with_usd.csv")
