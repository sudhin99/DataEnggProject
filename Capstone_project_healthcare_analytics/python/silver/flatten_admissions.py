"""
Objective:
Create `silver_admission` from `bronze_admissions_json.raw_json`.
Transformation: flatten admission-level fields from JSON.

Columns extracted (from the JSON `raw_json` field):
- admission_id
- patient_id
- doctor_id
- hospital_id
- admission_date
- discharge_date
- diagnosis
- room_type
- admission_type
- referral_source

Notes:
- Standardized date formats (invalid values coerced to Null).
- Duplicate `admission_id` rows are dropped before load.
"""
