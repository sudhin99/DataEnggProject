USE RELIANT_DWH_SILVER;

DROP TABLE IF EXISTS SILVER_EMPLOYEES;

CREATE TABLE SILVER_EMPLOYEES (
    emp_id          INT PRIMARY KEY,
    emp_name        VARCHAR(200),
    gender          VARCHAR(20),
    designation     VARCHAR(100),
    store_id        INT,
    city            VARCHAR(100),
    store_name      VARCHAR(255),
    joining_date    DATE,
    salary          DECIMAL(12,2),
    phone_number    VARCHAR(50),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_silver_employees_store_id (store_id),
    INDEX idx_silver_employees_city (city),
    INDEX idx_silver_employees_joining_date (joining_date)
);
