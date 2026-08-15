CREATE OR REPLACE VIEW vw_top_diseases AS
SELECT diagnosis, COUNT(*) AS admission_count
FROM fact_admission
GROUP BY diagnosis;
