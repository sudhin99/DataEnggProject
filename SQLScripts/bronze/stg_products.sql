USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_PRODUCTS;

CREATE TABLE STG_PRODUCTS (
    product_id      VARCHAR(50),
    product_name    VARCHAR(200),
    category        VARCHAR(100),
    brand           VARCHAR(100),
    purchase_price  VARCHAR(50),
    MRP             VARCHAR(50),
    warranty_months VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);
