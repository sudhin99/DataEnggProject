USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_STORES;

CREATE TABLE STG_STORES (
    store_id        VARCHAR(50),
    store_name      VARCHAR(255),
    city            VARCHAR(100),
    state           VARCHAR(50),
    store_type      VARCHAR(100),
    open_year       VARCHAR(50),
    store_area_sqft VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);