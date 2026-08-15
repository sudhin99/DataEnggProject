"""
Objective:
Create `silver_treatment` from the `treatments` array inside `bronze_admissions_json.raw_json`.
Transformation: one JSON treatment becomes one row.

Columns extracted (from the JSON `raw_json.treatments` objects and surrounding admission fields):
- treatment_id
- admission_id
- treatment_name
- treatment_date
- treatment_cost

Notes:
- `treatment_date` is parsed to `date` (invalid values coerced to Null).
- `treatment_cost` is coerced to numeric.
- Duplicate `treatment_id` rows are dropped before load.
"""

