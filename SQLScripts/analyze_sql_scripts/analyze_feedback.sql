-- ============================================================================
-- analyze_feedback.sql - Customer Feedback Analysis with Solutions
-- ============================================================================
-- This file contains SQL analysis scenarios with solutions.
-- Concepts covered: GROUP BY, Window Functions, Joins, CASE WHEN
--
-- MySQL Version Requirement: MySQL 8.0 or higher (for Window Functions)
-- ============================================================================

USE RELIANT_DWH_BRONZE;

-- ============================================================================
-- SCENARIO 1: Customer Rating Analysis
-- ============================================================================
-- Task: Analyze customer ratings distribution
--
-- Requirements:
-- 1. Count feedback by rating value
-- 2. Calculate average rating overall
-- 3. Calculate percentage of each rating
-- 4. Categorize ratings (positive: 4-5, neutral: 3, negative: 1-2)
-- ============================================================================

-- Solution:
SELECT
    CAST(rating AS UNSIGNED) AS rating,
    COUNT(*) AS feedback_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM STG_FEEDBACK WHERE rating IS NOT NULL), 2) AS percentage,
    CASE
        WHEN CAST(rating AS UNSIGNED) >= 4 THEN 'Positive'
        WHEN CAST(rating AS UNSIGNED) = 3 THEN 'Neutral'
        WHEN CAST(rating AS UNSIGNED) <= 2 THEN 'Negative'
        ELSE 'Unknown'
    END AS rating_category
FROM STG_FEEDBACK
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating DESC;

-- ============================================================================
-- SCENARIO 2: Store Rating Performance
-- ============================================================================
-- Task: Analyze store performance based on feedback ratings
--
-- Requirements:
-- 1. Calculate average rating per store
-- 2. Count feedback per store
-- 3. Rank stores by average rating
-- 4. Find stores with below-average ratings
-- ============================================================================

-- Solution:
WITH store_stats AS (
    SELECT
        store_id,
        AVG(CAST(rating AS UNSIGNED)) AS avg_rating,
        COUNT(*) AS feedback_count
    FROM STG_FEEDBACK
    WHERE store_id IS NOT NULL AND rating IS NOT NULL
    GROUP BY store_id
),
overall_avg AS (
    SELECT AVG(CAST(rating AS UNSIGNED)) AS overall_avg_rating
    FROM STG_FEEDBACK
    WHERE rating IS NOT NULL
)
SELECT
    s.store_id,
    s.avg_rating,
    s.feedback_count,
    RANK() OVER (ORDER BY s.avg_rating DESC) AS rating_rank,
    CASE
        WHEN s.avg_rating < o.overall_avg_rating THEN 'Below Average'
        WHEN s.avg_rating > o.overall_avg_rating THEN 'Above Average'
        ELSE 'Average'
    END AS performance_status
FROM store_stats s
CROSS JOIN overall_avg o
ORDER BY s.avg_rating DESC;

-- ============================================================================
-- SCENARIO 3: Feedback Channel Analysis
-- ============================================================================
-- Task: Analyze feedback by channel
--
-- Requirements:
-- 1. Count feedback by channel
-- 2. Calculate average rating by channel
-- 3. Find most popular channel
-- 4. Compare channel performance
-- ============================================================================

-- Solution:
SELECT
    channel,
    COUNT(*) AS feedback_count,
    AVG(CAST(rating AS UNSIGNED)) AS avg_rating,
    ROUND(COUNT(*) * 100.0 / (
