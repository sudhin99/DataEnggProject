USE RELIANT_DWH_GOLD;

DROP TABLE IF EXISTS DIM_STORE;

CREATE TABLE DIM_STORE (
    store_key      INT PRIMARY KEY AUTO_INCREMENT,
    store_id       INT,
    store_name     VARCHAR(255),
    city           VARCHAR(100),
    state          VARCHAR(50),
    store_type     VARCHAR(100),
    open_year      INT,
    store_area_sqft INT,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_store_id (store_id),
    INDEX idx_city (city),
    INDEX idx_state (state)
);
