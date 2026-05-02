# Airbnb End-to-End Data Engineering Project

## Overview

An end-to-end data engineering pipeline for Airbnb data built with **AWS S3**, **Snowflake**, and **dbt**. The pipeline processes listings, bookings, and host data through a medallion architecture (Bronze → Silver → Gold), implementing incremental loading, SCD Type 2 slowly changing dimensions, and analytics-ready datasets.

---

## Architecture

```
Source Data (CSV) → AWS S3 → Snowflake Staging → Bronze → Silver → Gold
```

| Layer | Description | Strategy |
|-------|-------------|----------|
| **Bronze** | Raw data ingested from staging with minimal transformation | Incremental |
| **Silver** | Cleaned, validated, and standardized datasets | Incremental |
| **Gold** | Analytics-ready fact tables, SCD2 dimensions, and OBT | Table / Snapshot |

---

## Data Model

### Bronze Layer — Raw Data
- `bronze_bookings` — raw booking transactions
- `bronze_hosts` — raw host information
- `bronze_listings` — raw property listings

### Silver Layer — Cleaned Data
- `silver_bookings` — validated booking records
- `silver_hosts` — enhanced host profiles with quality metrics
- `silver_listings` — standardized listing information with price categorization

### Gold Layer — Analytics Ready
- `fact` — fact table for dimensional modeling
- `obt` — One Big Table joining bookings, listings, and hosts
- `ephemeral/` — intermediate models (not persisted)

### Snapshots — SCD Type 2
- `dim_bookings` — historical booking changes
- `dim_hosts` — historical host profile changes
- `dim_listings` — historical listing changes

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| AWS S3 | Source storage for raw Airbnb CSV files |
| Snowflake | Cloud data warehouse — all transformation layers |
| dbt | SQL-based transformation and modeling framework |
| Jinja | Dynamic SQL templating inside dbt models |
| Python 3.12+ | Project entry point and orchestration support |
| YAML | dbt configuration, source and test definitions |

---

## Project Structure

```
aws_dbt_snowflake_project/
│
├── models/
│   ├── sources/
│   │   └── sources.yml             # Source definitions
│   ├── bronze/
│   │   ├── bronze_bookings.sql
│   │   ├── bronze_hosts.sql
│   │   └── bronze_listings.sql
│   ├── silver/
│   │   ├── silver_bookings.sql
│   │   ├── silver_hosts.sql
│   │   └── silver_listings.sql
│   └── gold/
│       ├── fact.sql
│       ├── obt.sql
│       └── ephemeral/
│           ├── bookings.sql
│           ├── hosts.sql
│           └── listings.sql
│
├── macros/
│   ├── generate_schema_name.sql    # Environment-aware schema naming
│   ├── multiply.sql                # Math operations
│   ├── tag.sql                     # Price categorization logic
│   └── trimmer.sql                 # String utilities
│
├── snapshots/
│   ├── dim_bookings.yml
│   ├── dim_hosts.yml
│   └── dim_listings.yml
│
├── tests/
│   └── source_tests.sql
│
├── dbt_project.yml
└── main.py
```

---

## Prerequisites

- Python 3.12+
- Snowflake account with a database, warehouse, and role configured
- AWS S3 bucket with raw Airbnb CSV source files
- `uv` package manager (`pip install uv`) or `pip`
- dbt-snowflake adapter (`dbt-snowflake>=1.11.0`)

---

## Setup

**1. Clone the repository**
```bash
git clone https://github.com/rec0vv/aws-dbt-snowflake-project.git
cd aws-dbt-snowflake-project
```

**2. Install dependencies**
```bash
uv sync
```

**3. Configure your dbt profile**

Create or update `~/.dbt/profiles.yml`:
```yaml
aws_dbt_snowflake_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_snowflake_account>
      user: <your_username>
      password: <your_password>
      role: ACCOUNTADMIN
      database: AIRBNB
      warehouse: COMPUTE_WH
      schema: dbt_schema
      threads: 4
```

**4. Set up Snowflake staging tables**

Run `DDL/ddl.sql` in Snowflake to create the staging schema and tables, then load source files:

```
bookings.csv  →  AIRBNB.STAGING.BOOKINGS
hosts.csv     →  AIRBNB.STAGING.HOSTS
listings.csv  →  AIRBNB.STAGING.LISTINGS
```

**5. Test your connection**
```bash
cd aws_dbt_snowflake_project
dbt debug
```

---

## Usage

```bash
dbt run                        # Run all models
dbt run --select bronze.*      # Bronze layer only
dbt run --select silver.*      # Silver layer only
dbt run --select gold.*        # Gold layer only
dbt snapshot                   # Run SCD Type 2 snapshots
dbt test                       # Run all data quality tests
dbt build                      # Run models + tests + snapshots together
dbt docs generate && dbt docs serve   # Generate and view documentation
```

---

## Key Features

### Incremental Loading
Bronze and Silver models only process new or changed records on each run:
```sql
{{ config(materialized='incremental') }}
{% if is_incremental() %}
  WHERE CREATED_AT > (SELECT COALESCE(MAX(CREATED_AT), '1900-01-01') FROM {{ this }})
{% endif %}
```

### Price Categorization Macro
A custom `tag()` macro categorizes listing prices into low, medium, and high bands:
```sql
{{ tag('CAST(PRICE_PER_NIGHT AS INT)') }} AS PRICE_PER_NIGHT_TAG
```

### Dynamic OBT Generation
The One Big Table uses Jinja loops to maintain joins in a scalable, readable way rather than hardcoding them.

### SCD Type 2 Snapshots
Dimension tables track historical changes automatically — valid from/to dates are maintained so point-in-time analysis is always accurate.

### Schema Separation by Layer
The `generate_schema_name` macro routes models to the correct Snowflake schema automatically:
- Bronze models → `AIRBNB.BRONZE`
- Silver models → `AIRBNB.SILVER`
- Gold models → `AIRBNB.GOLD`

---

## Data Flow

1. Raw Airbnb CSV files (bookings, hosts, listings) land in **AWS S3**
2. Files are loaded into **Snowflake staging schema**
3. **Bronze** models ingest from staging incrementally
4. **Silver** models clean, validate, and standardize
5. **Gold** models produce the fact table, SCD2 dimension snapshots, and OBT
6. Final datasets are available for BI tools and ad-hoc analytics