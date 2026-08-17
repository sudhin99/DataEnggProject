-- ============================================================================
-- analyze_customers.sql - Customer Data Analysis Tasks
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
--
-- MySQL Version Requirement: MySQL 8.0 or higher (for Window Functions)
-- ============================================================================

Execute
USE RELIANT_DWH_BRONZE;


-- ============================================================================
-- SCENARIO 1: Customer Demographics Analysis
-- ============================================================================
-- Task: Analyze customer distribution by city 
--
-- Requirements:
-- 1. Count total customers by city
-- 3. Calculate the percentage of customers in each city
-- 4. Find cities with more than 50 customers
--
-- Expected output columns: city, total_customers, gender, city_percentage
-- ============================================================================

-- Write your query here:




-- ============================================================================


-- ============================================================================
-- SCENARIO 2: Customer Signup Trends
-- ============================================================================
-- Task: Analyze customer signup patterns over time
--
-- Requirements:
-- 1. Count customers signed up each year
-- 2. Count customers signed up each month
-- 3. Find the month with maximum signups
-- 4. Rank years by signup count (highest first)
--
-- Expected output columns: year, month, signup_count, year_rank
-- ============================================================================

-- Write your query here:




-- ============================================================================
-- SCENARIO 3: Customer Contact Information Analysis
-- ============================================================================
-- Task: Analyze customer contact patterns
--
-- Requirements:
-- 1. Count customers with valid email addresses
-- 2. Count customers with valid phone numbers
-- 3. Find customers with both email and phone
-- 4. Categorize customers by contact availability (email only, phone only, both, none)
--
-- Expected output columns: contact_category, customer_count
-- ============================================================================

-- Write your query here:




-- ============================================================================
-- SCENARIO 4: Customer City Ranking
-- ============================================================================
-- Task: Rank cities by customer count using window functions
--
-- Requirements:
-- 1. Count customers per city
-- 2. Rank cities by customer count (ROW_NUMBER)
-- 3. Assign dense rank to cities by customer count
-- 4. Find top 5 cities by customer count
--
-- Expected output columns: city, customer_count, row_num, dense_rank
-- ============================================================================

-- Write your query here:



