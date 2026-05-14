import pandas as pd
import os
import glob

# ==============================================================================
# STUDENT TASK - Analyze Customer Feedback Data
# ==============================================================================
# Dataset: Datasets/stg/customer_feedback_*.csv
#
# This file contains tasks for you to complete.
# Read each task carefully, understand what is expected,
# and write your own Python code to solve it.
#
# Columns in the dataset:
#   feedback_id, customer_id, store_id, rating,
#   comment, channel, date
# ==============================================================================


# ==============================================================================
# TASK 1: Read the file and print basic info
# ==============================================================================
# - Load the customer_feedback CSV file from Datasets/stg/ folder
# - Print total number of feedback records and column names
# - Print first 5 rows as a table
#
# Expected output example:
#   Total records : 2000
#   Columns : ['feedback_id', 'customer_id', ...]
#   (first 5 rows printed as a table)

# YOUR CODE HERE


# ==============================================================================
# TASK 2: Average rating overall and per store
# ==============================================================================
# - Calculate the overall average rating across all feedback
# - Calculate the average rating per store_id
# - Sort stores from highest to lowest rating
# - Print store_id and average rating
#
# Expected output example:
#   Overall average rating : 3.8
#   Store 2  -> 4.2
#   Store 5  -> 4.0
#   ...

# YOUR CODE HERE


# ==============================================================================
# TASK 3: Count of feedback by rating value
# ==============================================================================
# - Count how many feedback records exist for each rating (1 to 5)
# - Print rating value and count
#
# Expected output example:
#   Rating 5  -> 620 feedbacks
#   Rating 4  -> 510 feedbacks
#   ...

# YOUR CODE HERE
