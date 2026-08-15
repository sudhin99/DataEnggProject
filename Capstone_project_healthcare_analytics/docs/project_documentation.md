# Project Documentation

## Solution Design

- Python loads raw files into Bronze.
- Python cleans and flattens to Silver.
- MySQL stored procedures load Gold from Silver.
- Power BI uses views from Gold tables.

## Silver Layer Responsibilities

- Convert dates and numeric fields.
- Create patient age group.
- Split doctor hospital mapping.
- Flatten admission JSON.
- Flatten treatments array.
- Flatten billing object.
- Run data quality validations.
