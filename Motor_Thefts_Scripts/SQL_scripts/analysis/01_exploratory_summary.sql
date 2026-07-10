-- 01_exploratory_summary.sql
-- High-level overview of the motor theft dataset.
-- Assumes the tables locations, make_details, and stolen_vehicles already exist.

SELECT
    COUNT(*) AS total_thefts,
    COUNT(DISTINCT sv.vehicle_type) AS distinct_vehicle_types,
    COUNT(DISTINCT COALESCE(loc.region, 'Unknown')) AS distinct_regions,
    COUNT(DISTINCT md.make_name) AS distinct_makes,
    MIN(sv.date_stolen) AS first_theft_date,
    MAX(sv.date_stolen) AS last_theft_date,
    ROUND(AVG(YEAR(sv.date_stolen) - sv.model_year), 2) AS avg_age_at_theft
FROM stolen_vehicles AS sv
LEFT JOIN make_details AS md
    ON sv.make_id = md.make_id
LEFT JOIN locations AS loc
    ON sv.location_id = loc.location_id;
