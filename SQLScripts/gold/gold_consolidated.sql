-- ============================================================================
-- GOLD LAYER - CONSOLIDATED TABLE & VIEW CREATION SCRIPT
-- ============================================================================
-- This script creates all Gold layer objects in one consolidated file.
-- It includes 5 dimension tables, 3 fact tables, and 3 reporting views.
--
-- Objects Created:
--   DIMENSION TABLES:
--     1. DIM_CUSTOMER
--     2. DIM_DATE
--     3. DIM_PRODUCT
--     4. DIM_STATE
--     5. DIM_STORE
--
--   FACT TABLES:
--     6. FACT_SALES
--     7. FACT_INVENTORY
--     8. FACT_FEEDBACK_REVIEWS
--
--   VIEWS:
--     9. VW_PRODUCT_PERFORMANCE
--    10. VW_SALES_SUMMARY
--    11. VW_STORE_PERFORMANCE
-- ============================================================================

USE RELIANT_DWH_GOLD;

-- ============================================================================
-- DIMENSION TABLES
-- ============================================================================

-- ============================================================================
-- 1. DIM_CUSTOMER
-- ============================================================================
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

-- ============================================================================
-- 2. DIM_DATE
-- ============================================================================
DROP TABLE IF EXISTS DIM_DATE;

CREATE TABLE DIM_DATE (
    date_key    INT PRIMARY KEY AUTO_INCREMENT,
    the_date    DATE NOT NULL,
    year        INT,
    quarter     INT,
    month       INT,
    month_name  VARCHAR(20),
    day         INT,
    day_of_week INT,
    is_weekend  BOOLEAN,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_date (the_date),
    INDEX idx_year_month (year, month)
);

-- ============================================================================
-- 3. DIM_PRODUCT
-- ============================================================================
DROP TABLE IF EXISTS DIM_PRODUCT;

CREATE TABLE DIM_PRODUCT (
    product_key    INT PRIMARY KEY AUTO_INCREMENT,
    product_id     INT,
    product_name   VARCHAR(500),
    category       VARCHAR(200),
    brand          VARCHAR(200),
    purchase_price DECIMAL(12,2),
    mrp            DECIMAL(12,2),
    warranty_months INT,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_product_id (product_id),
    INDEX idx_category (category),
    INDEX idx_brand (brand)
);

-- ============================================================================
-- 4. DIM_STATE
-- ============================================================================
DROP TABLE IF EXISTS DIM_STATE;

CREATE TABLE DIM_STATE (
    state_key    VARCHAR(20) PRIMARY KEY,
    state_code   VARCHAR(10),
    state_name   VARCHAR(100),
    country_name VARCHAR(100) DEFAULT 'INDIA',
    capital      VARCHAR(100),
    updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_state_code (state_code)
);

-- ============================================================================
-- 5. DIM_STORE
-- ============================================================================
DROP TABLE IF EXISTS DIM_STORE;

CREATE TABLE DIM_STORE (
    store_key      INT PRIMARY KEY AUTO_INCREMENT,
    store_id       INT,
    store_name     VARCHAR(255),
    city           VARCHAR(100),
    state          VARCHAR(50),
    store_type     VARCHAR(100),
    open_year      INT,
    store_area_sqft INT,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_store_id (store_id),
    INDEX idx_city (city),
    INDEX idx_state (state)
);

-- ============================================================================
-- FACT TABLES
-- ============================================================================

-- ============================================================================
-- 6. FACT_SALES
-- ============================================================================
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

-- ============================================================================
-- 7. FACT_INVENTORY
-- ============================================================================
DROP TABLE IF EXISTS FACT_INVENTORY;

CREATE TABLE FACT_INVENTORY (
    inventory_key   INT AUTO_INCREMENT PRIMARY KEY,
    date_key        INT,
    product_key     INT,
    store_key       INT,
    quantity_sold   INT,
    opening_stock   INT,
    closing_stock   INT,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_date_product_store (date_key, product_key, store_key),
    INDEX idx_date_key (date_key),
    INDEX idx_product_key (product_key),
    INDEX idx_store_key (store_key),
    INDEX idx_date_store (date_key, store_key),
    INDEX idx_date_product (date_key, product_key),
    FOREIGN KEY (date_key) REFERENCES DIM_DATE(date_key),
    FOREIGN KEY (product_key) REFERENCES DIM_PRODUCT(product_key),
    FOREIGN KEY (store_key) REFERENCES DIM_STORE(store_key)
);

