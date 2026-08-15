CREATE OR REPLACE VIEW vw_state_analysis AS
SELECT p.state, COUNT(DISTINCT a.admission_id) AS admission_count
FROM fact_admission a
LEFT JOIN dim_patient p ON a.patient_key = p.patient_key
GROUP BY p.state;
