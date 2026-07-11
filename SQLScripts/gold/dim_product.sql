USE RELIANT_DWH_GOLD;

DROP TABLE IF EXISTS DIM_PRODUCT;

CREATE TABLE DIM_PRODUCT (
    product_key    INT PRIMARY KEY AUTO_INCREMENT,
    product_id     INT,
    product_name   VARCHAR(500),
    category       VARCHAR(200),
    brand          VARCHAR(200),
    purchase_price DECIMAL(12,2),
    mrp            DECIMAL(12,2),
    warranty_months INT,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_product_id (product_id),
    INDEX idx_category (category),
    INDEX idx_brand (brand)
);