-- ============================================================================
-- 8. FACT_FEEDBACK_REVIEWS
-- ============================================================================
DROP TABLE IF EXISTS FACT_FEEDBACK_REVIEWS;

CREATE TABLE FACT_FEEDBACK_REVIEWS (
    sentiment_key INT AUTO_INCREMENT PRIMARY KEY,
    source_type   VARCHAR(20),
    source_id     INT,
    date_key      INT,
    store_key     INT,
    customer_key  INT,
    rating        INT,
    channel       VARCHAR(50),
    comment       TEXT,
    sentiment     VARCHAR(20),
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_source (source_type, source_id),
    INDEX idx_date_key (date_key),
    INDEX idx_store_key (store_key),
    INDEX idx_customer_key (customer_key),
    INDEX idx_rating (rating),
    INDEX idx_channel (channel),
    INDEX idx_source_type (source_type),
    INDEX idx_sentiment (sentiment),
    INDEX idx_date_store (date_key, store_key),
    FOREIGN KEY (date_key) REFERENCES DIM_DATE(date_key),
    FOREIGN KEY (store_key) REFERENCES DIM_STORE(store_key),
    FOREIGN KEY (customer_key) REFERENCES DIM_CUSTOMER(customer_key)
);

-- ============================================================================
-- REPORTING VIEWS
-- ============================================================================

-- ============================================================================
-- 9. VW_PRODUCT_PERFORMANCE
-- ============================================================================
DROP VIEW IF EXISTS VW_PRODUCT_PERFORMANCE;

CREATE OR REPLACE VIEW VW_PRODUCT_PERFORMANCE AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.mrp,
    COUNT(f.order_id)   AS total_orders,
    SUM(f.quantity)     AS total_units_sold,
    SUM(f.revenue)      AS total_revenue
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_key = p.product_key
GROUP BY 
    p.product_id, 
    p.product_name, 
    p.category, 
    p.brand, 
    p.mrp;

-- ============================================================================
-- 10. VW_SALES_SUMMARY
-- ============================================================================
DROP VIEW IF EXISTS VW_SALES_SUMMARY;

CREATE OR REPLACE VIEW VW_SALES_SUMMARY AS
SELECT
    d.the_date,
    d.year,
    d.month_name,
    d.quarter,
    s.store_name,
    s.city AS store_city,
    s.store_type,
    p.product_name,
    p.category,
    p.brand,
    c.customer_name,
    c.city AS customer_city,
    c.gender,
    f.quantity,
    f.selling_price,
    f.revenue
FROM FACT_SALES f
JOIN DIM_DATE d     ON f.date_key = d.date_key
JOIN DIM_PRODUCT p  ON f.product_key = p.product_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
JOIN DIM_STORE s    ON f.store_key = s.store_key;

-- ============================================================================
-- 11. VW_STORE_PERFORMANCE
-- ============================================================================
DROP VIEW IF EXISTS VW_STORE_PERFORMANCE;

CREATE OR REPLACE VIEW VW_STORE_PERFORMANCE AS
SELECT
    s.store_id,
    s.store_name,
    s.city,
    s.state,
    st.country_name,
    s.store_type,
    s.store_area_sqft,
    COUNT(f.order_id)           AS total_orders,
    SUM(f.revenue)              AS total_revenue,
    ROUND(AVG(f.revenue), 2)    AS avg_order_value,
    SUM(f.quantity)             AS total_units_sold
FROM FACT_SALES f
JOIN DIM_STORE s          ON f.store_key = s.store_key
LEFT JOIN DIM_STATE st    ON s.state = st.state_code
GROUP BY 
    s.store_id, 
    s.store_name, 
    s.city, 
    s.state, 
    st.country_name, 
    s.store_type, 
    s.store_area_sqft;

-- ============================================================================
-- END OF GOLD LAYER CONSOLIDATION SCRIPT
-- ============================================================================
