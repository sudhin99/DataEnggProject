import pandas as pd
import os
import glob
import matplotlib.pyplot as plt
from datetime import datetime, date, timedelta

datasets_folder = os.path.join(os.path.dirname(__file__), '...', 'Datasets', 'stg')

def find_file(pattern):
    matches = sorted(glob.glob(os.path.join(datasets_folder, pattern)))
    if not matches:
        raise FileNotFoundError(f'No file found matching: {pattern}')
    return matches[-1]

# ================================================================
# Step 1: Read the files
# ================================================================

orders  = pd.read_csv(find_file('orders_*.csv'))
products = pd.read_csv(find_file('products_*.csv'))
stores  = pd.read_parquet(find_file('store_details_*.parquet'))

print("Step 1: Files loaded successfully!")
print("Orders   :", len(orders), "rows")
print("Columns  :", list(orders.columns))

# ================================================================
# Step 2: Look at some records
# ================================================================

def show_sample_records():
    print("\n--- First 5 Orders ---")
    print(orders.head(5))

# ================================================================
# Step 3: Basic order stats
# ================================================================

def show_basic_stats():
    print("\n--- Basic Order Statistics ---")
    print("Total Orders           :", len(orders))
    print("Total Revenue          : Rs.", orders['revenue'].sum())
    print("Average Order Value: Rs.", round(orders['revenue'].mean(), 2))
    print("Min Order Value        : Rs.", orders['revenue'].min())
    print("Max Order Value        : Rs.", orders['revenue'].max())
    print("Total Quantity Sold    :", orders['quantity'].sum())
    print("Date Range             :", orders['order_date'].min(), "to", orders['order_date'].max())

# ================================================================
# Step 4: Revenue by store
# ================================================================

def revenue_by_store():
    print("\n--- Revenue by Store ---")

    # Merge orders with store details to get store names
    orders_with_store = orders.merge(stores[['store_id', 'store_name', 'city']], on='store_id', how='left')

    store_revenue = orders_with_store.groupby(['store_id', 'store_name', 'city'])['revenue'].sum()
    store_revenue = store_revenue.sort_values(ascending=False).reset_index()

    for _, row in store_revenue.iterrows():
        print(f" {row['store_name']:<45} ({row['city']}) -> Rs. {row['revenue']:,}")

# ================================================================
# Step 5: Revenue by category
# ================================================================

def revenue_by_category():
    print("\n--- Revenue by Product Category ---")

    # Merge orders with products to get category info
    orders_with_products = orders.merge(products[['product_id', 'product_name', 'category', 'brand']], on='product_id', how='left')

    cat_revenue = orders_with_products.groupby('category')['revenue'].sum().sort_values(ascending=False)

    for category, rev in cat_revenue.items():
        print(f" {category:<25} -> Rs. {rev:,}")

# ================================================================
# Step 6: Top selling products
# ================================================================

def top_selling_products():
    # Merge orders with products
    orders_with_products = orders.merge(products[['product_id', 'product_name', 'category', 'brand']], on='product_id', how='left')

    print("\n--- Top 10 Products by Revenue ---")
    top_revenue = orders_with_products.groupby(['product_name', 'category', 'brand'])['revenue'].sum()
    top_revenue = top_revenue.sort_values(ascending=False).head(10).reset_index()
    for _, row in top_revenue.iterrows():
        print(f" {row['product_name']:<40} ({row['category']}) -> Rs. {row['revenue']:,}")

    print("\n--- Top 10 Products by Quantity Sold ---")
    top_qty = orders_with_products.groupby(['product_name', 'category'])['quantity'].sum()
    top_qty = top_qty.sort_values(ascending=False).head(10).reset_index()
    for _, row in top_qty.iterrows():
        print(f" {row['product_name']:<40} ({row['category']}) -> {row['quantity']} units")

# ================================================================
# Step 7: Monthly revenue trend
# ================================================================

def monthly_revenue_trend():
    print("\n--- Monthly Revenue Trend ---")

    # Convert order date to datetime so we can extract month and year
    orders['order_date'] = pd.to_datetime(orders['order_date'])

    monthly = orders.groupby('month')['revenue'].sum().sort_index()

    for month, rev in monthly.items():
        print(f" {month} -> Rs. {rev:,}")

# ================================================================
# Step 8: Orders by store type (via store details)
# ================================================================

def revenue_by_store_type():
    print("\n--- Revenue by Store Type ---")

    orders_with_store = orders.merge(stores[['store_id', 'store_type']], on='store_id', how='left')
    type_revenue = orders_with_store.groupby('store_type')['revenue'].sum().sort_values(ascending=False)

    for store_type, rev in type_revenue.items():
        print(f" {store_type:<15} -> Rs. {rev:,}")

    print("\n--- Order Count by Store Type ---")
    type_count = orders_with_store.groupby('store_type')['order_id'].count().sort_values(ascending=False)
    for store_type, cnt in type_count.items():
        print(f" {store_type:<15} -> {cnt:,} orders")

# ================================================================
# Step 9: datetime module scenarios
# ================================================================

