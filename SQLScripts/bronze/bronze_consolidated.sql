-- ============================================================================
-- BRONZE LAYER - CONSOLIDATED TABLE CREATION SCRIPT
-- ============================================================================
-- This script creates all Bronze layer objects in one consolidated file.
-- It includes setup tables and all staging tables for the data warehouse.
--
-- Objects Created:
--   1. RELIANT_DWH database
--   2. RELIANT_DWH_BRONZE database
--   3. RELIANT_DWH_SILVER database
--   4. RELIANT_DWH_GOLD database
--   5. FILE_LOAD_LOG
--   6. SP_EXECUTION_LOG
--   7. STG_CUSTOMERS
--   8. STG_DATE_DIM
--   9. STG_EMPLOYEES
--   10. STG_FEEDBACK
--   11. STG_INVENTORY
--   12. STG_ORDERS
--   13. STG_PRODUCTS
--   14. STG_REVIEWS
--   15. STG_STORES
-- ============================================================================

-- Step 1: Create the main database
CREATE DATABASE IF NOT EXISTS RELIANT_DWH;

-- Step 2: Create schema databases (simulated as separate databases in MySQL)
CREATE DATABASE IF NOT EXISTS RELIANT_DWH_BRONZE;
CREATE DATABASE IF NOT EXISTS RELIANT_DWH_SILVER;
CREATE DATABASE IF NOT EXISTS RELIANT_DWH_GOLD;

-- Step 3: Use the bronze database
USE RELIANT_DWH_BRONZE;

-- ============================================================================
-- FILE_LOAD_LOG
-- ============================================================================
CREATE TABLE IF NOT EXISTS FILE_LOAD_LOG (
    log_id          INT AUTO_INCREMENT,
    file_name       VARCHAR(255),
    table_name      VARCHAR(100),
    file_hash       VARCHAR(64),
    rows_loaded     INT,
    load_status     VARCHAR(20),
    error_message   TEXT,
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
);

-- ============================================================================
-- SP_EXECUTION_LOG
-- ============================================================================
CREATE TABLE IF NOT EXISTS SP_EXECUTION_LOG (
    log_id          INT AUTO_INCREMENT,
    sp_name         VARCHAR(100),
    layer           VARCHAR(20),
    target_table    VARCHAR(100),
    started_at      TIMESTAMP NULL,
    ended_at        TIMESTAMP NULL,
    duration_secs   INT,
    watermark_used  TIMESTAMP NULL,
    rows_merged     INT DEFAULT 0,
    status          VARCHAR(20),
    error_message   TEXT,
    logged_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
);

-- ============================================================================
-- STG_CUSTOMERS
-- ============================================================================
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

-- ============================================================================
-- STG_DATE_DIM
-- ============================================================================
DROP TABLE IF EXISTS STG_DATE_DIM;

CREATE TABLE STG_DATE_DIM (
    date            VARCHAR(50),
    year            VARCHAR(50),
    month           VARCHAR(50),
    month_name      VARCHAR(100),
    quarter         VARCHAR(50),
    day             VARCHAR(50),
    weekday_name    VARCHAR(100),
    is_weekend      VARCHAR(20),
    is_public_holiday VARCHAR(20),
    holiday_name    VARCHAR(255),
    is_working_day  VARCHAR(20),
    day_type        VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);

-- ============================================================================
-- STG_EMPLOYEES
-- ============================================================================
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

-- ============================================================================
-- STG_FEEDBACK
-- ============================================================================
DROP TABLE IF EXISTS STG_FEEDBACK;

CREATE TABLE STG_FEEDBACK (
    feedback_id     VARCHAR(50),
    customer_id     VARCHAR(50),
    store_id        VARCHAR(50),
    rating          VARCHAR(50),
    comment         VARCHAR(500),
    channel         VARCHAR(100),
    date            VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);

-- ============================================================================
-- STG_INVENTORY
-- ============================================================================
DROP TABLE IF EXISTS STG_INVENTORY;

CREATE TABLE STG_INVENTORY (
    store_id        VARCHAR(50),
    product_id      VARCHAR(50),
    quantity        VARCHAR(50),
    closing_stock   VARCHAR(50),
    opening_stock   VARCHAR(50),
    inventory_date  VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);

-- ============================================================================
-- STG_ORDERS
-- ============================================================================
DROP TABLE IF EXISTS STG_ORDERS;

CREATE TABLE STG_ORDERS (
    order_id        VARCHAR(50),
    store_id        VARCHAR(50),
    product_id      VARCHAR(50),
    customer_id     VARCHAR(50),
    order_date      VARCHAR(50),
    quantity        VARCHAR(50),
    selling_price   VARCHAR(50),
    revenue         VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);

-- ============================================================================
-- STG_PRODUCTS
-- ============================================================================
DROP TABLE IF EXISTS STG_PRODUCTS;

CREATE TABLE STG_PRODUCTS (
    product_id      VARCHAR(50),
    product_name    VARCHAR(200),
    category        VARCHAR(100),
    brand           VARCHAR(100),
    purchase_price  VARCHAR(50),
    MRP             VARCHAR(50),
    warranty_months VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);

-- ============================================================================
-- STG_REVIEWS
-- ============================================================================
DROP TABLE IF EXISTS STG_REVIEWS;

CREATE TABLE STG_REVIEWS (
    review_id       VARCHAR(50),
    store_id        VARCHAR(50),
    rating          VARCHAR(50),
    text            VARCHAR(1000),
    date            VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);

-- ============================================================================
-- STG_STORES
-- ============================================================================
DROP TABLE IF EXISTS STG_STORES;

CREATE TABLE STG_STORES (
    store_id        VARCHAR(50),
    store_name      VARCHAR(255),
    city            VARCHAR(100),
    state           VARCHAR(50),
    store_type      VARCHAR(100),
    open_year       VARCHAR(50),
    store_area_sqft VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);

-- ============================================================================
-- END OF BRONZE LAYER CONSOLIDATION SCRIPT
-- ============================================================================
