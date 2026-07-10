USE motot_theaft;

-- Practice use case: rank regions by theft intensity relative to population size
SELECT
    loc.region,
    COUNT(*) AS theft_count,
    COALESCE(loc.population, 0) AS population,
    ROUND((COUNT(*) / NULLIF(loc.population, 0)) * 100000, 2) AS thefts_per_100k_people,
    ROUND(AVG(YEAR(CURDATE()) - sv.model_year), 1) AS avg_vehicle_age_years
FROM stolen_vehicles AS sv
JOIN locations AS loc
    ON sv.location_id = loc.location_id
GROUP BY
    loc.region,
    loc.population
ORDER BY thefts_per_100k_people DESC, theft_count DESC;
