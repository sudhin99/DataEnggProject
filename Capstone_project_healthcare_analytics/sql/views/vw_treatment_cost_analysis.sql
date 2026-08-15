CREATE OR REPLACE VIEW vw_treatment_cost_analysis AS
SELECT a.diagnosis, AVG(t.treatment_cost) AS avg_treatment_cost, SUM(t.treatment_cost) AS total_treatment_cost
FROM fact_admission a
LEFT JOIN fact_treatment t ON a.admission_key = t.admission_key
GROUP BY a.diagnosis;