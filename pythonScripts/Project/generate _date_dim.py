import pandas as pd
import os
import requests
from datetime import date, timedelta

datasets_folder = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'Datasets'))

# =============================================================================
# Step 1: Define the date range
# =============================================================================
# We generate one row per day between start and end date.
# This covers the full orders date range (Jan 2024 - Mar 2026)

start_date = date(2024, 1, 1)
end_date   = date(2026, 3, 31)

# =============================================================================
# Step 2: Fetch Indian public holidays using Calendarific API
# =============================================================================
# API: https://calendarific.com
# Covers national + regional Indian holidays (Diwali, Holi, Eid etc.)
# URL format: https://calendarific.com/api/v2/holidays?api_key=KEY&country=IN&year=2025

API_KEY = 'mXAzR8653C37w1CFcbLP2XHyRmoq0RMg'

def fetch_holidays_for_year(year):
    url = f"https://calendarific.com/api/v2/holidays?api_key={API_KEY}&country=IN&year={year}"
    
    print(f" Calling API for year {year}...")
    response = requests.get(url, timeout=10)
    
    if response.status_code == 200:
        data = response.json()
        holidays = data['response']['holidays']
        # Build a dictionary: { date object -> holiday name }
        return {
            date.fromisoformat(h['date']['iso'][:10]): h['name'] 
            for h in holidays
        }
    else:
        print(f" Warning: Could not fetch holidays for {year} (status {response.status_code})")
        return {}

# Fetch holidays for all years in our date range
print("Fetching Indian public holidays from API...\n")
all_holidays = {}
for year in [2024, 2025, 2026]:
    year_holidays = fetch_holidays_for_year(year)
    all_holidays.update(year_holidays)
    print(f" {year}: {len(year_holidays)} holidays fetched")

print(f"\nTotal holidays loaded: {len(all_holidays)}\n")

def get_holiday_name(d):
    return all_holidays.get(d, None)

# =============================================================================
# Step 3: Generate one row per date
# =============================================================================

rows = []

current = start_date
while current <= end_date:
    holiday_name = get_holiday_name(current)
    
    # datetime module: .weekday() returns 0=Monday ... 6=Sunday
    weekday_num  = current.weekday()
    weekday_name = current.strftime("%A")      # e.g. Monday
    month_name   = current.strftime("%B")      # e.g. January
    quarter      = (current.month - 1) // 3 + 1
    
    is_weekend        = weekday_num >= 5       # Saturday=5, Sunday=6
    is_public_holiday = holiday_name is not None
    is_working_day    = not is_weekend and not is_public_holiday
    
    if is_public_holiday:
        day_type = "Public Holiday"
    elif is_weekend:
        day_type = "Weekend"
    else:
        day_type = "Weekday"
        
    rows.append({
        "date": current.strftime("%Y-%m-%d"),
        "year": current.year,
        "month": current.month,
        "month_name": month_name,
        "quarter": f"Q{quarter}",
        "day": current.day,
        "weekday_name": weekday_name,
        "is_weekend": is_weekend,
        "is_public_holiday": is_public_holiday,
        "holiday_name": holiday_name if holiday_name else "",
        "is_working_day": is_working_day,
        "day_type": day_type
    })
    
    current += timedelta(days=1)

# =============================================================================
# Step 4: Save as date_dim.csv
# =============================================================================

df = pd.DataFrame(rows)
output_folder = os.path.join(os.path.dirname(__file__), '..', 'data_output')
os.makedirs(output_folder, exist_ok=True)
output_path = os.path.join(output_folder, 'date_dim.csv')
df.to_csv(output_path, index=False)

print(f"date_dim.csv created with {len(df)} rows")
print(f"Saved to: data_output/date_dim.csv")

# =============================================================================
# Step 5: Summary
# =============================================================================

print("\n--- Day Type Breakdown ---")
print(df['day_type'].value_counts().to_string())

print("\n--- Public Holidays in the dataset ---")
holidays_df = df[df['is_public_holiday'] == True][['date', 'weekday_name', 'holiday_name']]
print(holidays_df.to_string(index=False))

print("\n--- Sample rows from date_dim ---")
print(df.head(10).to_string(index=False))
