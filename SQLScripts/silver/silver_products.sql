USE RELIANT_DWH_SILVER;

DROP TABLE IF EXISTS SILVER_PRODUCTS;

CREATE TABLE SILVER_PRODUCTS (
    product_id      INT PRIMARY KEY,
    product_name    VARCHAR(500),
    category        VARCHAR(200),
    brand           VARCHAR(200),
    purchase_price  DECIMAL(12,2),
    MRP             DECIMAL(12,2),
    warranty_months INT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_silver_products_category (category),
    INDEX idx_silver_products_brand (brand)
);
