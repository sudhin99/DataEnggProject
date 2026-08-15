CREATE OR REPLACE VIEW vw_disease_trend AS
SELECT d.month_number, d.month_name, f.diagnosis, COUNT(*) AS admission_count
FROM fact_admission f
LEFT JOIN dim_date d ON f.admission_date_key = d.date_key
GROUP BY d.month_number, d.month_name, f.diagnosis;