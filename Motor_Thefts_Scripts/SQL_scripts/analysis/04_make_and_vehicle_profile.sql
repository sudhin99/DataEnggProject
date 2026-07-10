-- 04_make_and_vehicle_profile.sql
-- Examine theft frequency by vehicle make and vehicle characteristics.

SELECT
    md.make_name,
    md.make_type,
    COUNT(*) AS theft_count,
    SUM(CASE WHEN sv.vehicle_type = 'Car' THEN 1 ELSE 0 END) AS car_thefts,
    SUM(CASE WHEN sv.color = 'Black' THEN 1 ELSE 0 END) AS black_vehicle_thefts,
    ROUND(AVG(YEAR(sv.date_stolen) - sv.model_year), 2) AS avg_age_at_theft
FROM stolen_vehicles AS sv
JOIN make_details AS md
    ON sv.make_id = md.make_id
WHERE sv.date_stolen IS NOT NULL
  AND sv.model_year IS NOT NULL
GROUP BY md.make_name, md.make_type
ORDER BY theft_count DESC, avg_age_at_theft DESC;
