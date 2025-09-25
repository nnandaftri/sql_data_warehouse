/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading silver Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading Products Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.prd_info';
		TRUNCATE TABLE silver.prd_info;

		PRINT '>> Inserting Data Into: silver.prd_info';
		INSERT INTO silver.prd_info (
			product_id,
			product_name,
			product_category,
			product_cost,
			product_price
		)
		SELECT 
			product_id,
			product_name,
			product_category,
			CAST(REPLACE(product_cost, 'IDR ', '') AS INT) AS product_cost,
			CAST(REPLACE(product_price, 'IDR ', '') AS INT) AS product_price
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY product_id) AS frequency
			FROM bronze.prd_info
			WHERE product_id IS NOT NULL
			)t
		WHERE frequency = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------';


		PRINT '------------------------------------------------';
		PRINT 'Loading Transaction Tables';
		PRINT '------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.trx_info';
		TRUNCATE TABLE silver.trx_info;

		PRINT '>> Inserting Data Into: silver.trx_info';
		INSERT INTO silver.trx_info (
			trx_id,
			product_id,
			trx_date,
			trx_time,
			units
		)
		SELECT
			trx_id,
			product_id,
			CASE
				WHEN LEN(CAST(trx_date AS VARCHAR(10))) = 7 THEN
					TRY_CAST(
						CONCAT(
							RIGHT(CAST(trx_date AS VARCHAR(10)), 4),
							SUBSTRING(CAST(trx_date AS VARCHAR(10)), 2, 2),
							'0', LEFT(CAST(trx_date AS VARCHAR(10)), 1)
						) AS DATE
					)
				WHEN LEN(CAST(trx_date AS VARCHAR(10))) = 8 THEN
					TRY_CAST(
						CONCAT(
							RIGHT(CAST(trx_date AS VARCHAR(10)), 4),
							SUBSTRING(CAST(trx_date AS VARCHAR(10)), 3, 2),
							LEFT(CAST(trx_date AS VARCHAR(10)), 2)
						) AS DATE
					)
				ELSE NULL
			END AS trx_date,
			trx_time,
			COALESCE(units, 0) AS units
		FROM bronze.trx_info
		WHERE trx_id IS NOT NULL 
			AND ISNUMERIC(CAST(trx_date AS VARCHAR(10))) = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------';

		
		PRINT '------------------------------------------------';
		PRINT 'Loading Funnel Tables';
		PRINT '------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.funnel';
		TRUNCATE TABLE silver.funnel;

		PRINT '>> Inserting Data Into: silver.funnel';
		INSERT INTO silver.funnel (
			date,
			product_id,
			purchase,
			add_to_cart,
			click,
			viewed
		)
		SELECT
			CASE
				WHEN LEN(CAST(date AS VARCHAR(10))) = 7 THEN
					TRY_CAST(
						CONCAT(
							RIGHT(CAST(date AS VARCHAR(10)), 4),
							SUBSTRING(CAST(date AS VARCHAR(10)), 2, 2),
							'0', LEFT(CAST(date AS VARCHAR(10)), 1)
						) AS DATE
					)
				WHEN LEN(CAST(date AS VARCHAR(10))) = 8 THEN
					TRY_CAST(
						CONCAT(
							RIGHT(CAST(date AS VARCHAR(10)), 4),
							SUBSTRING(CAST(date AS VARCHAR(10)), 3, 2),
							LEFT(CAST(date AS VARCHAR(10)), 2)
						) AS DATE
					)
				ELSE NULL
			END AS date,
			TRIM(product_id) AS product_id,
			purchase,
			add_to_cart,
			click,
			viewed
		FROM bronze.funnel;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ------------------';


		SET @batch_end_time = GETDATE();
		PRINT '============================================='
		PRINT 'Loading silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '============================================='
	END TRY
	BEGIN CATCH
		PRINT '============================================='
		PRINT 'ERROR OCCURED DURING LOADING silver LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '============================================='
	END CATCH
END
