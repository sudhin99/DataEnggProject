"""
Simple Matplotlib Example
=========================
Matplotlib is a Python library for creating charts.
This example shows how to create a basic bar chart and pie chart.
"""

import matplotlib.pyplot as plt

# ===== BAR CHART EXAMPLE =====

# Step 1: Prepare your data
cities = ['Hyderabad', 'Bangalore', 'Mumbai', 'Delhi', 'Chennai']
store_counts = [2, 2, 2, 2, 1]

# Step 2: Create a bar chart
# plt.bar() attributes:
#   - cities: X-axis data (categories to display)
#   - store_counts: Y-axis data (values for each category)
#   - color: Color of the bars (e.g., 'steelblue', 'red', 'green')
plt.bar(cities, store_counts, color='steelblue')

# Step 3: Add labels and title
# plt.xlabel(): Label for X-axis (what does horizontal axis represent?)
plt.xlabel('City')

# plt.ylabel(): Label for Y-axis (what does vertical axis represent?)
plt.ylabel('Number of Stores')

# plt.title(): Title of the chart (main heading)
plt.title('Stores by City')

# Step 4: Display the chart
# plt.show(): Display the chart window
plt.show()

# ===== PIE CHART EXAMPLE =====

cities = ['Hyderabad', 'Bangalore', 'Mumbai', 'Delhi', 'Chennai']
store_counts = [2, 2, 2, 2, 1]

# plt.figure(): Create a new chart with specific size
#   - figsize: Tuple (width, height) in inches - (8, 6) means 8 inches wide, 6 inches tall
plt.figure(figsize=(8, 6))

# plt.pie() attributes:
#   - store_counts: Data values to display as pie slices
#   - labels: Labels for each slice (what each slice represents)
#   - autopct: Format string to show percentage on each slice
#             '%1.1f%%' means show percentage with 1 decimal place
plt.pie(store_counts, labels=cities, autopct='%1.1f%%')

# plt.title(): Title of the pie chart
plt.title('Store Distribution by City')

# plt.show(): Display the chart window
plt.show()
