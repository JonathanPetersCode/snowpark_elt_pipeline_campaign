# Ad Campaign Media ELT Pipeline (Snowflake & Snowpark)

## Interactive Deliverables

* **SQL Pipeline Setup:** [`sql/01_setup_and_ingestion.sql`](https://www.google.com/search?q=./sql/01_setup_and_ingestion.sql)
* **Formatted Snowpark Notebook Output:** [`notebooks/snowpark_elt_pipeline.html`](https://www.google.com/search?q=./notebooks/snowpark_elt_pipeline.html)

---

## Project overview

This project shows how to process advertising data that was pulled in Snowflake using two methods: standard SQL and Snowpark Python.

It takes raw JSON campaign data, cleans and extracts the key details, calculates budget pacing metrics, and stores the results in ready-to-use database tables.

---

## File Overview

* `sql/01_setup_and_ingestion.sql`: Database setup and SQL table creation scripts.
* `notebooks/snowpark_elt_pipeline.html`: Interactive view of the Python code and its actual output results.

## How It Works

1. **Raw Ingestion:** Incoming data is stored directly in a Snowflake table as raw JSON. This keeps the pipeline flexible so upstream API changes won't break the system.
2. **SQL Transformation:** Uses Snowflake Dynamic Tables to parse the raw JSON and automatically build continuous reporting views.
3. **Python Transformation:** Uses Snowpark Python DataFrames to extract nested metrics, cast currency fields to precise decimals, and calculate budget pacing status.
4. **Final Storage:** Outputs clean, structured tables directly back into Snowflake for reporting and analysis.

---

## Project Highlights

* **Snowpark Pushdown:** All Python code runs directly on Snowflake's cloud hardware rather than pulling data onto a local laptop.
* **Exact Math Precision:** Converts currency values to strict decimals to prevent rounding errors.
* **Smart Budget Status:** Automatically labels campaigns as `OVER_BUDGET`, `UNDER_PACING`, or `ON_PACING`.

---