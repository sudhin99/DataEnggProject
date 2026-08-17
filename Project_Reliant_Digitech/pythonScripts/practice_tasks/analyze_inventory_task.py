import pandas as pd
import os
import glob

# =============================================================================
# STUDENT TASK - Analyze Inventory Data
# =============================================================================
# Dataset: Datasets/stg/inventory_*.csv
#
# This file contains tasks for you to complete.
# Read each task carefully, understand what is expected,
# and write your own Python code to solve it.
#
# Columns in the dataset:
#   store_id, product_id, quantity, closing_stock,
#   opening_stock, inventory_date
# =============================================================================


# =============================================================================
# TASK 1: Read the file and print basic info
# =============================================================================
# - Load the inventory CSV file from Datasets/stg/ folder
# - Print total number of records and column names
# - Print first 5 rows as a table
#
# Expected output example:
#   Total records : 1200
#   Columns : ['store_id', 'product_id', ...]
#   (first 5 rows printed as a table)

# YOUR CODE HERE


# =============================================================================
# TASK 2: Products with zero closing stock (out of stock)
# =============================================================================
# - Filter rows where closing_stock is 0
# - Print store_id, product_id, and inventory_date for those rows
# - Also print how many out-of-stock records exist
#
# Expected output example:
#   Out-of-stock records : 45
#   (table of store_id, product_id, inventory_date)

# YOUR CODE HERE


# =============================================================================
# TASK 3: Total quantity sold per store
# =============================================================================
# - quantity = units sold in a given period
# - Group by store_id and calculate total quantity sold
# - Sort from highest to lowest
# - Print store_id and total quantity
#
# Expected output example:
#   Store 3  -> 8,450 units
#   Store 1  -> 7,230 units
#   ...

# YOUR CODE HERE
