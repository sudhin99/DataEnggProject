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

## Advanced Capstone Insights

### Executive Insights

- Top revenue-generating hospital
- Highest admission month
- Revenue trend over 2025

### Clinical Insights

- Top diseases by admission count
- Average length of stay by disease
- Disease hotspots by state

### Operational Insights

- Busiest hospital by admissions
- Bed utilization percentage
- Most frequently performed treatments

### Financial Insights

- Revenue by payment mode
- Outstanding pending collections
- Average bill amount by disease

### Patient Insights

- Admissions by age group
- Admissions by gender
- Patients traveling from outside West Bengal

# Power BI Dashboard Requirement

## Dashboard Name

# Kolkata Healthcare Disease Analytics Dashboard 2025

### Objective

Build a **single-page interactive Power BI dashboard** that helps healthcare management understand:

- Disease trends throughout 2025
- Seasonal disease patterns
- Most common diseases
- Treatment cost analysis
- Patient distribution across states
- Disease distribution across hospitals
- Patient demographics by age group

The dashboard should answer the following questions:

1. Which diseases are most common?
2. How do disease patterns change month by month?
3. Which diseases are the most expensive to treat?
4. Which states contribute the highest patient volume?
5. Which hospitals handle the highest number of specific disease cases?
6. Which age groups account for the largest patient population?

---

# Dashboard Layout

## KPI Cards

Display the following KPIs at the top of the dashboard:

```text
Total Admissions
Total Patients
Total Diseases
Average Treatment Cost
Most Common Disease
```

---

# Filters / Slicers

Provide the following filters on the left panel:

```text
Disease
Hospital
State
Month
```

All visuals should respond dynamically to filter selections.

---

# Visual 1: Disease Trend Over Time

### Chart Type

```text
Line Chart
```

### Fields

```text
X-Axis   : Month
Y-Axis   : Admission Count
Legend   : Disease
```

### Purpose

Analyze:

- Disease seasonality
- Outbreak trends
- Monthly disease patterns

### Example Questions

```text
Which disease peaked during monsoon?
How did Dengue cases change throughout the year?
Which disease shows consistent growth?
```

---

# Visual 2: Top Diseases by Admissions

### Chart Type

```text
Horizontal Bar Chart
```

### Fields

```text
Disease
Admission Count
```

### Purpose

Identify:

- Most common diseases
- Disease burden across all hospitals

### Example Questions

```text
What are the Top 10 diseases?
Which disease contributes the highest admissions?
```

---

# Visual 3: Average Treatment Cost by Disease

### Chart Type

```text
Horizontal Bar Chart
```

### Fields

```text
Disease
Average Treatment Cost
```

### Purpose

Compare treatment costs across diseases.

### Example Questions

```text
Which diseases are most expensive?
Which diseases are least expensive?
What is the average treatment cost for Stroke?
```

---

# Visual 4: Admissions by State

### Chart Type

```text
Map Visual
OR
Horizontal Bar Chart
```

### Fields

```text
State
Admission Count
```

### Purpose

Show geographical distribution of patients.

### Example Questions

```text
Which states send the most patients?
How many patients travel from outside West Bengal?
```

---

# Visual 5: Disease vs Hospital Analysis

### Chart Type

```text
Matrix / Heatmap
```

### Rows

```text
Hospital Name
```

### Columns

```text
Disease
```

### Values

```text
Admission Count
```

### Purpose

Analyze disease concentration across hospitals.

### Example Questions

```text
Which hospital handles the most cardiac cases?
Which hospital treats the most Dengue patients?
Which diseases are common at Apollo Hospital?
```

---

# Visual 6: Patient Count by Age Group

### Chart Type

```text
Clustered Column Chart
```

### Fields

```text
Age Group
Patient Count
```

### Recommended Age Groups

```text
0-18
19-35
36-50
51-65
65+
```

### Purpose

Analyze patient demographics.

### Example Questions

```text
Which age group contributes the highest number of patients?
Which age segment is most affected by healthcare issues?
```

---

# Dashboard Design Guidelines

- Use a clean healthcare-themed color palette.
- Maintain consistent colors across disease categories.
- Ensure all visuals support cross-filtering.
- Limit the dashboard to a single page.
- Avoid clutter and unnecessary visuals.
- Focus on storytelling through disease trends and treatment cost analysis.

---

# Expected Insights

Students should be able to present insights such as:

### Disease Insights

```text
Dengue cases peak during August and September.
Type 2 Diabetes is one of the most common chronic diseases.
```

### Cost Insights

```text
Cancer treatments have the highest average treatment cost.
Dengue treatments have relatively low average treatment cost.
```

### Geographic Insights

```text
Most patients come from West Bengal, Bihar and Jharkhand.
```

### Hospital Insights

```text
Apollo and Fortis handle a large number of cardiology-related cases.
```

### Demographic Insights

```text
The 51-65 age group contributes the highest patient count.
```

---

# Deliverable

Submit:

```text
Power BI (.pbix) File
Dashboard Screenshot
Summary of Key Insights
```

## Project folder structure

```
Capstone_project_healthcare_analytics/
├─ .gitignore
├─ CapstoneProjectDetails.md
├─ PowerBiDashboardSample.pdf
├─ requirements.txt
├─ data/
│  ├─ archive/.gitkeep
│  └─ source/
│     ├─ .gitkeep
│     └─ README.md
├─ python/
│  ├─ bronze/
│  │  ├─ load_admissions_bronze.py
│  │  ├─ load_patients_bronze.py
│  │  ├─ load_hospitals_bronze.py
│  │  └─ load_doctors_bronze.py
│  ├─ silver/
│  │  ├─ flatten_treatments.py
│  │  ├─ flatten_billing.py
│  │  ├─ flatten_admissions.py
│  │  ├─ transform_hospitals.py
│  │  ├─ transform_doctors.py
│  │  └─ transform_patients.py
│  ├─ gold/
│  │  └─ load_gold_tables.py
│  └─ orchestration/
│     └─ run_pipeline.py
├─ sql/
│  ├─ ddl/
│  │  ├─ bronze_tables.sql
│  │  ├─ silver_tables.sql
│  │  └─ gold_tables.sql
│  ├─ procedures/
│  │  ├─ usp_load_dim_doctor.sql
│  │  ├─ usp_load_dim_hospital.sql
│  │  ├─ usp_load_dim_patient.sql
│  │  ├─ usp_load_fact_admission.sql
│  │  ├─ usp_load_fact_billing.sql
│  │  └─ usp_load_fact_treatment.sql
│  └─ views/
│     ├─ vw_age_group_analysis.sql
│     ├─ vw_disease_hospital_matrix.sql
│     ├─ vw_disease_trend.sql
│     ├─ vw_state_analysis.sql
│     ├─ vw_top_diseases.sql
│     └─ vw_treatment_cost_analysis.sql
```