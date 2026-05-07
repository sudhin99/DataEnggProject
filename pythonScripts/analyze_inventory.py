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
# Step 1: Read the files
# ================================================================
# inventory.csv has stock movement data: quantity sold, opening and closing stock
# We also load products to get product names and categories

inventory = pd.read_csv(find_file('inventory_*.csv'))
products  = pd.read_csv(find_file('products_*.csv'))

print("Step 1: Files loaded successfully!")
print("Inventory rows :", len(inventory))
print("Column names   :", list(inventory.columns))
print("Inventory data :", inventory['inventory_date'].iloc[0])

# Join product name and category into inventory for easier reading
# merge() combines two tables on a common column (product_id)
inventory = inventory.merge(products[['product_id', 'product_name', 'category']], on='product_id', how='left')

# ================================================================
# Step 2: Show some records
# ================================================================

def show_sample():
    print("\n--- First 5 Inventory Records ---")
    print(inventory[['store_id', 'product_name', 'category', 'quantity', 'opening_stock', 'closing_stock', 'inventory_date']].head(5).to_string(index=False))

# ================================================================
# Step 3: Overall stock summary
# ================================================================

def stock_summary():
    print("\n--- Overall Inventory Summary ---")
    print("Total quantity sold     :", inventory['quantity'].sum())
    print("Total opening stock     :", inventory['opening_stock'].sum())
    print("Total closing stock     :", inventory['closing_stock'].sum())

    # Check if any product has zero or negative closing stock
    low_stock = inventory[ inventory['closing_stock'] <= 0 ]
    print("Products with zero/negative closing stock:", len(low_stock))

# ================================================================
# Step 4: Which products sold the most?
# ================================================================

def top_selling_products():
    print("\n--- Top 10 Products by Quantity Sold (across all stores) ---")

    # groupby groups rows with the same product and sums their quantity
    top = inventory.groupby(['product_name', 'category'])['quantity'].sum()
    top = top.sort_values(ascending=False).head(10).reset_index()

    for _, row in top.iterrows():
        print(f" {row['product_name']:<40} ({row['category']}) -> {row['quantity']:,} units sold")

# ================================================================
# Step 5: Which category sold the most?
# ================================================================

def sales_by_category():
    print("\n--- Total Quantity Sold by Category ---")

    cat_qty = inventory.groupby('category')['quantity'].sum().sort_values(ascending=False)
    for category, qty in cat_qty.items():
        print(f" {category:<25} -> {qty:,} units")

# ================================================================
# Step 6: Which store has the most closing stock left?
# ================================================================

def stock_by_store():
    print("\n--- Closing Stock Remaining by Store ---")

    store_stock = inventory.groupby('store_id')['closing_stock'].sum().sort_values(ascending=False)
    for store_id, stock in store_stock.items():
        print(f" Store {store_id} -> {stock:,} units remaining")

# ================================================================
# Step 7: Products with lowest closing stock (may need restocking)
# ================================================================

def low_stock_alert():
    print("\n--- Products with Lowest Closing Stock (Top 10) ---")

    low = inventory.groupby(['product_name', 'category'])['closing_stock'].sum()
    low = low.sort_values(ascending=True).head(10).reset_index()

    for _, row in low.iterrows():
        print(f" {row['product_name']:<40} ({row['category']}) -> {row['closing_stock']} units left")

# ================================================================
# Run all steps
# ================================================================

show_sample()
stock_summary()
top_selling_products()
sales_by_category()
stock_by_store()
low_stock_alert()
