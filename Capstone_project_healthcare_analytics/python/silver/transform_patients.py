"""
Objective:
Create `silver_patients` from `bronze_patients`.

Transformations and calculation logic:

- Duplicate removal: drop duplicate rows based on `patient_id` keeping the first occurrence.
- Date parsing: parse `dob` and `registration_date` to dates using `pandas.to_datetime(..., errors='coerce')`.
    Invalid or unparseable values are coerced to Null.
- Age calculation:
    - A fixed `report_date` of `2025-12-31` is used as the reference date for age calculation.
    - `age` is computed as the integer number of years between `report_date` and `dob` using the formula:
        `age = floor((report_date - dob).days / 365)` implemented as `((report_date - dob_dt).dt.days // 365)`.
    - The `age` column uses the nullable integer dtype `Int64` to preserve missing values when `dob` is invalid.
- Age group assignment: `age_group` is assigned by as per below mapping 
    0 - 18 => Pediatric
    19 - 35 => Young Adult
    36 - 50 => Adult
    51 - 65 => Middle Age
    66+ => Senior Citizen

Selected output columns:
- `patient_id`, `patient_name`, `gender`, `dob`, `age`, `age_group`, `city`, `state`, `locality`, `registration_date`
"""
