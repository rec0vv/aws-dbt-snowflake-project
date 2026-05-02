# aws_dbt_snowflake_project

## Airbnb Analytics Pipeline

This project implements an end-to-end data pipeline using **AWS S3, Snowflake, and dbt**, transforming raw data into analytics-ready datasets through a layered architecture and incremental processing strategy.

The pipeline is designed with scalability and modularity in mind, leveraging **dbt and Jinja templating** to build reusable, maintainable, and efficient data models.

---

## Architecture Overview

The pipeline follows a **medallion architecture**:

* **Bronze Layer**

  * Raw data loaded from AWS S3 into Snowflake staging schema
  * Implemented using **incremental models**
  * Handles initial transformation and ingestion logic

* **Silver Layer**

  * Cleaned and standardized datasets
  * Applies business logic and data normalization
  * Built using **incremental models for performance optimization**

* **Gold Layer**

  * Final analytics layer for reporting and consumption
  * Contains:

    * **Fact table**
    * **Dimension tables (via snapshots)**
    * **One Big Table (OBT)** for denormalized analytics

---

## Technology Stack

* **AWS S3** – Source system for raw data
* **Snowflake** – Cloud data warehouse and staging layer
* **dbt (Data Build Tool)** – Data transformation and modeling
* **Jinja** – Dynamic SQL and metadata-driven transformations
* **VS Code** – Development environment

---

## Key Features

### Incremental Data Processing

Incremental models are implemented in both Bronze and Silver layers to efficiently process only new or updated data, improving performance and scalability.

### Snapshot-Based SCD Type 2

Snapshots are used in the Gold layer to maintain historical records for dimension tables, enabling **Slowly Changing Dimension Type 2 (SCD2)** tracking.

### Metadata-Driven Transformations

Jinja templating is used to dynamically generate SQL logic, particularly in constructing the OBT, enabling scalable and reusable transformations.

### Fact and Dimension Modeling

The Gold layer includes:

* Fact table for transactional analysis
* Dimension tables (snapshots) for descriptive attributes
* OBT for consolidated analytical queries

### Ephemeral Models

Ephemeral models are used to define reusable transformation logic without persisting intermediate tables in Snowflake.

### Custom Macros

Custom macros are implemented to control schema naming and ensure consistent environment-specific configurations.

---

## Project Structure

```plaintext
aws_dbt_snowflake_project/
│
├── models/
│   ├── bronze/          # Incremental ingestion models
│   ├── silver/          # Incremental transformation models
│   ├── gold/
│   │   ├── fact/        # Fact table models
│   │   ├── dim/         # Snapshot-based dimension models
│   │   ├── obt/         # One Big Table (OBT)
│   │   └── ephemeral/   # Reusable intermediate logic
│   └── sources/         # Source definitions (Snowflake staging)
│
├── snapshots/           # SCD Type 2 implementations
├── macros/              # Custom macros (schema handling, etc.)
├── tests/               # Data quality tests
│
└── dbt_project.yml
```

---

## Data Flow

1. Data is extracted from **AWS S3**
2. Loaded into **Snowflake staging schema**
3. Transformed using **dbt models (Bronze → Silver → Gold)**
4. Historical tracking applied via **snapshots**
5. Final datasets exposed for analytics and reporting

---

## Design Approach

* Layered architecture for clear separation of concerns
* Incremental processing for performance optimization
* Snapshot-based history tracking for analytical accuracy
* Metadata-driven modeling using Jinja for scalability
* Modular and reusable transformations