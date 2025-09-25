/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

IF OBJECT_ID('silver.prd_info', 'U') IS NOT NULL
    DROP TABLE silver.prd_info;
GO

CREATE TABLE silver.prd_info (
    product_id			NVARCHAR(50),
  	product_name		NVARCHAR(50),
  	product_category	NVARCHAR(50),
  	product_cost		FLOAT,
  	product_price		FLOAT,
  	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.trx_info', 'U') IS NOT NULL
    DROP TABLE silver.trx_info;
GO

CREATE TABLE silver.trx_info (
    trx_id		NVARCHAR(50),
  	product_id	NVARCHAR(50),
  	trx_date	DATE,
  	trx_time	TIME,
  	units		INT,
  	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.funnel', 'U') IS NOT NULL
    DROP TABLE silver.funnel;
GO

CREATE TABLE silver.funnel (
    date		DATE,
  	product_id	NVARCHAR(50),
  	purchase	INT,
  	add_to_cart	INT,
  	click		INT,
  	viewed		INT,
  	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
