-- ============================================================================
-- analyze_inventory.sql - Inventory Data Analysis with Solutions
-- ============================================================================
-- This file contains SQL analysis scenarios with solutions.
-- Concepts covered: GROUP BY, Window Functions, Joins, CASE WHEN
-- 
-- MySQL Version Requirement: MySQL 8.0 or higher (for Window Functions)
-- ============================================================================

USE RELIANT_DWH_BRONZE;

-- ============================================================================
-- SCENARIO 1: Store Inventory Levels
-- ============================================================================
-- Task: Analyze inventory levels across stores
-- 
-- Requirements:
-- 1. Calculate total quantity per store
-- 2. Calculate average quantity per store
-- 3. Find stores with highest inventory
-- 4. Rank stores by total inventory
-- ============================================================================

-- Solution:
SELECT 
    store_id,
    SUM(CAST(quantity AS UNSIGNED)) AS total_quantity,
    AVG(CAST(quantity AS UNSIGNED)) AS avg_quantity,
    RANK() OVER (ORDER BY SUM(CAST(quantity AS UNSIGNED)) DESC) AS inventory_rank
FROM STG_INVENTORY
WHERE store_id IS NOT NULL
GROUP BY store_id
ORDER BY total_quantity DESC;


-- ============================================================================
-- SCENARIO 2: Product Inventory Analysis
-- ============================================================================
-- Task: Analyze inventory levels by product
-- 
-- Requirements:
-- 1. Calculate total quantity per product
-- 2. Count how many stores stock each product
-- 3. Find products with low inventory (< 100 total)
-- 4. Find products with high inventory (> 1000 total)
-- ============================================================================

-- Solution:
SELECT 
    product_id,
    SUM(CAST(quantity AS UNSIGNED)) AS total_quantity,
    COUNT(DISTINCT store_id) AS stores_stocking,
    CASE 
        WHEN SUM(CAST(quantity AS UNSIGNED)) < 100 THEN 'Low Inventory'
        WHEN SUM(CAST(quantity AS UNSIGNED)) > 1000 THEN 'High Inventory'
        ELSE 'Normal Inventory'
    END AS inventory_status
FROM STG_INVENTORY
WHERE product_id IS NOT NULL
GROUP BY product_id
ORDER BY total_quantity DESC;


-- ============================================================================
-- SCENARIO 3: Inventory Movement Analysis
-- ============================================================================
-- Task: Analyze inventory changes using opening and closing stocks
-- 
-- Requirements:
-- 1. Calculate total opening stock by store
-- 2. Calculate total closing stock by store
-- 3. Calculate inventory change (closing - opening)
-- 4. Find stores with negative inventory change (stock depletion)
-- ============================================================================

-- Solution:
SELECT 
    store_id,
    SUM(CAST(opening_stock AS UNSIGNED)) AS total_opening_stock,
    SUM(CAST(closing_stock AS UNSIGNED)) AS total_closing_stock,
    SUM(CAST(closing_stock AS UNSIGNED)) - SUM(CAST(opening_stock AS UNSIGNED)) AS inventory_change,
    CASE 
        WHEN SUM(CAST(closing_stock AS UNSIGNED)) - SUM(CAST(opening_stock AS UNSIGNED)) < 0 THEN 'Stock Depletion'
        WHEN SUM(CAST(closing_stock AS UNSIGNED)) - SUM(CAST(opening_stock AS UNSIGNED)) > 0 THEN 'Stock Accumulation'
        ELSE 'No Change'
    END AS movement_status
FROM STG_INVENTORY
WHERE opening_stock IS NOT NULL AND closing_stock IS NOT NULL
GROUP BY store_id
ORDER BY inventory_change ASC;

