USE RELIANT_DWH_GOLD;

DROP TABLE IF EXISTS FACT_SALES;

CREATE TABLE FACT_SALES (
    sales_key       INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT,
    date_key        INT,
    product_key     INT,
    customer_key    INT,
    store_key       INT,
    quantity        INT,
    selling_price   DECIMAL(10,2),
    revenue         DECIMAL(12,2),
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_order_id (order_id),
    INDEX idx_date_key (date_key),
    INDEX idx_product_key (product_key),
    INDEX idx_customer_key (customer_key),
    INDEX idx_store_key (store_key),
    INDEX idx_date_store (date_key, store_key),
    INDEX idx_date_product (date_key, product_key),
    FOREIGN KEY (date_key) REFERENCES DIM_DATE(date_key),
    FOREIGN KEY (product_key) REFERENCES DIM_PRODUCT(product_key),
    FOREIGN KEY (customer_key) REFERENCES DIM_CUSTOMER(customer_key),
    FOREIGN KEY (store_key) REFERENCES DIM_STORE(store_key)
);
