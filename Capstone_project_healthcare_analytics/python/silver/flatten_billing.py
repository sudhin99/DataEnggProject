"""
Objective:
Create `silver_billing` from the `billing` object inside `bronze_admissions_json.raw_json`.
Transformation: one billing object becomes one row.

Columns extracted (from the JSON `raw_json.billing` object and surrounding admission fields):
- bill_id
- admission_id
- total_bill
- discount
- patient_payable
- payment_mode
- payment_status

Notes:
- Monetary fields (`total_bill`, `discount`, `patient_payable`) are coerced to numeric.
- Duplicate `bill_id` rows are dropped before load.
"""
