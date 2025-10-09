# Data Catalog

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics.

## Dimension Tables

### **gold.dim_product**
Product master data dimension

- **Primary Key**: product_key
- **Natural Key**: product_id
- **Columns**:

| Column Name       | Data Type     | Description                                                                           |
|-------------------|---------------|---------------------------------------------------------------------------------------|
| product_key       | INT           | Surrogate key uniquely identifying each product record in the product dimension table.|
| product_id        | INT           | A unique identifier assigned to the product for internal tracking and referencing.    |
| product_name      | NVARCHAR(50)  | Descriptive name of the product, including key details such as type, color, and size. |
| product_category  | NVARCHAR(50)  | The broader classification of the product (e.g., ) to group related items.            |

---

### **gold.dim_date**
Date dimension for time-based analysis

- **Primary Key**: date_key
- **Date Range**: [2024-01-01] - [2025-09-30]
- **Columns**:

| Column Name    | Data Type    | Description                                                                     |
|----------------|--------------|---------------------------------------------------------------------------------|
| date_key       | INT          | Surrogate key uniquely identifying each date record in the date dimension table.|
| date           | DATE         | Actual date.                                                                    |
| year           | INT          | Calendar year.                                                                  |
| quarter        | INT          | Quarter number(1-4).                                                            |
| month          | INT          | Month number (1-12).                                                            |
| month_name     | NVARCHAR(50) | Full month name.                                                                |
| day_name       | NVARCHAR(50) | Day of week name.                                                               |
| day_type       | NVARCHAR(50) | Weekday/Weekend classification.                                                 |

---

## Fact Table

### **gold.fact_transaction**
Central fact table combining transaction data with customer behavior metrics

- **Foreign key**: (product_key, date_key)
- **Columns**:

| Column Name       | Data Type | Description                                                               |
|-------------------|-----------|---------------------------------------------------------------------------|
| product_key       | INT       | Surrogate key linking the transaction to the product dimension table.     |
| date_key          | INT       | Surrogate key linking the transaction to the date dimension table.        |
| transaction_date  | DATE      | The date when the order was placed.                                       |
| total_unit_sold   | INT       | Total units sold per product per day.                                     |
| product_cost      | FLOAT     | Product cost price.                                                       |
| product_price     | FLOAT     | Product selling price.                                                    |
| total_revenue     | FLOAT     | Total revenue (units × price).                                            |
| total_profit      | FLOAT     | Total profit (units × (price - cost)).                                    |
| total_cost        | FLOAT     | Total cost (units × cost).                                                |
| total_purchases   | INT       | Number of purchase conversions.                                           |
| total_add_to_cart | INT       | Number of add-to-cart actions.                                            |
| total_clicks      | INT       | Number of product clicks.                                                 |
| total_views       | INT       | Number of product views.                                                  |
| click_through_rate| FLOAT     | Click_through rate percentage.                                            |
| conversion_rate   | FLOAT     | Conversion rate percentage.                                               |

