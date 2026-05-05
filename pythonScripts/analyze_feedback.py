import pandas as pd
import os
import glob
import matplotlib.pyplot as plt

# Setup paths
base_dir = os.path.dirname(__file__)
datasets_folder = os.path.join(base_dir, '..', 'Datasets', 'stg')
charts_folder = os.path.join(base_dir, '..', 'charts')

def find_file(pattern):
    path_pattern = os.path.join(datasets_folder, pattern)
    matches = sorted(glob.glob(path_pattern))
    if not matches:
        raise FileNotFoundError(f"No file found matching: {pattern}")
    return matches[-1]

# --- Step 1: Read the file ---
try:
    file_path = find_file('customer_feedback_*.csv')
    df = pd.read_csv(file_path)
    print(f"Step 1: File loaded successfully! ({os.path.basename(file_path)})")
    print(f"Total rows : {len(df)}")
    print(f"Column names: {list(df.columns)}")
except Exception as e:
    print(f"Error: {e}")
    exit()

# --- Step 2: Show sample records ---
def show_sample():
    print("\n--- First 5 Feedback Records ---")
    print(df.head(5).to_string(index=False))

# --- Step 3: Rating distribution ---
def rating_distribution():
    print("\n--- Feedback Count by Rating ---")
    rating_count = df['rating'].value_counts().sort_index()
    for rating, count in rating_count.items():
        stars = "★" * int(rating) + "☆" * (5 - int(rating))
        print(f"{stars} (Rating {rating}) -> {count} feedbacks")
    
    avg_rating = round(df['rating'].mean(), 2)
    print(f"\nAverage Rating: {avg_rating} / 5")

# --- Step 4: Rating by store ---
def rating_by_store():
    print("\n--- Average Rating by Store ---")
    store_rating = df.groupby('store_id')['rating'].mean().round(2).sort_values(ascending=False)
    for store_id, avg in store_rating.items():
        print(f"Store {store_id} -> {avg} / 5")

# --- Step 5: Feedback by channel ---
def feedback_by_channel():
    print("\n--- Feedback Count by Channel ---")
    channel_count = df['channel'].value_counts()
    for channel, count in channel_count.items():
        print(f"{channel:<12} -> {count} feedbacks")
    
    print("\n--- Average Rating by Channel ---")
    channel_rating = df.groupby('channel')['rating'].mean().round(2).sort_values(ascending=False)
    for channel, avg in channel_rating.items():
        print(f"{channel:<12} -> {avg} / 5")

# --- Step 6: Sentiment Summary ---
def sentiment_summary():
    positive = len(df[df['rating'] >= 4])
    neutral = len(df[df['rating'] == 3])
    negative = len(df[df['rating'] <= 2])
    total = len(df)

    print("\n--- Sentiment Summary ---")
    print(f"Positive (4-5) : {positive} ({round(positive/total*100, 1)}%)")
    print(f"Neutral  (3)   : {neutral}  ({round(neutral/total*100, 1)}%)")
    print(f"Negative (1-2) : {negative} ({round(negative/total*100, 1)}%)")

    print("\n--- Store with Most Negative Feedback ---")
    neg_by_store = df[df['rating'] <= 2].groupby('store_id')['feedback_id'].count().sort_values(ascending=False)
    if not neg_by_store.empty:
        for store_id, count in neg_by_store.items():
            print(f"Store {store_id} -> {count} negative feedbacks")
    else:
        print("No negative feedback found!")

# --- Step 7: Sentiment Pie Chart ---
def sentiment_pie_chart():
    positive = len(df[df['rating'] >= 4])
    neutral = len(df[df['rating'] == 3])
    negative = len(df[df['rating'] <= 2])
    total = len(df)

    labels = [
        f'Positive (4-5)\n{round(positive/total*100, 1)}%',
        f'Neutral (3)\n{round(neutral/total*100, 1)}%',
        f'Negative (1-2)\n{round(negative/total*100, 1)}%'
    ]
    sizes = [positive, neutral, negative]
    colors = ['#4CAF50', '#FFC107', '#F44336'] # Green, Amber, Red
    explode = (0.05, 0.05, 0.05)

    fig, ax = plt.subplots(figsize=(7, 7))
    ax.pie(sizes, labels=labels, colors=colors, explode=explode, 
           startangle=140, textprops={'fontsize': 12})

    plt.title("Customer Feedback Sentiment\n(Positive / Neutral / Negative)", 
              fontsize=15, fontweight='bold', pad=20)
    
    plt.tight_layout()
    
    os.makedirs(charts_folder, exist_ok=True)
    output_path = os.path.join(charts_folder, 'feedback_sentiment_pie.png')
    plt.savefig(output_path, dpi=150)
    print(f"\nChart saved: {output_path}")
    plt.show()
    plt.close()

# --- Step 8: Monthly feedback trend ---
def monthly_trend():
    df['date'] = pd.to_datetime(df['date'])
    df['month'] = df['date'].dt.to_period('M')

    monthly = df.groupby('month').agg(
        feedback_count=('feedback_id', 'count'),
        avg_rating=('rating', 'mean')
    ).round(2)

    print("\n--- Monthly Feedback Trend ---")
    for month, row in monthly.iterrows():
        print(f"{month} -> {int(row['feedback_count'])} feedbacks | Avg Rating: {row['avg_rating']}")

# --- Run all steps ---
if __name__ == "__main__":
    show_sample()
    rating_distribution()
    rating_by_store()
    feedback_by_channel()
    sentiment_summary()
    sentiment_pie_chart()
    monthly_trend()
