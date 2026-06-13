-- ========================================================================
-- analyze_employees.sql - Employee Data Analysis Tasks
-- ========================================================================
-- This file contains task scenarios for students to practice SQL.
-- Students should write their own queries to solve each scenario.
--
-- Concepts covered:
--   - GROUP BY and aggregation
--   - Window functions (ROW_NUMBER, RANK, DENSE_RANK)
--   - CASE WHEN statements
--   - Subqueries
--   - Joins
--   - Date functions
-- ========================================================================

Execute
USE RELIANT_DWH_BRONZE;

-- ========================================================================
-- SCENARIO 1: Employee Distribution Analysis
-- ========================================================================
-- Task: Analyze employee distribution across stores and cities
--
-- Requirements:
-- 1. Count total employees by store
-- 2. Count employees by designation within each store
-- 3. Calculate the percentage of employees in each store
-- 4. Find stores with more than 10 employees
--
-- Expected output columns: store_id, store_name, total_employees, designation, designation_count
-- ========================================================================

-- Write your query here:




-- ========================================================================
-- SCENARIO 2: Salary Analysis by Designation
-- ========================================================================
-- Task: Analyze salary patterns across designations
--
-- Requirements:
-- 1. Calculate average salary by designation
-- 2. Calculate minimum and maximum salary by designation
-- 3. Find the designation with highest average salary
-- 4. Count employees in each salary range (0-15000, 15000-25000, 25000-35000, >35000)
--
-- Expected output columns: designation, avg_salary, min_salary, max_salary, employee_count
-- ========================================================================

-- Write your query here:




-- ========================================================================
-- SCENARIO 3: Employee Tenure Analysis
-- ========================================================================
-- Task: Analyze employee tenure patterns
--
-- Requirements:
-- 1. Calculate employee tenure in years (current date - joining_date)
-- 2. Count employees by tenure range (0-2 years, 2-5 years, 5-10 years, >10 years)
-- 3. Find average tenure by designation
-- 4. Identify employees with longest tenure in each store
--
-- Expected output columns: employee_id, employee_name, store_id, tenure_years, tenure_category
-- ========================================================================

-- Write your query here:




-- ========================================================================
-- SCENARIO 4: Store Performance by Employee Count
-- ========================================================================
-- Task: Rank stores by employee count using window functions
--
-- Requirements:
-- 1. Count employees per store
-- 2. Calculate total salary expense per store
-- 3. Calculate average salary per store
-- 4. Rank stores by employee count (ROW_NUMBER)
-- 5. Assign dense rank to stores by total salary expense
--
-- Expected output columns: store_id, store_name, employee_count, total_salary, avg_salary, emp_rank, sal_rank
-- ========================================================================

-- Write your query here:


