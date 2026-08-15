CREATE OR REPLACE VIEW vw_disease_hospital_matrix AS
SELECT h.hospital_name, a.diagnosis, COUNT(*) AS admission_count
FROM fact_admission a
LEFT JOIN dim_hospital h ON a.hospital_key = h.hospital_key
GROUP BY h.hospital_name, a.diagnosis;