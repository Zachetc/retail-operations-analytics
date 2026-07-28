# Retail Operations Analytics

An end-to-end SQL and business intelligence project that models the operations of a multi-store retailer.

## Business Problem

Retail leaders need a unified view of sales, profit, inventory, supplier performance, customer value, returns, and delivery reliability. These metrics often live in separate operational systems, making it difficult to identify why profit is changing or where action is needed.

This project builds a relational PostgreSQL database, transforms operational data into BI-ready fact tables, and defines a Power BI reporting model for decision-making.

## Questions Answered

- Which stores and product categories generate the most profit?
- Which promotions increase revenue but reduce margin?
- Which suppliers create the greatest operational risk?
- Which products are overstocked, understocked, or candidates for discontinuation?
- Which customer segments are most valuable?
- Where are late deliveries and returns affecting profitability?
- What changed month over month in revenue and margin?

## Architecture

1. Synthetic operational source files in `data/raw`
2. Normalized PostgreSQL schema in `sql/01_schema.sql`
3. Data loading through `sql/02_load_data.sql`
4. Analytical views and indexes
5. Python ETL into BI-ready processed tables
6. Power BI star-schema design and dashboard specification

## Core Tables

Customers, Stores, Employees, Products, Suppliers, Promotions, Orders, Order Items, Shipments, Returns, and Inventory.

## SQL Skills Demonstrated

- Primary and foreign keys
- Constraints and normalization
- CTEs
- Window functions
- `LAG`, `RANK`, and `NTILE`
- Conditional logic
- Views
- Data-quality checks
- Indexing
- Reconciliation queries
- Profitability and risk scoring

## Power BI Model

Recommended model:

- `FactSales`
- `FactDelivery`
- `FactInventory`
- `FactReturns`
- `DimDate`
- `DimCustomer`
- `DimProduct`
- `DimStore`
- `DimSupplier`
- `DimPromotion`

See `powerbi/model_and_dashboard_spec.md` for relationships, measures, and page layouts.

## Run Locally

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python etl/build_bi_model.py
```

Create a PostgreSQL database, then run:

```bash
psql -d retail_analytics -f sql/01_schema.sql
psql -d retail_analytics -f sql/02_load_data.sql
psql -d retail_analytics -f sql/03_views.sql
psql -d retail_analytics -f sql/05_indexes.sql
```

## Repository Structure

```text
data/raw/          Operational source data
data/processed/    BI-ready fact tables
sql/               Schema, loading, views, analysis, indexes, QA
etl/               Python transformation pipeline
powerbi/           Data model and dashboard specification
docs/              ERD and data dictionary
outputs/           Example analytical outputs
```

## Portfolio Value

This project demonstrates the workflow of a data analyst working from raw operational data through relational modeling, SQL analysis, quality validation, and executive BI reporting.
