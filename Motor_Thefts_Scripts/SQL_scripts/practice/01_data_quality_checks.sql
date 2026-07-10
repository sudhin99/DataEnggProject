USE motot_theaft;

-- Practice use case: identify incomplete or inconsistent records in the motor theft dataset
SELECT
    'stolen_vehicles' AS table_name,
    'date_stolen' AS column_name,
    COUNT(*) AS missing_count
FROM stolen_vehicles
WHERE date_stolen IS NULL OR TRIM(date_stolen) = ''

UNION ALL

SELECT
    'stolen_vehicles' AS table_name,
    'color' AS column_name,
    COUNT(*) AS missing_count
FROM stolen_vehicles
WHERE color IS NULL OR TRIM(color) = ''

UNION ALL

SELECT
    'locations' AS table_name,
    'population' AS column_name,
    COUNT(*) AS missing_count
FROM locations
WHERE population IS NULL OR TRIM(population) = ''

UNION ALL

SELECT
    'make_details' AS table_name,
    'make_type' AS column_name,
    COUNT(*) AS missing_count
FROM make_details
WHERE make_type IS NULL OR TRIM(make_type) = '';

-- Practice use case: find records that point to missing parent values
SELECT
    sv.vehicle_id,
    sv.make_id,
    sv.location_id,
    md.make_id AS matched_make_id,
    loc.location_id AS matched_location_id
FROM stolen_vehicles AS sv
LEFT JOIN make_details AS md
    ON sv.make_id = md.make_id
LEFT JOIN locations AS loc
    ON sv.location_id = loc.location_id
WHERE md.make_id IS NULL OR loc.location_id IS NULL
ORDER BY sv.vehicle_id;
