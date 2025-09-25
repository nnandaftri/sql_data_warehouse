
/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges.
	- Missing values.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.prd_info'
-- ====================================================================
select * from silver.prd_info;

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    product_id,
    COUNT(product_id) AS frekuensi
FROM silver.prd_info
GROUP BY product_id
HAVING COUNT(product_id) > 1 OR product_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    product_category
FROM silver.prd_info
WHERE product_category != TRIM(product_category);

-- Data Standardization & Consistency
SELECT DISTINCT 
    product_category
FROM silver.prd_info;

-- Check for NULLs or Negative Values
-- Expectation: No Results
SELECT 
    product_price
FROM silver.prd_info
WHERE product_price < 0 OR product_price IS NULL;

-- ====================================================================
-- Checking 'silver.trx_info'
-- ====================================================================
select * from silver.trx_info;

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    trx_id,
    COUNT(*) 
FROM silver.trx_info
GROUP BY trx_id
HAVING COUNT(*) > 1 OR trx_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    product_id
FROM silver.trx_info
WHERE product_id != TRIM(product_id);

-- Data Standardization & Consistency
SELECT DISTINCT 
    product_id 
FROM silver.trx_info
ORDER BY product_id;

-- Check for Invalid Date Orders
-- Expectation: No Results
SELECT DISTINCT
    NULLIF(trx_date, 0) AS trx_date
FROM silver.trx_info
WHERE trx_date <= 0 
    OR LEN(trx_date) != 8 ;

-- Check for NULLs or Negative Values in Unit
-- Expectation: No Results
SELECT 
    units
FROM silver.trx_info
WHERE units < 0 OR units IS NULL;

-- ====================================================================
-- Checking 'silver.funnel'
-- ====================================================================
select * from silver.funnel;

-- Check for Duplicates in date and product_id
-- Expectation: No Results
SELECT
	COUNT(*)
FROM silver.funnel
GROUP BY date, product_id
HAVING COUNT(*) > 1;

-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT DISTINCT
    NULLIF(date, 0) AS date 
FROM silver.funnel
WHERE date <= 0 
    OR LEN(date) != 8;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    product_id
FROM silver.funnel
WHERE product_id != TRIM(product_id);

-- Check for NULLs or Negative Values
-- Expectation: No Results
SELECT 
    viewed
FROM silver.funnel
WHERE viewed < 0 OR viewed IS NULL;
