/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_product
-- =============================================================================

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO

CREATE VIEW gold.dim_product AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key, -- Surrogate key
    product_id,
	product_name,
	product_category
FROM silver.prd_info;
GO

-- =============================================================================
-- Create Dimension: gold.dim_date
-- =============================================================================
IF OBJECT_ID('gold.dim_date', 'V') IS NOT NULL
    DROP VIEW gold.dim_date;
GO

CREATE VIEW gold.dim_date AS
WITH all_dates AS (
    SELECT DISTINCT date 
    FROM silver.funnel
    UNION 
    SELECT DISTINCT trx_date 
    FROM silver.trx_info
    WHERE trx_date IS NOT NULL
)
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), date, 112)) AS date_key, -- Surrogate key
    date,
    YEAR(date) AS year,
    DATEPART(QUARTER, date) AS quarter,
    DATEPART(MONTH, date) AS month,
    DATENAME(MONTH, date) AS month_name,
    DATEPART(WEEK, date) AS week_number,
    DATEPART(DAY, date) AS day,
    DATENAME(WEEKDAY, date) AS day_name,
    CASE 
        WHEN DATEPART(WEEKDAY, date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type
FROM all_dates
WHERE date IS NOT NULL;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_transaction
-- =============================================================================
IF OBJECT_ID('gold.fact_transaction', 'V') IS NOT NULL
    DROP VIEW gold.fact_transaction;
GO

CREATE VIEW gold.fact_transaction AS
WITH transaksi AS (
	SELECT
		product_id,
		trx_date,
		SUM(units) AS total_units_sold
	FROM silver.trx_info
	GROUP BY product_id, trx_date
),
produk AS (
	SELECT DISTINCT
		product_id,
		product_cost,
		product_price
	FROM silver.prd_info
),
funnel AS (
	SELECT
		date,
		product_id,
		SUM(purchase) AS total_purchases,
		SUM(add_to_cart) AS total_add_to_cart,
		SUM(click) AS total_clicks,
		SUM(viewed) AS total_views
	FROM silver.funnel
	GROUP BY date, product_id
),
base_data AS (
    SELECT DISTINCT 
        COALESCE(f.date, t.trx_date) AS transaction_date,
        COALESCE(f.product_id, t.product_id) AS product_id
    FROM funnel f
    FULL OUTER JOIN transaksi t 
        ON f.date = t.trx_date AND f.product_id = t.product_id
    WHERE COALESCE(f.product_id, t.product_id) IS NOT NULL
)
SELECT
    dp.product_key,
    dd.date_key,
    t.total_units_sold,
    p.product_cost AS cost_each,
    p.product_price AS price_each,
    t.total_units_sold * p.product_price AS total_revenue,
    t.total_units_sold * (p.product_price - p.product_cost) AS total_profit,
    t.total_units_sold * p.product_cost AS total_cost,
    f.total_purchases,
    f.total_add_to_cart,
    f.total_clicks,
    f.total_views,
    CASE 
        WHEN f.total_views > 0 
        THEN ROUND(f.total_clicks * 100.0 / f.total_views, 2)
        ELSE 0 
    END AS click_through_rate,
    CASE 
        WHEN f.total_clicks > 0 
        THEN ROUND(f.total_purchases * 100.0 / f.total_clicks, 2)
        ELSE 0 
    END AS conversion_rate
FROM base_data bd
INNER JOIN gold.dim_product dp ON bd.product_id = dp.product_id
INNER JOIN gold.dim_date dd ON bd.transaction_date = dd.date
LEFT JOIN transaksi t ON bd.product_id = t.product_id AND bd.transaction_date = t.trx_date
LEFT JOIN funnel f ON bd.product_id = f.product_id AND bd.transaction_date = f.date
INNER JOIN produk p ON bd.product_id = p.product_id;
GO
