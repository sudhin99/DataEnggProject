USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_CUSTOMERS;

CREATE TABLE STG_CUSTOMERS (
    stg_id          INT AUTO_INCREMENT,
    customer_id     VARCHAR(50),
    customer_name   VARCHAR(200),
    gender          VARCHAR(10),
    city            VARCHAR(100),
    phone           VARCHAR(20),
    email           VARCHAR(100),
    signup_date     VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255),
    row_hash        VARCHAR(64)
);
