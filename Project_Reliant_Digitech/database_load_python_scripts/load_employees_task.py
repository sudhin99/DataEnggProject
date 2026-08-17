import pandas as pd
import os
import glob

# =============================================================================
# STUDENT TASK - Load Employee Data
# =============================================================================
# Dataset: datasets/Reliant_Digitech/stg/employee_*.csv
#
# This file contains tasks for you to complete.
# Read each task carefully, understand what is expected,
# and write your own Python code to solve it.
#
# Goal:
#   Load the employee data file, clean it if needed, and prepare it
#   for loading into a staging table.
#
# Columns in the dataset:
#   emp_id, emp_name, gender, designation, store_id,
#   city, store_name, joining_date, salary, phone_number
# =============================================================================


# =============================================================================
# TASK 1: Find and read the employee file
# =============================================================================
# - Use glob to find the employee CSV file in datasets/Reliant_Digitech/stg/
# - Load the file into a pandas DataFrame
# - Print the total number of rows and the column names
# - Print the first 5 rows as a table
#
# Expected output example:
#   Total employees : 178
#   Columns : ['emp_id', 'emp_name', ...]
#   (first 5 rows printed as a table)

# YOUR CODE HERE


# =============================================================================
# TASK 2: Clean the data before loading
# =============================================================================
# - Convert all column names to lowercase or uppercase consistently
# - Remove any duplicate rows if present
# - Handle missing values if needed
# - Convert joining_date to a proper date format if required by your table
# - Print the cleaned DataFrame shape
#
# Expected output example:
#   Cleaned rows : 178
#   Cleaned columns : 10

# YOUR CODE HERE


# =============================================================================
# TASK 3: Prepare the data for database loading
# =============================================================================
# - Add any required audit columns if your staging table needs them
# - Reorder or rename columns to match the table structure
# - Print the final column list that will be loaded
#
# Expected output example:
#   Final columns : ['emp_id', 'emp_name', ...]

# YOUR CODE HERE


# =============================================================================
# TASK 4: Load into the staging table
# =============================================================================
# - Connect to MySQL using the project connection settings
# - Load the DataFrame into the employee staging table
# - Print a success message with the number of rows loaded
# - If the load fails, print the error message
#
# Expected output example:
#   Successfully loaded 178 rows into STG_EMPLOYEES

# YOUR CODE HERE
