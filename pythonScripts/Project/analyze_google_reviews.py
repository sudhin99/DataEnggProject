import json
import glob
import pandas as pd
import os
from textblob import TextBlob

# ===================================================
# Step 1: Read the JSON file
# ===================================================

datasets_folder = os.path.join(os.path.dirname(__file__), '..', '..', 'Datasets', 'stg')

def find_file(pattern):
    matches = sorted(glob.glob(os.path.join(datasets_folder, pattern)))
    if not matches:
        raise FileNotFoundError(f"No file found matching: {pattern}")
    return matches[-1]

file_path = find_file('google_reviews_*.json')

# ===================================================
# Step 1: Read the JSON file
# ===================================================
# json.load() converts it to a Python list
with open(file_path, 'r') as f:
    data = json.load(f)

print("Step 1: JSON file read successfully!")
print("Total records :", len(data))

# ===================================================
# Step 2: Print raw JSON – see what it looks like
# ===================================================
# Each record is a dictionary with key-value pairs
print("\nStep 2: Raw JSON (first 3 records):")
for record in data[:3]:
    print(" ", record)

# ===================================================
# Step 3: Flatten JSON into a DataFrame (table format)
# ===================================================
# pd.DataFrame() converts the list of dictionaries into a table
# with row and columns – just like a spreadsheet
df = pd.DataFrame(data)

print("\nStep 3: Flattened into DataFrame!")
print(df.head(10).to_string(index=False))

# ===================================================
# Step 4: Sentiment Analysis – add a new column
# ===================================================
# TextBlob gives a polarity score for each review text
# we use .apply() to run the function on every row
# lambda scores each review text and maps polarity to a sentiment level

get_sentiment = lambda text: 'Positive' if TextBlob(text).sentiment.polarity > 0.2 else 'Negative' if TextBlob(text).sentiment.polarity < -0.2 else 'Neutral'

df['sentiment'] = df['text'].apply(get_sentiment)

print("\nStep 4: Sentiment column added!")
print(df[['review_id', 'store_id', 'rating', 'text', 'sentiment']].head(10).to_string(index=False))

print("\n---- Sentiment Summary ----")
print(df['sentiment'].value_counts())
