USE RELIANT_DWH_SILVER;

DROP TABLE IF EXISTS SILVER_CUSTOMERS;

CREATE TABLE SILVER_CUSTOMERS (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(200),
    gender        VARCHAR(10),
    city          VARCHAR(100),
    phone         VARCHAR(20),
    email         VARCHAR(100),
    signup_date   DATE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
