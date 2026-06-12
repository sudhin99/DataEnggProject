USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_INVENTORY;

CREATE TABLE STG_INVENTORY (
    store_id        VARCHAR(50),
    product_id      VARCHAR(50),
    quantity        VARCHAR(50),
    closing_stock   VARCHAR(50),
    opening_stock   VARCHAR(50),
    inventory_date  VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);