-- 02_region_analysis.sql
-- Compare theft activity by region and country.

SELECT
    COALESCE(loc.region, 'Unknown') AS region,
    COALESCE(loc.country, 'Unknown') AS country,
    COUNT(*) AS theft_count,
    ROUND(AVG(loc.population), 2) AS avg_population,
    ROUND(AVG(loc.density), 2) AS avg_density,
    SUM(CASE WHEN sv.vehicle_type = 'Car' THEN 1 ELSE 0 END) AS car_thefts,
    SUM(CASE WHEN sv.vehicle_type = 'Truck' THEN 1 ELSE 0 END) AS truck_thefts,
    SUM(CASE WHEN sv.vehicle_type = 'Bike' THEN 1 ELSE 0 END) AS bike_thefts
FROM stolen_vehicles AS sv
LEFT JOIN locations AS loc
    ON sv.location_id = loc.location_id
GROUP BY COALESCE(loc.region, 'Unknown'), COALESCE(loc.country, 'Unknown')
ORDER BY theft_count DESC, region;
