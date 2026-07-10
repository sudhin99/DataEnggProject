-- 05_risk_insights.sql
-- Rank regions by theft intensity using population-adjusted risk.

WITH region_profile AS (
    SELECT
        COALESCE(loc.region, 'Unknown') AS region,
        COALESCE(loc.country, 'Unknown') AS country,
        MAX(loc.population) AS population,
        MAX(loc.density) AS density,
        COUNT(*) AS theft_count,
        SUM(CASE WHEN sv.vehicle_type = 'Car' THEN 1 ELSE 0 END) AS car_thefts,
        SUM(CASE WHEN sv.color = 'White' THEN 1 ELSE 0 END) AS white_vehicle_thefts
    FROM stolen_vehicles AS sv
    LEFT JOIN locations AS loc
        ON sv.location_id = loc.location_id
    GROUP BY COALESCE(loc.region, 'Unknown'), COALESCE(loc.country, 'Unknown')
)
SELECT
    region,
    country,
    population,
    density,
    theft_count,
    car_thefts,
    white_vehicle_thefts,
    ROUND((theft_count / NULLIF(population, 0)) * 100000, 2) AS thefts_per_100k_people
FROM region_profile
ORDER BY thefts_per_100k_people DESC, theft_count DESC;