def datetime_scenarios():
    print("\n" + "=" * 60)
    print("DATETIME MODULE SCENARIOS")
    print("=" * 60)

    # Convert order_date to datetime so we can do date calculations
    orders['order_date'] = pd.to_datetime(orders['order_date'])

    # ---------------------------------------------------
    # Scenario 1: Today's date and data range
    # ---------------------------------------------------

    today = date.today()
    first_order = orders['order_date'].min().date()
    last_order = orders['order_date'].max().date()

    print("\n--- Scenario 1: Date Basics ---")
    print("Today              :", today)
    print("First order date   :", first_order)
    print("Last order date    :", last_order)
    print("Days of data       :", (last_order - first_order).days)

    # ---------------------------------------------------
    # Scenario 2: Orders placed in the last 90 days
    # ---------------------------------------------------

    ninety_days_ago = pd.Timestamp.today() - timedelta(days=90)
    recent_orders = orders[ orders['order_date'] >= ninety_days_ago ]

    print("\n--- Scenario 2: Orders in Last 90 Days ---")
    print("Orders count :", len(recent_orders))
    print("Revenue      : Rs.", recent_orders['revenue'].sum())

    # ---------------------------------------------------
    # Scenario 3: Extract year and month from order date
    # ---------------------------------------------------

    orders['year'] = orders['order_date'].dt.year
    orders['month'] = orders['order_date'].dt.month

    print("\n--- Scenario 3: Revenue by Year ---")
    yearly = orders.groupby('year')['revenue'].sum()
    for year, rev in yearly.items():
        print(f" {year} -> Rs. {rev:,}")

    # ---------------------------------------------------
    # Scenario 4: Find the highest sales date and month using strftime
    # ---------------------------------------------------
    # strftime() converts a datetime into a readable string
    # %d = day, %B full month name, %Y = year, %A = weekday name

    # --- Best day ---
    daily_revenue = year_orders.groupby('order_date')['revenue'].sum()
    best_day = daily_revenue.idxmax()
    best_day_rev = daily_revenue.max()

    # --- Best month ---
    monthly_revenue = year_orders.groupby('year_month')['revenue'].sum()
    best_month = monthly_revenue.idxmax().to_timestamp()
    best_month_rev = monthly_revenue.max()

    # strftime formats the datetime into a readable string
    print("\n Year : {year}")
    print(f" Best Day   -> {best_day.strftime('%d %B %Y')} ({best_day.strftime('%A')})    | Revenue: Rs. {best_day_rev:,}")
    print(f" Best Month -> {best_month.strftime('%B %Y')}          | Revenue: Rs. {best_month_rev:,}")

# ================================================================
# Step 10: Charts using matplotlib
# ================================================================

# matplotlib is a Python library for creating charts and graphs.
# plt.figure() -> creates a new chart window
# plt.bar()    -> bar chart
# plt.pie()    -> pie chart
# plt.plot()   -> line chart
# plt.show()   -> displays all charts

def show_charts():
    orders['order_date'] = pd.to_datetime(orders['order_date'])
    orders_with_products = orders.merge(products[['product_id', 'product_name', 'category', 'brand']], on='product_id', how='left')
    orders_with_store    = orders.merge(stores[['store_id', 'store_name', 'store_type']], on='store_id', how='left')

    # ---- Chart 1: Bar chart - Revenue by Category ----
    cat_revenue = orders_with_products.groupby('category')['revenue'].sum().sort_values(ascending=False)

    plt.figure(figsize=(10, 5))
    plt.bar(cat_revenue.index, cat_revenue.values, color='steelblue')
    plt.title('Revenue by Product Category')
    plt.xlabel('Category')
    plt.ylabel('Revenue (Rs.)')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), '...', 'charts', 'revenue_by_category.png'))
    print("Chart saved: charts/revenue_by_category.png")

    # ---- Chart 2: Pie chart - Revenue share by Store Type ----
    type_revenue = orders_with_store.groupby('store_type')['revenue'].sum()

    plt.figure(figsize=(6, 6))
    plt.pie(type_revenue.values, labels=type_revenue.index, autopct='%1.1f%%', startangle=140)
    plt.title('Revenue Share by Store Type')
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), '...', 'charts', 'revenue_by_store_type.png'))
    print("Chart saved: charts/revenue_by_store_type.png")

    # ---- Chart 3: Bar chart - Revenue by Store ----
    store_rev = orders_with_store.groupby('store_name')['revenue'].sum().sort_values(ascending=False)
    short_names = [name.replace('Reliant DigiTech ', '') for name in store_rev.index]

    plt.figure(figsize=(12, 5))
    plt.bar(short_names, store_rev.values, color='coral')
    plt.title('Revenue by Store')
    plt.xlabel('Store')
    plt.ylabel('Revenue (Rs.)')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), '...', 'charts', 'revenue_by_store.png'))
    print("Chart saved: charts/revenue_by_store.png")

    # ---- Chart 4: Line chart - Monthly Revenue Trend ----
    orders['month'] = orders['order_date'].dt.to_period('M')
    monthly = orders.groupby('month')['revenue'].sum()
    months = [str(m) for m in monthly.index]

    plt.figure(figsize=(14, 5))
    plt.plot(months, monthly.values, marker='o', color='green', linewidth=2)
    plt.title('Monthly Revenue Trend')
    plt.xlabel('Month')
    plt.ylabel('Revenue (Rs.)')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), '...', 'charts', 'monthly_revenue_trend.png'))
    print("Chart saved: charts/monthly_revenue_trend.png")

    plt.show()

# ================================================================
# Run all steps
# ================================================================

show_sample_records()
show_basic_stats()
revenue_by_store()
revenue_by_category()
top_selling_products()
monthly_revenue_trend()
revenue_by_store_type()
datetime_scenarios()
show_charts()
