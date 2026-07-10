USE motot_theaft;

-- Practice use case: find duplicate make names that may need cleanup
SELECT
    make_name,
    COUNT(*) AS duplicate_count
FROM make_details
GROUP BY make_name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Practice use case: find suspicious vehicle records based on dates and model year
SELECT
    vehicle_id,
    vehicle_type,
    make_id,
    model_year,
    date_stolen,
    location_id
FROM stolen_vehicles
WHERE date_stolen > CURDATE()
   OR model_year > YEAR(CURDATE())
   OR model_year < 1900
ORDER BY date_stolen;
