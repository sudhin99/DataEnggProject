USE RELIANT_DWH_GOLD;

DROP TABLE IF EXISTS FACT_INVENTORY;

CREATE TABLE FACT_INVENTORY (
    inventory_key   INT AUTO_INCREMENT PRIMARY KEY,
    date_key        INT,
    product_key     INT,
    store_key       INT,
    quantity_sold   INT,
    opening_stock   INT,
    closing_stock   INT,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_date_product_store (date_key, product_key, store_key),
    INDEX idx_date_key (date_key),
    INDEX idx_product_key (product_key),
    INDEX idx_store_key (store_key),
    INDEX idx_date_store (date_key, store_key),
    INDEX idx_date_product (date_key, product_key),
    FOREIGN KEY (date_key) REFERENCES DIM_DATE(date_key),
    FOREIGN KEY (product_key) REFERENCES DIM_PRODUCT(product_key),
    FOREIGN KEY (store_key) REFERENCES DIM_STORE(store_key)
);
