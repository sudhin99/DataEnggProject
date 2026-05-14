import pandas as pd
import os
import glob

# =============================================================================
# STUDENT TASK - Analyze Orders Data
# =============================================================================
# Dataset: Datasets/stg/orders_*.csv
#
# This file contains tasks for you to complete.
# Read each task carefully, understand what is expected,
# and write your own Python code to solve it.
#
# Columns in the dataset:
#   order_id, store_id, product_id, customer_id,
#   order_date, quantity, selling_price, revenue
# =============================================================================


# =============================================================================
# TASK 1: Read the file and print basic info
# =============================================================================
# - Load the orders CSV file from Datasets/stg/ folder
# - Print total number of orders and column names
# - Print first 5 rows as a table
#
# Expected output example:
#   Total orders : 5000
#   Columns : ['order_id', 'store_id', ...]
#   (first 5 rows printed as a table)

# YOUR CODE HERE


# =============================================================================
# TASK 2: Total revenue and average order value
# =============================================================================
# - Calculate the total revenue across all orders
# - Calculate the average revenue per order
# - Print both values
#
# Expected output example:
#   Total revenue     : ₹1,23,45,678
#   Average per order : ₹2,469

# YOUR CODE HERE


# =============================================================================
# TASK 3: Top 5 stores by total revenue
# =============================================================================
# - Group orders by store_id
# - Calculate total revenue per store
# - Show top 5 stores with highest revenue
# - Print store_id and total revenue
#
# Expected output example:
#   Store 3  -> ₹15,23,456
#   Store 1  -> ₹14,87,234
#   ...

# YOUR CODE HERE
