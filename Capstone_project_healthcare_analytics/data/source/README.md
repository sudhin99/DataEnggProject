# Kolkata Private Hospital Analytics Platform - Synthetic Dataset 2025

This synthetic dataset is designed for a Data Engineering capstone project using Python, SQL, ETL, and Data Warehouse concepts.

## Scenario
A healthcare analytics company receives data from a network of private hospitals in Kolkata/Howrah. Patient registration and doctor data arrive as CSV files, hospital master data arrives as Excel, and daily admission transactions arrive as a nested JSON API extract.

## Files
- `patients.csv`: 5,000 patient registration records from different Indian cities/states.
- `doctors.csv`: 120 doctors with `hospital_ids` stored as a pipe-delimited concat field, e.g. `H101|H105`.
- `hospital_master.xlsx`: 15 private Kolkata/Howrah hospital records and a data dictionary sheet.
- `admissions_2025_nested.json`: 12,000 admission records for calendar year 2025. Treatments and billing are nested inside each admission record.
- `sample_5_admissions_preview.json`: Small preview file.

## ETL Expectations
1. Load raw files into Bronze layer as-is.
2. Split/explode `doctors.hospital_ids` into a normalized `doctor_hospital_bridge`.
3. Flatten `admissions_2025_nested.json` into admissions, treatments, and billing datasets.
4. Validate foreign keys: patient_id, doctor_id, hospital_id.
5. Build Silver clean tables.
6. Build Gold star schema: dim_patient, dim_doctor, dim_hospital, dim_date, fact_admission, fact_treatment, fact_billing.

## Intentional Data Quality Issues
A few records include issues for validation practice:
- Missing diagnosis
- Negative treatment cost
- Out-of-year admission date
- Unknown patient ID
- Negative bill amount
- Small number of doctor-hospital mismatches

## Notes
- Data is fully synthetic and generated for education/training only.
- Do not use this dataset for medical, clinical, financial, or operational decision-making.
