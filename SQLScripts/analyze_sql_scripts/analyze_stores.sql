-- ============================================================================
-- analyze_stores.sql - Store Data Analysis with Solutions
-- ============================================================================
-- This file contains SQL analysis scenarios with solutions.
-- Concepts covered: GROUP BY, Window Functions, Joins, CASE WHEN
-- 
-- MySQL Version Requirement: MySQL 8.0 or higher (for Window Functions)
-- ============================================================================

USE RELIANT_DWH_BRONZE;

-- ============================================================================
-- SCENARIO 1: Store Distribution Analysis
-- ============================================================================
-- Task: Analyze store distribution by location and type
-- 
-- Requirements:
-- 1. Count stores by state
-- 2. Count stores by city within each state
-- 3. Count stores by store_type
-- 4. Find states with more than 5 stores
-- ============================================================================

-- Solution:
SELECT 
    state,
    COUNT(*) AS total_stores,
    city,
    COUNT(*) OVER (PARTITION BY state, city) AS stores_in_city,
    store_type,
    COUNT(*) OVER (PARTITION BY store_type) AS stores_by_type
FROM STG_STORES
WHERE state IS NOT NULL
GROUP BY state, city, store_type
HAVING COUNT(*) > 0
ORDER BY state, city;


-- ============================================================================
-- SCENARIO 2: Store Size Analysis
-- ============================================================================
-- Task: Analyze store size patterns
-- 
-- Requirements:
-- 1. Calculate average store area by store_type
-- 2. Categorize stores by size (small: <5000, medium: 5000-10000, large: >10000)
-- 3. Count stores in each size category
-- 4. Find the largest store by area
-- ============================================================================

-- Solution:
SELECT 
    store_id,
    store_name,
    store_type,
    CAST(store_area_sqft AS UNSIGNED) AS store_area,
    CASE 
        WHEN CAST(store_area_sqft AS UNSIGNED) < 5000 THEN 'Small'
        WHEN CAST(store_area_sqft AS UNSIGNED) BETWEEN 5000 AND 10000 THEN 'Medium'
        WHEN CAST(store_area_sqft AS UNSIGNED) > 10000 THEN 'Large'
        ELSE 'Unknown'
    END AS size_category
FROM STG_STORES
WHERE store_area_sqft IS NOT NULL
ORDER BY store_area DESC
LIMIT 1;

-- Count by size category:
SELECT 
    CASE 
        WHEN CAST(store_area_sqft AS UNSIGNED) < 5000 THEN 'Small'
        WHEN CAST(store_area_sqft AS UNSIGNED) BETWEEN 5000 AND 10000 THEN 'Medium'
        WHEN CAST(store_area_sqft AS UNSIGNED) > 10000 THEN 'Large'
        ELSE 'Unknown'
    END AS size_category,
    COUNT(*) AS store_count
FROM STG_STORES
WHERE store_area_sqft IS NOT NULL
GROUP BY size_category;


-- ============================================================================
-- SCENARIO 3: Store Age Analysis
-- ============================================================================
-- Task: Analyze store age distribution
-- 
-- Requirements:
-- 1. Calculate store age (current year - open_year)
-- 2. Categorize stores by age (new: <5, established: 5-10, old: >10)
-- 3. Find average age by store_type
-- 4. Rank stores by age (oldest first)
-- ============================================================================

-- Solution:
SELECT 
    store_id,
    store_name,
    store_type,
    CAST(open_year AS UNSIGNED) AS open_year,
    YEAR(CURDATE()) - CAST(open_year AS UNSIGNED) AS store_age,
    CASE 
        WHEN YEAR(CURDATE()) - CAST(open_year AS UNSIGNED) < 5 THEN 'New'
        WHEN YEAR(CURDATE()) - CAST(open_year AS UNSIGNED) BETWEEN 5 AND 10 THEN 'Established'
        WHEN YEAR(CURDATE()) - CAST(open_year AS UNSIGNED) > 10 THEN 'Old'
        ELSE 'Unknown'
    END AS age_category,
    RANK() OVER (ORDER BY CAST(open_year AS UNSIGNED) ASC) AS age_rank
FROM STG_STORES
WHERE open_year IS NOT NULL
ORDER BY open_year ASC;


-- ============================================================================
-- SCENARIO 4: Store Performance Summary
-- ============================================================================
-- Task: Create a comprehensive store performance summary
-- 
-- Requirements:
-- 1. Count stores by state and store_type
-- 2. Calculate average store area by state
-- 3. Find oldest and newest stores in each state
-- 4. Calculate percentage of stores by store_type
-- ============================================================================

-- Solution:
WITH store_stats AS (
    SELECT 
        state,
        store_type,
        COUNT(*) AS store_count,
        AVG(CAST(store_area_sqft AS UNSIGNED)) AS avg_area,
        MIN(CAST(open_year AS UNSIGNED)) AS oldest_store_year,
        MAX(CAST(open_year AS UNSIGNED)) AS newest_store_year
    FROM STG_STORES
    WHERE state IS NOT NULL
    GROUP BY state, store_type
),
total_stores AS (
    SELECT COUNT(*) AS total FROM STG_STORES
)
SELECT 
    s.state,
    s.store_type,
    s.store_count,
    s.avg_area,
    s.oldest_store_year,
    s.newest_store_year,
    ROUND(s.store_count * 100.0 / t.total, 2) AS percentage
FROM store_stats s
CROSS JOIN total_stores t
ORDER BY s.state, s.store_count DESC;
