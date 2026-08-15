CREATE OR REPLACE VIEW vw_age_group_analysis AS
SELECT age_group, COUNT(DISTINCT patient_id) AS patient_count
FROM dim_patient
GROUP BY age_group;