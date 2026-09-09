# Ad Campaign Media ELT Pipeline (Snowflake & Snowpark)

## Interactive Deliverables

* **SQL Pipeline Setup:** [`sql/01_setup_and_ingestion.sql`]
* **Formatted Snowpark Notebook Output:** [`notebooks/snowpark_elt_pipeline.html`]

---

## What This Project Does

This project shows how to process advertising data in Snowflake using two methods: standard SQL and Snowpark Python.

It takes raw JSON campaign data, cleans and extracts key details, calculates budget pacing metrics, and stores the results in ready-to-use database tables.

---

## How It Works

1. **Raw Ingestion:** Incoming data is stored directly in a Snowflake table as raw JSON. This keeps the pipeline flexible so upstream API changes won't break the system.

2. **SQL Transformation:** Uses Snowflake Dynamic Tables to parse the raw JSON and automatically build continuous reporting views.

3. **Python Transformation:** Uses Snowpark Python DataFrames to extract nested metrics, cast currency fields to precise decimals, and calculate budget pacing status.

4. **Final Storage:** Outputs clean, structured tables directly back into Snowflake for reporting and analysis.

---

## Key Highlights

* **Snowpark Pushdown:** All Python code runs directly on Snowflake's cloud hardware rather than pulling data onto a local laptop.

* **Exact Math Precision:** Converts currency values to strict decimals to prevent rounding errors.

* **Smart Budget Status:** Automatically labels campaigns as `OVER_BUDGET`, `UNDER_PACING`, or `ON_PACING`.

---

## Setup & Troubleshooting Notes

These are were issues that I encountered when setting up Snowflake. I also include the fix and error log if  

## Setup & Troubleshooting Notes

1. **Accidentally Overwriting the Snowflake Session**

   * **Problem:** If you name a variable `session` in Python (like `session = df.collect()`), it wipes out Snowflake's built-in connection object.
   * **Error Log:** `AttributeError: 'list' object has no attribute 'sql'` or `'NoneType' object has no attribute 'table'`

   * **Fix:** Use `session = get_active_session()` once at the top of your notebook, and never reuse the word `session` as a variable name later.

2. **Queries Timing Out on Large Data**
   * **Problem:** Snowflake will automatically cancel long-running queries if your virtual computing warehouse is too small or timed out.
   * **Error Log:** `SQL execution error: Statement reached its execution timeout limit of 3600 seconds and was canceled.`

   * **Fix:** Make sure your warehouse (`INTERVIEW_WH`) is turned on and properly sized before running large JSON parsing tasks.


3. **Pipeline Breaking When Raw Data Changes**
   * **Problem:** Direct insertions into rigid, fixed table columns fail whenever an ad platform changes or adds fields to its API feed.
   * **Error Log:** `SQL compilation error: Insert value list does not match column..`

   * **Fix:** Save raw data directly into a `VARIANT` column first. This lets you extract new JSON fields downstream, without breaking the initial intake process.

4. **Missing Database or Access Permissions**
   * **Problem:** The script was trying to create or read tables in a database that the current logged in user role cannot see.
   * **Error Log:** `Object 'MEDIA_DB.PUBLIC.RAW_CAMPAIGN_DATA' does not exist /  not authorized.`

   * **Fix:**  Always include `USE ROLE` and `USE DATABASE MEDIA_DB` at the top of your scripts, this ensures that you are in the right workspace before running queries. 

---

## File Overview

* `sql/01_setup_and_ingestion.sql`: Database setup and SQL table creation scripts.
* `notebooks/snowpark_elt_pipeline.html`: Interactive view of the Python code and its actual output results.