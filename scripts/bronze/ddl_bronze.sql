/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.prd_info;
GO

CREATE TABLE bronze.prd_info (
    product_id			NVARCHAR(50),
	product_name		NVARCHAR(50),
	product_category	NVARCHAR(50),
	product_cost		NVARCHAR(50),
	product_price		NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.trx_info', 'U') IS NOT NULL
    DROP TABLE bronze.trx_info;
GO

CREATE TABLE bronze.trx_info (
    trx_id		NVARCHAR(50),
	product_id	NVARCHAR(50),
	trx_date	INT,
	trx_time	TIME,
	units		INT
);
GO

IF OBJECT_ID('bronze.funnel', 'U') IS NOT NULL
    DROP TABLE bronze.funnel;
GO

CREATE TABLE bronze.funnel (
    date		INT,
	product_id	NVARCHAR(50),
	purchase	INT,
	add_to_cart	INT,
	click		INT,
	viewed		INT,
);
GO
