USE motot_theaft;

-- Practice use case: understand theft patterns by make, vehicle type, and color
SELECT
    COALESCE(md.make_name, 'Unknown Make') AS make_name,
    sv.vehicle_type,
    COALESCE(sv.color, 'Unknown') AS color,
    COUNT(*) AS theft_count,
    ROUND(AVG(YEAR(CURDATE()) - sv.model_year), 1) AS avg_vehicle_age_years
FROM stolen_vehicles AS sv
LEFT JOIN make_details AS md
    ON sv.make_id = md.make_id
GROUP BY
    COALESCE(md.make_name, 'Unknown Make'),
    sv.vehicle_type,
    COALESCE(sv.color, 'Unknown')
ORDER BY theft_count DESC, make_name ASC;
