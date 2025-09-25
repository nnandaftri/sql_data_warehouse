/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_product'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_product
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_product
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.dim_date'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_date
-- Expectation: No results 
SELECT 
    date_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_date
GROUP BY date_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_transaction'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_transaction t
LEFT JOIN gold.dim_product p
ON p.product_key = t.product_key
LEFT JOIN gold.dim_date d
ON d.date_key = t.date_key
WHERE p.product_key IS NULL OR d.date_key IS NULL;
