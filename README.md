# Data Warehouse Project With SSMS

## Overview
Implementation of a **star schema** data warehouse for e-commerce analytics, complete with a comprehensive data integration flow from raw data to ready-to-use business insights.

## 🏗️ Data Architecture

![data architecture](docs/data_architecture.png)

## Data Flow
![data flow](docs/data_flow.png)

## Star Schema
![star schema](docs/star_schema.png)

## ⚡ Quick Start
### Prerequisites
- SQL Server 2016+
- SSMS (SQL Server Management Studio)
- Basic understanding of T-SQL

### Installation
1. Clone the repository
    ```
    git clone https://github.com/nnandaftri/sql_data_warehouse.git
    cd sql_data_warehouse
    ```
2. Install the necessary dependencies.
3. Execute setup scripts in order:
    ```
    1. \scripts\init_database.sql
    2. bronze
        - \scripts\bronze\ddl_bronze.sql
        - \scripts\bronze\procedure_load_bronze.sql
    3. silver
        - \scripts\silver\ddl_silver.sql
        - \scripts\silver\procedure_load_silver.sql
    4. gold
        - \scripts\gold\ddl_silver.sql
    ```

## 📄 License
This project is licensed under the [MIT License](https://github.com/nnandaftri/sql_data_warehouse/blob/main/LICENSE). You are free to use, modify, and share this project with proper attribution.
