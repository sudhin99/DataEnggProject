-- ==============================================================================
-- 01_setup.sql - MySQL Version
-- Run this ONCE after creating your MySQL database.
-- Creates the database and schemas (simulated as separate databases in MySQL).
-- ==============================================================================

-- Step 1: Create the main database
CREATE DATABASE IF NOT EXISTS RELIANT_DWH;

-- Step 2: Create schema databases (MySQL doesn't have schemas like Snowflake, so we use separate databases)
CREATE DATABASE IF NOT EXISTS RELIANT_DWH_BRONZE;
CREATE DATABASE IF NOT EXISTS RELIANT_DWH_SILVER;
CREATE DATABASE IF NOT EXISTS RELIANT_DWH_GOLD;

-- Step 3: Use the main database
USE RELIANT_DWH;
