import pandas as pd
import os
import glob

datasets_folder = os.path.join(os.path.dirname(__file__), '..', 'Datasets', 'stg')

def find_file(pattern):
    matches = sorted(glob.glob(os.path.join(datasets_folder, pattern)))
    if not matches:
        raise FileNotFoundError(f'No file found matching: {pattern}')
    return matches[-1]

# pd.read_csv() reads a CSV file and stores it as a DataFrame (like a table)
file_path = find_file('products_*.csv')
df = pd.read_csv(file_path)
print(f"Step 1: File loaded successfully! ({os.path.basename(file_path)})")

# Calculate profit margin % column once - used across all functions
# margin % = (selling price - purchase price) / purchase price * 100
df['margin_pct'] = ((df['selling_price'] - df['purchase_price']) / df['purchase_price'] * 100).round(2)

print("Step 1: File loaded successfully!")
print("Total rows   :", len(df))
print("Total columns:", len(df.columns))
print("Column names :", list(df.columns))

# ================================================================
# Step 2: Look at some records
# ================================================================

def show_sample_records():
    # df.head(5) shows the first 5 rows
    print("\n--- First 5 records ---")
    print(df.head(5))

# ================================================================
# Step 3: What products are available?
# ================================================================

def show_products_available():
    # value_counts() counts how many times each value appear
    print("\n--- Product Categories ---")
    print(df['category'].value_counts())

    print("\n--- Brands Available ---")
    print(df['brand'].value_counts())

# ================================================================
# Step 4: Costliest product
# ================================================================

def show_costliest_products():
    # df['column'].max() gives the maximum value
    # df[ df['column'] == value ] filters rows matching a condition
    most_expensive_price = df['selling_price'].max()
    most_expensive_product = df[ df['selling_price'] == most_expensive_price ]

    print("\n--- Costliest Product Overall (by Selling Price) ---")
    print(most_expensive_product[['product_name', 'category', 'brand', 'selling_price']])

    print("\n--- Costliest Product in Each Category ---")
    for category in df['category'].unique():
        category_df = df[ df['category'] == category ]
        max_price = category_df['selling_price'].max()
        top_product = category_df[ category_df['selling_price'] == max_price ].iloc[0]
        print(f" ({category:<25}) -> {top_product['product_name']} at Rs.{max_price}")

# ================================================================
# Step 5: Price summary
# ================================================================

def show_price_summary():
    # mean() / min() / max() give basic statistics
    print("\n--- Selling Price Summary ---")
    print("Minimum price :", df['selling_price'].min())
    print("Maximum price :", df['selling_price'].max())
    print("Average price :", round(df['selling_price'].mean(), 2))

    print("\n--- Average Selling Price by Category ---")
    avg_by_category = df.groupby('category')['selling_price'].mean().round(2).sort_values(ascending=False)
    print(avg_by_category)

# ================================================================
# Step 6: Category-wise Profit Margin Details
# ================================================================
# This shows a detailed profit margin breakdown for each category:
# - How many products in the category
# - Average, min and max margin %
# - Best and worst margin product in that category

def category_profit_margin():
    print("\n" + "=" * 60)
    print("CATEGORY-WISE PROFIT MARGIN DETAILS")
    print("=" * 60)

    print("\n--- Overall Profit Margin Summary ---")
    print("Lowest margin  :", df['margin_pct'].min(), "%")
    print("Highest margin :", df['margin_pct'].max(), "%")
    print("Average margin :", round(df['margin_pct'].mean(), 2), "%")

    print("\n--- Detailed Margin Breakdown by Category ---")

    # Sort categories by average margin (highest first)
    categories_sorted = df.groupby('category')['margin_pct'].mean().sort_values(ascending=False).index

    for category in categories_sorted:
        # Filter rows for this category
        cat_df = df[ df['category'] == category ]

        avg_margin = round(cat_df['margin_pct'].mean(), 2)
        min_margin = cat_df['margin_pct'].min()
        max_margin = cat_df['margin_pct'].max()

        # Product with best margin in this category
        best_product = cat_df[ cat_df['margin_pct'] == max_margin ].iloc[0]
        # Product with worst margin in this category
        worst_product = cat_df[ cat_df['margin_pct'] == min_margin ].iloc[0]

        print(f"\n Category : {category}")
        print(f" Products : {len(cat_df)}")
        print(f" Avg Margin : {avg_margin}%     |    Min: {min_margin}%    |    Max: {max_margin}%")
        print(f" Best margin  -> {best_product['product_name']} ({best_product['brand']}) : {max_margin}%")
        print(f" Worst margin -> {worst_product['product_name']} ({worst_product['brand']}) : {min_margin}%")

    print("\n--- Top 5 Products with Highest Profit Margin ---")
    top_margin = df.sort_values('margin_pct', ascending=False).head(5)
    print(top_margin[['product_name', 'category', 'brand', 'purchase_price', 'selling_price', 'margin_pct']].to_string(index=False))

# ================================================================
# Step 7: Warranty info
# ================================================================

def show_warranty_info():
    print("\n--- Warranty Distribution (how many products have 12 vs 24 months) ---")
    print(df['warranty_months'].value_counts())

    print("\n--- Average Warranty by Category ---")
    warranty_by_cat = df.groupby('category')['warranty_months'].mean().round(1).sort_values(ascending=False)
    print(warranty_by_cat)

# ================================================================
# Run all steps
# ================================================================

show_sample_records()
show_products_available()
show_costliest_products()
show_price_summary()
category_profit_margin()
show_warranty_info()
