USE RELIANT_DWH_SILVER;

DROP TABLE IF EXISTS SILVER_STORES;

CREATE TABLE SILVER_STORES (
    store_id          INT PRIMARY KEY,
    store_name        VARCHAR(255),
    city              VARCHAR(100),
    state             VARCHAR(50),
    store_type        VARCHAR(100),
    open_year         INT,
    store_area_sqft   INT,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
