USE RELIANT_DWH_SILVER;

DROP TABLE IF EXISTS SILVER_ORDERS;

CREATE TABLE SILVER_ORDERS (
    order_id      INT PRIMARY KEY,
    store_id      INT,
    product_id    INT,
    customer_id   INT,
    order_date    DATE,
    quantity      INT,
    selling_price DECIMAL(12,2),
    revenue       DECIMAL(12,2),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
