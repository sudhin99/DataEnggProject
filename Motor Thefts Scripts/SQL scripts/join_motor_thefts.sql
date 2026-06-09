SELECT
    sv.vehicle_id,
    sv.vehicle_type,
    sv.make_id,
    md.make_name,
    md.make_type,
    sv.model_year,
    sv.vehicle_desc,
    sv.color,
    sv.date_stolen,
    sv.location_id,
    loc.region,
    loc.country,
    loc.population,
    loc.density
FROM stolen_vehicles AS sv
LEFT JOIN make_details AS md
    ON sv.make_id = md.make_id
LEFT JOIN locations AS loc
    ON sv.location_id = loc.location_id;
