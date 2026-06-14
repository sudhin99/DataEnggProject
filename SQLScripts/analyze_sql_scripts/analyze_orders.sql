-- ============================================================================
-- analyze_orders.sql - Order Data Analysis with Solutions
-- ============================================================================
-- This file contains SQL analysis scenarios with solutions.
-- Concepts covered: GROUP BY, Window Functions, Joins, Subqueries
-- 
-- MySQL Version Requirement: MySQL 8.0 or higher (for CTEs and Window Functions)
-- ============================================================================

USE RELIANT_DWH_BRONZE;

-- ============================================================================
-- SCENARIO 1: Order Volume Analysis by Store
-- ============================================================================
-- Task: Analyze order distribution across stores
-- 
-- Requirements:
-- 1. Count total orders by store
-- 2. Calculate average revenue per order by store
-- 3. Calculate total revenue by store
-- 4. Find stores with above-average revenue
-- ============================================================================

-- Solution:
SELECT 
    store_id,
    COUNT(*) AS total_orders,
    AVG(CAST(revenue AS DECIMAL(10,2))) AS avg_revenue_per_order,
    SUM(CAST(revenue AS DECIMAL(10,2))) AS total_revenue,
    CASE 
        WHEN SUM(CAST(revenue AS DECIMAL(10,2))) > (SELECT AVG(sub.total_store_revenue) FROM (SELECT SUM(CAST(revenue AS DECIMAL(10,2))) AS total_store_revenue FROM STG_ORDERS GROUP BY store_id) sub) THEN 'Above Average'
        ELSE 'Below Average'
    END AS revenue_category
FROM STG_ORDERS
WHERE store_id IS NOT NULL
GROUP BY store_id
ORDER BY total_revenue DESC;


-- ============================================================================
-- SCENARIO 2: Customer Order Patterns
-- ============================================================================
-- Task: Analyze customer ordering behavior
-- 
-- Requirements:
-- 1. Count orders per customer
-- 2. Calculate total revenue per customer
-- 3. Rank customers by total revenue (window function)
-- 4. Find top 10 customers by revenue
-- ============================================================================


