
use motot_theaft;
CREATE TABLE IF NOT EXISTS locations (
        location_id INT PRIMARY KEY, 
        region VARCHAR(200), 
        country VARCHAR(200), 
        population INT, 
        density DECIMAL(10,2)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    
CREATE  TABLE make_details (
        make_id INT PRIMARY KEY, 
        make_name VARCHAR(255), 
        make_type VARCHAR(50)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        
CREATE  TABLE stolen_vehicles (
        vehicle_id INT PRIMARY KEY, 
        vehicle_type VARCHAR(100), 
        make_id INT, 
        model_year INT, 
        vehicle_desc VARCHAR(255), 
        color VARCHAR(50), 
        date_stolen DATE, 
        location_id INT, 
        FOREIGN KEY (make_id) REFERENCES make_details(make_id), 
        FOREIGN KEY (location_id) REFERENCES locations(location_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;