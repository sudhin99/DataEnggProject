USE motot_theaft;

-- Practice use case: insert intentionally messy rows to trigger data-quality and anomaly checks
INSERT IGNORE INTO locations (location_id, region, country, population, density)
VALUES
    (999, 'Unknown Region', 'New Zealand', NULL, NULL),
    (1000, 'Test Valley', 'New Zealand', 0, 0.00);

INSERT IGNORE INTO make_details (make_id, make_name, make_type)
VALUES
    (9001, 'Junk Brand', NULL),
    (9002, 'Alpha', '');

INSERT IGNORE INTO stolen_vehicles (vehicle_id, vehicle_type, make_id, model_year, vehicle_desc, color, date_stolen, location_id)
VALUES
    (9001, 'Boat Trailer', NULL, 2035, 'TEMP VEHICLE', '', NULL, NULL),
    (9002, 'Roadbike', 9001, 2050, 'FUTURE BIKE', 'Purple', '2030-01-01', 102);
