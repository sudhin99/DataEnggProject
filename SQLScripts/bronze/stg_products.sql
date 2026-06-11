USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_PRODUCTS;

CREATE TABLE STG_PRODUCTS (
    stg_id          INT AUTO_INCREMENT,
    product_id      VARCHAR(50),
    product_name    VARCHAR(200),
    category        VARCHAR(100),
    brand           VARCHAR(100),
    purchase_price  VARCHAR(50),
    selling_price   VARCHAR(50),
    warranty_months VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255),
    row_hash        VARCHAR(64)
);
