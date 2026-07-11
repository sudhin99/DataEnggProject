USE RELIANT_DWH_GOLD;

DROP TABLE IF EXISTS DIM_CUSTOMER;

CREATE TABLE DIM_CUSTOMER (
    customer_key   INT PRIMARY KEY AUTO_INCREMENT,
    customer_id    INT,
    customer_name  VARCHAR(200),
    gender         VARCHAR(10),
    city           VARCHAR(100),
    phone          VARCHAR(50),
    email          VARCHAR(100),
    signup_date    DATE,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_customer_id (customer_id),
    INDEX idx_city (city)
);
