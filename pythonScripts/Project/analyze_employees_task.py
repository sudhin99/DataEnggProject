import pandas as pd
import os
import glob

# =============================================================================
# STUDENT TASK - Analyze Employee Data
# =============================================================================
# Dataset: Datasets/stg/employees_*.csv
#
# This file contains tasks for you to complete.
# Read each task carefully, understand what is expected,
# and write your own Python code to solve it.
#
# Columns in the dataset:
#   employee_id, employee_name, store_id, store_name,
#   city, store_type, designation, joining_date, salary
# =============================================================================


# =============================================================================
# TASK 1: Read the file and print first 5 records
# =============================================================================
# - Load the employees CSV file from Datasets/stg/ folder
# - The filename has a timestamp so use glob to find it
# - Print the first 5 rows of the DataFrame
# - Also print the total number of employees and column names
#
# Expected output example:
#   Total employees : 178
#   Columns : ['employee_id', 'employee_name', ...]
#   (first 5 rows printed as a table)

# YOUR CODE HERE


# =============================================================================
# TASK 2: Highest and lowest salary
# =============================================================================
# - Find the employee with the highest salary
# - Find the employee with the lowest salary
# - Print their name, designation, store name, and salary
#
# Expected output example:
#   Highest salary: Chitra Kaur | Store Manager | ... | ₹49,000
#   Lowest salary : Geeta Mishra | Staff | ... | ₹10,000

# YOUR CODE HERE


# =============================================================================
# TASK 3: Average salary by designation
# =============================================================================
# - Group employees by designation
# - Calculate the average salary for each designation
# - Sort the result from highest to lowest average salary
# - Print the results
#
# Expected output example:
#   Store Manager        -> ₹43,900
#   Assistant Manager    -> ₹33,500
#   Inventory Manager    -> ₹29,200
#   ...

# YOUR CODE HERE


# =============================================================================
# TASK 4: Oldest and newest employee (by joining date)
# =============================================================================
# - Convert joining_date column to a proper date type using pd.to_datetime()
# - Find the employee who joined earliest (oldest employee)
# - Find the employee who joined most recently (newest employee)
# - Print their name, designation, store name, and joining date
#
# Expected output example:
#   Oldest  employee: Prasad Rao | Sales Associate | joined 2017-01-02
#   Newest  employee: Jyoti More | Assistant Manager | joined 2024-12-28

# YOUR CODE HERE


# =============================================================================
# TASK 5: Employee count per store
# =============================================================================
# - Count how many employees each store has
# - Sort by employee count (highest first)
# - Print store name and count
#
# Expected output example:
#   Reliant DigiTech Hyderabad Mall     -> 19 employees
#   Reliant DigiTech Mumbai Mall        -> 19 employees
#   ...

# YOUR CODE HERE
