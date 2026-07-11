-- ============================================================================
-- SILVER LAYER - CONSOLIDATED TABLE CREATION SCRIPT
-- ============================================================================
-- This script creates all Silver layer tables in one consolidated file.
-- It consolidates all individual silver_*.sql scripts into a single file
-- for easier deployment and management.
-- 
-- Tables Created:
--   1. SILVER_CUSTOMERS
--   2. SILVER_EMPLOYEES
--   3. SILVER_FEEDBACK
--   4. SILVER_INVENTORY
--   5. SILVER_ORDERS
--   6. SILVER_PRODUCTS
--   7. SILVER_REVIEWS
--   8. SILVER_STORES
-- ============================================================================

USE RELIANT_DWH_SILVER;

-- ============================================================================
-- 1. SILVER_CUSTOMERS
-- ============================================================================
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

-- ============================================================================
-- 2. SILVER_EMPLOYEES
-- ============================================================================
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
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. SILVER_FEEDBACK
-- ============================================================================
DROP TABLE IF EXISTS SILVER_FEEDBACK;

CREATE TABLE SILVER_FEEDBACK (
    feedback_id   INT PRIMARY KEY,
    customer_id   INT,
    customer_name VARCHAR(200),
    store_id      INT,
    store_name    VARCHAR(200),
    rating        INT,
    comment       TEXT,
    channel       VARCHAR(50),
    feedback_date DATE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 4. SILVER_INVENTORY
-- ============================================================================
DROP TABLE IF EXISTS SILVER_INVENTORY;

CREATE TABLE SILVER_INVENTORY (
    store_id       INT,
    product_id     INT,
    quantity       INT,
    closing_stock  INT,
    opening_stock  INT,
    inventory_date DATE,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (store_id, product_id, inventory_date)
);

-- ============================================================================
-- 5. SILVER_ORDERS
-- ============================================================================
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

-- ============================================================================
-- 6. SILVER_PRODUCTS
-- ============================================================================
DROP TABLE IF EXISTS SILVER_PRODUCTS;

CREATE TABLE SILVER_PRODUCTS (
    product_id      INT PRIMARY KEY,
    product_name    VARCHAR(500),
    category        VARCHAR(200),
    brand           VARCHAR(200),
    purchase_price  DECIMAL(12,2),
    MRP             DECIMAL(12,2),
    warranty_months INT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 7. SILVER_REVIEWS
-- ============================================================================
DROP TABLE IF EXISTS SILVER_REVIEWS;

CREATE TABLE SILVER_REVIEWS (
    review_id       INT PRIMARY KEY,
    store_id        INT,
    rating          INT,
    text            TEXT,
    review_date     DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 8. SILVER_STORES
-- ============================================================================
DROP TABLE IF EXISTS SILVER_STORES;

CREATE TABLE SILVER_STORES (
    store_id          INT PRIMARY KEY,
    store_name        VARCHAR(255),
    city              VARCHAR(100),
    state             VARCHAR(50),
    store_type        VARCHAR(100),
    open_year         INT,
    store_area_sqft   INT,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- END OF SILVER LAYER CONSOLIDATION SCRIPT
-- ============================================================================
