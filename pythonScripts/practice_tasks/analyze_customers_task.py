import pandas as pd
import os
import glob

# =============================================================================
# STUDENT TASK - Analyze Customers Data
# =============================================================================
# Dataset: Datasets/stg/customers_*.xlsx    (Excel file)
#
# This file contains tasks for you to complete.
# Read each task carefully, understand what is expected,
# and write your own Python code to solve it.
#
# Hint: Use pd.read_excel() instead of pd.read_csv()
#       for .xlsx files
#
# Columns in the dataset:
#   customer_id, customer_name, gender, city,
#   phone, email, signup_date
# =============================================================================


# =============================================================================
# TASK 1: Read the Excel file and print basic info
# =============================================================================
# - Load the customers Excel file from Datasets/stg/ folder
# - Use glob to find the file (filename has a timestamp)
# - Print total number of customers and column names
# - Print first 5 rows as a table
#
# Expected output example:
#   Total customers : 500
#   Columns : ['customer_id', 'customer_name', ...]
#   (first 5 rows printed as a table)

# YOUR CODE HERE


# =============================================================================
# TASK 2: Top 5 cities with most customers
# =============================================================================
# - Count how many customers belong to each city
# - Show only the top 5 cities with the most customers
# - Print city name and count
#
# Expected output example:
#   Mumbai        -> 85 customers
#   Delhi         -> 72 customers
#   ...

# YOUR CODE HERE


# =============================================================================
# TASK 3: Newest and oldest customer by signup date
# =============================================================================
# - Convert signup_date to datetime using pd.to_datetime()
# - Find the customer who signed up first (oldest)
# - Find the customer who signed up most recently (newest)
# - Print name, city, and signup date for each
#
# Expected output example:
#   Oldest   customer: Ramesh Kumar | Mumbai | signed up 2018-03-15
#   Newest   customer: Priya Singh  | Delhi  | signed up 2025-12-28

# YOUR CODE HERE
