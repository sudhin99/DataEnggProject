USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_EMPLOYEES;

CREATE TABLE STG_EMPLOYEES (
    emp_id          VARCHAR(50),
    emp_name        VARCHAR(200),
    gender          VARCHAR(20),
    designation     VARCHAR(100),
    store_id        VARCHAR(50),
    city            VARCHAR(100),
    store_name      VARCHAR(255),
    joining_date    VARCHAR(50),
    salary          VARCHAR(50),
    phone_number    VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);