# SQL Data Warehouse: Medallion Architecture

## Overview
This repository contains a SQL-based Data Warehouse project implementing the Medallion Architecture. The project is designed to ingest raw data from CSV files and process it through progressive layers (Bronze, Silver, and Gold) to ensure data quality, enhance engineering tracking, and enforce role-based data privacy for end users. The pipeline concludes with a comprehensive data analysis phase.

## Architecture Architecture

This project processes data through three distinct layers:

### 1. Bronze Layer (Raw Data)
*   **Source:** Ingested directly from raw CSV files.
*   **State:** Unfiltered, unvalidated, and dirty data.
*   **Purpose:** Serves as the historical archive and an exact replica of the source data.

### 2. Silver Layer (Cleaned & Enriched Data)
*   **Transformations:** Data cleansing, type casting, and standardization.
*   **Enhancements:** Addition of technical metadata columns (e.g., column creation timestamps, ingestion dates) designed specifically for data engineering tracking and auditing.
*   **Purpose:** Provides a validated, clean foundation of enterprise data.

### 3. Gold Layer (Presentation & Access Control)
*   **Transformations:** Business-level aggregations and the creation of targeted SQL views.
*   **Data Privacy & Security:** Simulates department-level access control. Views are tailored so different departments only have access to the data they need. For instance, business analysts are granted access to analytical views but are restricted from viewing the engineering metadata generated in the Silver layer.
*   **Purpose:** Delivers secure, business-ready data optimized for reporting and analytics.

## Data Analysis
Upon completion of the data engineering pipeline, a comprehensive data analysis is conducted querying the secure views established in the Gold layer to extract business insights.

## Technologies Used
*   SQL
*   [Insert your specific SQL dialect/RDBMS here, e.g., PostgreSQL, SQL Server, Snowflake]

## Repository Structure
```text
├── 1_bronze/         # SQL scripts for raw data ingestion from CSV
├── 2_silver/         # SQL scripts for data cleaning and metadata generation
├── 3_gold/           # SQL scripts for view creation and access control logic
├── analysis/         # SQL scripts and queries used for final data analysis
├── data/             # Directory for source CSV files
└── README.md         # Project documentation
