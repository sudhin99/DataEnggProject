-- ============================================================================
-- analyze_products.sql - Product Data Analysis Tasks
-- ============================================================================
-- This file contains task scenarios for students to practice SQL.
-- Students should write their own queries to solve each scenario.
-- 
-- Concepts covered:
-- - GROUP BY and aggregation
-- - Window functions (ROW_NUMBER, RANK, DENSE_RANK)
-- - CASE WHEN statements
-- - Subqueries
-- - Joins
-- - String functions
-- 
-- MySQL Version Requirement: MySQL 8.0 or higher (for Window Functions)
-- ============================================================================

USE RELIANT_DWH_BRONZE;

-- ============================================================================
-- SCENARIO 1: Product Category Analysis
-- ============================================================================
-- Task: Analyze product distribution by category and brand
-- 
-- Requirements:
-- 1. Count total products by category
-- 2. Count products by brand within each category
-- 3. Calculate the percentage of products in each category
-- 4. Find categories with more than 20 products
-- 
-- Expected output columns: category, total_products, brand, brand_count, category_percentage
-- ============================================================================

-- Solution:
WITH category_totals AS (
    SELECT 
        category,
        COUNT(*) AS total_products
    FROM STG_PRODUCTS
    GROUP BY category
),
global_total AS (
    SELECT COUNT(*) AS total_count FROM STG_PRODUCTS
)
SELECT 
    p.category,
    ct.total_products,
    p.brand,
    COUNT(*) AS brand_count,
    ROUND((ct.total_products * 100.0) / gt.total_count, 2) AS category_percentage
FROM STG_PRODUCTS p
JOIN category_totals ct ON p.category = ct.category
CROSS JOIN global_total gt
GROUP BY p.category, ct.total_products, p.brand, gt.total_count
HAVING ct.total_products > 20
ORDER BY ct.total_products DESC, brand_count DESC;


-- ============================================================================
-- SCENARIO 2: Product Price Analysis
-- ============================================================================
-- Task: Analyze product pricing patterns
-- 
-- Requirements:
-- 1. Calculate average purchase price by category
-- 2. Calculate average MRP by category
-- 3. Calculate profit margin (MRP - purchase_price) by category
-- 4. Find categories with highest profit margin
-- 
-- Expected output columns: category, avg_purchase_price, avg_MRP, profit_margin
-- ============================================================================

-- Solution:
SELECT 
    category,
    ROUND(AVG(purchase_price), 2) AS avg_purchase_price,
    ROUND(AVG(MRP), 2) AS avg_MRP,
    ROUND(AVG(MRP) - AVG(purchase_price), 2) AS profit_margin
FROM STG_PRODUCTS
GROUP BY category
ORDER BY profit_margin DESC;


-- ============================================================================
-- SCENARIO 3: Product Warranty Analysis
-- ============================================================================
-- Task: Analyze product warranty periods
-- 
-- Requirements:
-- 1. Count products by warranty months
-- 2. Find average warranty period by category
-- 3. Categorize products by warranty duration (short: <12, medium: 12-24, long: >24)
-- 4. Find products with the longest warranty in each category
-- 
-- Expected output columns: category, product_name, warranty_months, warranty_category
-- ============================================================================

-- Solution:
WITH ranked_warranties AS (
    SELECT 
        category,
        product_name,
        CAST(warranty_months AS UNSIGNED) AS warranty_months,
        CASE 
            WHEN CAST(warranty_months AS UNSIGNED) < 12 THEN 'Short'
            WHEN CAST(warranty_months AS UNSIGNED) BETWEEN 12 AND 24 THEN 'Medium'
            WHEN CAST(warranty_months AS UNSIGNED) > 24 THEN 'Long'
            ELSE 'Unknown'
        END AS warranty_category,
        DENSE_RANK() OVER(PARTITION BY category ORDER BY CAST(warranty_months AS UNSIGNED) DESC) AS ranking
    FROM STG_PRODUCTS
    WHERE warranty_months IS NOT NULL
)
SELECT 
    category,
    product_name,
    warranty_months,
    warranty_category
FROM ranked_warranties
WHERE ranking = 1
ORDER BY category;


-- ============================================================================
-- SCENARIO 4: Product Ranking by Price
-- ============================================================================
-- Task: Rank products within categories by MRP using window functions
-- 
-- Requirements:
-- 1. Rank products within each category by MRP (highest first)
-- 2. Find top 3 most expensive products in each category
-- 3. Calculate the price difference from the category average
-- 
-- Expected output columns: category, product_name, MRP, price_rank, category_avg_price, price_diff
-- ============================================================================

-- Solution:
WITH ranked_products AS (
    SELECT 
        category,
        product_name,
        MRP,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY MRP DESC) AS price_rank,
        AVG(MRP) OVER (PARTITION BY category) AS category_avg_price
    FROM STG_PRODUCTS
)
SELECT 
    category,
    product_name,
    MRP,
    price_rank,
    ROUND(category_avg_price, 2) AS category_avg_price,
    ROUND(MRP - category_avg_price, 2) AS price_diff
FROM ranked_products
WHERE price_rank <= 3
ORDER BY category, price_rank;
