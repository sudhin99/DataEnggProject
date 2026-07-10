# Motor Theft SQL Practice Use Cases

This folder contains practice-style SQL scripts that focus on real data quality and analytics questions from the motor theft dataset.

## 1. Data quality checks
- Use case: Identify missing or inconsistent values in the theft dataset.
- SQL file: [01_data_quality_checks.sql](01_data_quality_checks.sql)

## 2. Duplicate and anomaly detection
- Use case: Find duplicate make records and suspicious theft rows that may need review.
- SQL file: [02_duplicate_and_anomaly_detection.sql](02_duplicate_and_anomaly_detection.sql)

## 3. Region risk scoring
- Use case: Rank regions by theft intensity relative to population size.
- SQL file: [03_region_risk_scoring.sql](03_region_risk_scoring.sql)

## 4. Vehicle profiling by make and color
- Use case: Explore which combinations of make, vehicle type, and color appear most often in theft records.
- SQL file: [04_vehicle_profile_by_make_and_color.sql](04_vehicle_profile_by_make_and_color.sql)

## 5. Insert messy practice data
- Use case: Add intentional junk rows so the data-quality, duplicate-detection, and anomaly queries produce visible results.
- SQL file: [05_insert_junk_data.sql](05_insert_junk_data.sql)

## Suggested flow
1. Run the data quality checks first.
2. Review duplicates and anomalies.
3. Use the risk-scoring query to identify regional hotspots.
4. Finish with the vehicle-profile query for a more detailed story.
5. Optionally run the junk-data insert script to create test rows before the checks.
