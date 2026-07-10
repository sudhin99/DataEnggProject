# Motor Theft SQL Use Cases

This document maps the SQL scripts in the Motor Thefts project to practical business use cases.

## 1. Create the database structure
- Use case: Set up the database tables needed for the motor theft dataset.
- SQL file: [create_table_script.sql](create_table_script.sql)

## 2. Load raw data into the tables
- Use case: Populate the database with location, make, and stolen vehicle records from the raw dataset.
- SQL file: [insert_data.sql](insert_data.sql)

## 3. Join theft facts with supporting dimensions
- Use case: Create a unified view combining stolen vehicle details with make information and location details.
- SQL file: [join_motor_thefts.sql](join_motor_thefts.sql)

## 4. Explore overall dataset health
- Use case: Get a quick summary of theft volume, vehicle variety, regions covered, and average age at theft.
- SQL file: [analysis/01_exploratory_summary.sql](analysis/01_exploratory_summary.sql)

## 5. Analyze theft activity by region
- Use case: Understand which regions and countries experience the highest number of thefts.
- SQL file: [analysis/02_region_analysis.sql](analysis/02_region_analysis.sql)

## 6. Analyze theft trends over time
- Use case: Review theft patterns by year, month, and weekday.
- SQL file: [analysis/03_time_series_analysis.sql](analysis/03_time_series_analysis.sql)

## 7. Profile vehicle makes and vehicle characteristics
- Use case: Identify which makes are involved most often and how thefts differ by vehicle type or color.
- SQL file: [analysis/04_make_and_vehicle_profile.sql](analysis/04_make_and_vehicle_profile.sql)

## 8. Measure theft risk by population-adjusted exposure
- Use case: Rank areas by theft intensity relative to population and density.
- SQL file: [analysis/05_risk_insights.sql](analysis/05_risk_insights.sql)

## Suggested project flow
1. Run the table creation script.
2. Run the data insertion script.
3. Use the join query to build a combined view.
4. Run the analysis scripts to generate insights for presentation or portfolio use.
