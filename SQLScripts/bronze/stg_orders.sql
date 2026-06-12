USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_ORDERS;

CREATE TABLE STG_ORDERS (
    order_id        VARCHAR(50),
    store_id        VARCHAR(50),
    product_id      VARCHAR(50),
    customer_id     VARCHAR(50),
    order_date      VARCHAR(50),
    quantity        VARCHAR(50),
    selling_price   VARCHAR(50),
    revenue         VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);