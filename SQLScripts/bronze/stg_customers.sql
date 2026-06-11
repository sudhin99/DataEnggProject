USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_CUSTOMERS;

CREATE TABLE STG_CUSTOMERS (
    customer_id     VARCHAR(50),
    customer_name   VARCHAR(200),
    gender          VARCHAR(10),
    city            VARCHAR(100),
    phone           VARCHAR(20),
    email           VARCHAR(100),
    signup_date     VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);
