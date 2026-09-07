# Enterprise Banking Data Platform with Data Vault 2.0

## Overview

The **Enterprise Banking Data Platform** is an end-to-end Data Engineering portfolio project that simulates an enterprise banking data platform using synthetic banking data, Python, Snowflake, Medallion Architecture, Snowpipe Streaming, Snowflake Streams and Tasks, Snowflake Alerts, and Data Vault 2.0.

The project demonstrates how raw banking events can move through multiple data-processing layers:

```text
Synthetic Banking Data
        │
        ▼
      RAW
        │
        ▼
     BRONZE
        │
        ▼
     SILVER
        │
        ▼
  DATA VAULT 2.0
      GOLD
        │
        ▼
    ANALYTICS
```

The platform supports both **initial/batch loading** and **continuous transaction streaming**, allowing the project to demonstrate traditional data warehousing concepts alongside modern streaming-oriented Data Engineering practices.

---

## Project Objectives

The project was designed to demonstrate practical enterprise Data Engineering concepts, including:

* Synthetic banking data generation using Python and Faker
* Generation of customers, accounts, merchants, and transactions
* Intentional data-quality issues in source data
* Data profiling and validation
* Missing-value handling
* Duplicate handling
* Data standardization
* Currency and country standardization
* Referential-integrity validation
* Medallion Architecture
* Snowflake data warehousing
* Snowpipe
* Snowpipe Streaming
* Snowflake Streams
* Snowflake Tasks
* Task dependency graphs
* Incremental data processing
* Snowflake Alerts
* Suspicious-transaction detection
* Data Vault 2.0 modeling
* Hubs, Links, and Satellites
* Hash-key based relationships
* Git-based version control
* Automated and incremental data processing

---

# Architecture

The platform consists of two major execution paths.

### Initial Load

The initial load establishes the complete banking dataset and populates the data platform from RAW through the Data Vault.

```text
Python Initial Data Generator
            │
            ▼
     Initial Payload
            │
            ▼
          RAW
            │
            ▼
         BRONZE
            │
            ▼
         SILVER
            │
            ▼
      DATA VAULT GOLD
            │
            ▼
        ANALYTICS
```

### Streaming

After the initial platform has been populated, the streaming pipeline can be started to continuously generate and ingest new banking transactions.

```text
Transaction Simulator
        │
        ▼
Snowpipe Streaming SDK
        │
        ▼
       RAW
        │
        ▼
     BRONZE
        │
        ▼
     SILVER
        │
        ▼
 Data Vault 2.0 GOLD
        │
        ▼
 Snowflake Alert
        │
        ▼
Suspicious Transaction Log
```

---

# How the Project Works

The project should be executed in **two major phases**:

1. **Initial Load**
2. **Streaming Pipeline**

The initial load should be completed first because it establishes the foundational customers, accounts, merchants, and historical transactions required by the downstream Data Vault model.

Once the initial load is complete, the streaming pipeline can be configured and started to continuously introduce new transactions into the platform.

---

# Phase 1 — Initial Load

## 1. Generate the Initial Banking Dataset

The initial dataset is generated using the Python event generator.

From the project root, run:

```bash
python -m event_generator.initial_data_generation.run
```

This generates the initial synthetic banking dataset containing approximately:

* **100,000 customers**
* **100,000 accounts**
* **10,000 merchants**
* **1,000,000 transactions**

The generated data is intentionally designed to contain realistic variations that can be used to demonstrate data-quality and transformation processes.

The generator creates the source data that will subsequently be loaded into Snowflake.

---

## 2. Execute the Initial Payload SQL

After generating the source data, execute the SQL contained in the **initial payload** section of the project.

This establishes the required Snowflake objects and loads the generated source data into the initial RAW layer.

The initial payload is the starting point for the Snowflake data pipeline.

The general flow is:

```text
Generated CSV / Source Data
          │
          ▼
     Snowflake RAW
```

---

# 3. RAW Layer

The RAW layer represents the source data as it arrives from the simulated banking system.

The purpose of RAW is to preserve the source representation before applying significant transformations.

At this stage, the data may contain:

* Null values
* Duplicate records
* Inconsistent formatting
* Inconsistent country values
* Inconsistent currency values
* Invalid relationships
* Other intentionally introduced data-quality issues

The RAW layer therefore acts as the initial landing zone.

---

# 4. BRONZE Layer

The BRONZE layer performs the first stage of structured processing.

The data is extracted from the RAW representation and converted into a more structured relational format.

The BRONZE layer focuses primarily on:

* Parsing source records
* Extracting fields
* Applying basic data types
* Preserving source information
* Preparing data for deeper validation and transformation

The flow becomes:

```text
RAW
 │
 ▼
BRONZE
```

---

# 5. SILVER Layer

The SILVER layer contains cleansed and standardized banking data.

This layer applies the project's data-quality and transformation logic.

The SILVER processing includes:

* Data profiling
* Null handling
* Duplicate handling
* Data validation
* Country standardization
* Currency standardization
* Lookup-based standardization
* Transaction validation
* Account relationship validation
* Data-type normalization
* Business-rule validation

The result is a cleaner and more consistent representation of the banking data.

```text
BRONZE
   │
   ▼
 SILVER
```

The SILVER layer therefore acts as the trusted operational data layer used by the downstream Data Vault.

---

# 6. Data Vault 2.0 — GOLD Layer

The GOLD layer implements the enterprise Data Vault 2.0 model.

The model is divided into:

```text
             HUBS
              │
        ┌─────┴─────┐
        ▼           ▼
      LINKS     SATELLITES
```

## Hubs

Hubs contain the core business keys of the banking domain.

The project implements hubs for:

* Customers
* Accounts
* Transactions
* Merchants

The hubs use hash keys to provide stable identifiers for Data Vault relationships.

---

## Links

Links represent relationships between business entities.

The project implements relationships including:

* Customer → Account
* Account → Transaction
* Merchant → Transaction

For example:

```text
CUSTOMER
   │
   ▼
ACCOUNT
   │
   ▼
TRANSACTION
   ▲
   │
MERCHANT
```

This allows the Data Vault to represent the relationships between the major banking entities independently of descriptive attributes.

---

## Satellites

Satellites contain descriptive and historical attributes associated with the hubs and relationships.

The project implements satellites for:

* Customers
* Accounts
* Transactions
* Merchants

This separates business keys and relationships from descriptive information and provides the foundation for historical tracking.

---

# Phase 2 — Streaming Pipeline

Once the initial load has been completed, the streaming section can be started.

The streaming pipeline is designed to continuously generate and ingest new banking transactions.

```text
Transaction Generator
        │
        ▼
Snowpipe Streaming SDK
        │
        ▼
RAW
        │
        ▼
BRONZE
        │
        ▼
SILVER
        │
        ▼
DATA VAULT
        │
        ▼
ALERTING
```

---

# 1. Configure the Streaming Environment

Before running the streaming components, create the required environment configuration file.

Create a `.env` file in the appropriate project location.

The `.env` file contains the credentials and configuration required by the streaming application.

**Do not commit the `.env` file to Git.**

The repository should use `.gitignore` to prevent sensitive credentials from being committed.

---

# 2. Generate RSA Keys

Snowpipe Streaming authentication uses key-pair authentication.

Generate an RSA private key using OpenSSL.

For example:

```bash
openssl genrsa -out rsa_key.pem 2048
```

Then generate the corresponding public key:

```bash
openssl rsa -in rsa_key.pem -pubout -out rsa_key.pub
```

The generated private key must be kept secure and must **never be committed to Git**.

The public key is configured in Snowflake for the user that will authenticate with the Snowpipe Streaming client.

The private key is then referenced by the streaming application's environment configuration.

---

# 3. Configure Snowflake Authentication

After generating the RSA key pair:

```text
Private Key
     │
     ▼
Streaming Application
     │
     ▼
Snowpipe Streaming SDK
     │
     ▼
Snowflake
```

The Snowflake user must be configured for key-pair authentication using the generated public key.

The streaming application's `.env` configuration then references the corresponding private key.

---

# 4. Start the Transaction Streaming Generator

After the environment and authentication have been configured, start the transaction streaming component.

The simulator continuously generates new transaction events.

Unlike the initial generator, the streaming generator is designed to produce transactions incrementally rather than generating the entire historical dataset at once.

```text
Transaction Generator
       │
       │ Continuous Events
       ▼
Snowpipe Streaming
```

---

# 5. Snowpipe Streaming

The generated transactions are sent to Snowflake using the **Snowpipe Streaming SDK**.

This allows transaction events to be ingested continuously without requiring the simulator to first create files and wait for traditional batch ingestion.

```text
Transaction Event
        │
        ▼
Snowpipe Streaming SDK
        │
        ▼
Snowflake RAW
```

---

# 6. Bronze → Silver Processing

New streaming records are processed through the same downstream architecture established during the initial load.

Snowflake Streams track newly changed data.

Snowflake Tasks then process the incremental records.

```text
RAW
 │
 ▼
Stream
 │
 ▼
BRONZE
 │
 ▼
Stream
 │
 ▼
SILVER
```

This allows the platform to process newly arriving transactions without repeatedly rebuilding the entire dataset.

---

# 7. Data Vault Incremental Processing

The streaming transactions are subsequently processed into the Data Vault.

The GOLD task graph processes the Data Vault in dependency order:

```text
HUB TRANSACTION
      │
      ▼
ACCOUNT TRANSACTION LINK
      │
      ▼
TRANSACTION SATELLITE
```

The Hub task acts as the root of the transaction task graph.

The Link task runs after the Hub task.

The Satellite task runs after the Link task.

This ensures that the required Hub and Link records exist before dependent records are inserted.

---

# 8. Suspicious Transaction Detection

The platform also implements Snowflake Alert functionality.

Transactions with an amount greater than or equal to:

```text
100,000
```

are treated as suspicious transactions for demonstration purposes.

The alert monitors the transaction satellite and records suspicious transactions in:

```text
BANKING.GOLD.SUSPICIOUS_TRANSACTION_ALERT_LOG
```

The alert architecture is:

```text
Transaction Satellite
        │
        ▼
 Suspicious Transaction
        │
        ▼
 Snowflake Alert
        │
        ├──────────────► Alert Log
        │
        ▼
 Notification
```

This demonstrates how analytical or operational monitoring can be placed directly on top of the Data Vault layer.

---

# Complete End-to-End Flow

The complete platform can therefore be represented as:

```text
                 INITIAL LOAD
                     │
                     ▼
        Python Initial Data Generator
                     │
          ┌──────────┴──────────┐
          │                     │
   100K Customers        100K Accounts
   10K Merchants        1M Transactions
          │                     │
          └──────────┬──────────┘
                     ▼
                   RAW
                     │
                     ▼
                  BRONZE
                     │
                     ▼
                  SILVER
                     │
                     ▼
              DATA VAULT GOLD
                     │
                     ▼
                 ANALYTICS


                 STREAMING
                     │
                     ▼
             Transaction Simulator
                     │
                     ▼
          Snowpipe Streaming SDK
                     │
                     ▼
                   RAW
                     │
                     ▼
                  BRONZE
                     │
                     ▼
                  SILVER
                     │
                     ▼
              DATA VAULT GOLD
                     │
                     ▼
             Suspicious Transaction
                   Alert
                     │
                     ▼
               Alert Log /
               Notification
```

---

# Technology Stack

### Data Generation

* Python
* Faker

### APIs / Ingestion

* FastAPI
* Snowpipe
* Snowpipe Streaming SDK

### Data Platform

* Snowflake
* Snowflake Streams
* Snowflake Tasks
* Snowflake Alerts
* Dynamic Tables

### Data Architecture

* Medallion Architecture
* Data Vault 2.0
* Hubs
* Links
* Satellites

### Development

* SQL
* Git
* GitHub
* GitHub Actions
* OpenSSL

---

# Repository Structure

```text
enterprise-banking-data-platform
│
├── .github/
│
├── api/
│
├── deployment/
│
├── docs/
│
├── event_generator/
│   ├── initial_data_generation/
│   ├── generators/
│   ├── models/
│   ├── quality/
│   ├── services/
│   ├── streaming/
│   └── writers/
│
├── sql/
│   ├── raw/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   │   ├── hubs/
│   │   ├── links/
│   │   └── satellites/
│   │
│   └── analytics/
│
├── tests/
│
├── README.md
│
└── requirements.txt
```

---

# Execution Order

For a clean deployment, follow the project in this order:

### Initial Load

```text
1. Install Python dependencies
        ↓
2. Generate initial banking data
        ↓
3. Run event_generator.initial_data_generation.run
        ↓
4. Execute Initial Payload SQL
        ↓
5. Load RAW
        ↓
6. Process BRONZE
        ↓
7. Process SILVER
        ↓
8. Populate Data Vault GOLD
        ↓
9. Validate the complete initial dataset
```

### Streaming

```text
10. Create .env
        ↓
11. Generate RSA private/public keys with OpenSSL
        ↓
12. Configure Snowflake key-pair authentication
        ↓
13. Configure streaming credentials
        ↓
14. Start transaction simulator
        ↓
15. Start Snowpipe Streaming
        ↓
16. Process RAW → BRONZE
        ↓
17. Process BRONZE → SILVER
        ↓
18. Process SILVER → Data Vault
        ↓
19. Monitor task execution
        ↓
20. Test suspicious transaction alerts
        ↓
21. Validate alert logs / notifications
```

**The initial load should always be completed before starting the streaming section.**

---

# Data Quality Philosophy

The generated data intentionally contains imperfections.

The goal is not to produce a perfectly clean dataset at the source.

Instead, the platform demonstrates how an enterprise Data Engineering system can identify and handle imperfect source data.

Examples include:

* Missing values
* Duplicate records
* Inconsistent country names
* Inconsistent currency representations
* Invalid relationships
* Transaction anomalies
* High-value transactions
* Source-data variations

This allows the RAW layer to remain close to the source while progressively improving data quality through the Bronze and Silver layers.

---

# Data Vault 2.0 Philosophy

The Data Vault layer separates:

```text
Business Keys
     │
     ▼
    Hubs

Relationships
     │
     ▼
    Links

Descriptive / Historical Data
     │
     ▼
 Satellites
```

Hash keys are used throughout the model to provide deterministic identifiers and support scalable relationships between Data Vault entities.

The Data Vault is intentionally separated from the transformation logic in the Silver layer, allowing the platform to maintain a clear distinction between:

* Source ingestion
* Data cleansing
* Business-rule processing
* Enterprise modeling
* Analytics

---

# Streaming Philosophy

The streaming component demonstrates how a banking platform can transition from batch-oriented processing toward continuously arriving data.

The initial load establishes the historical foundation of the platform.

The streaming pipeline then introduces new transactions incrementally.

This results in a hybrid architecture:

```text
Historical Data
      │
      ▼
 Initial Batch Load
      │
      ▼
 Data Platform
      ▲
      │
Continuous Transactions
      │
      ▼
Snowpipe Streaming
```

This approach provides a practical demonstration of both traditional batch processing and modern streaming ingestion within the same platform.

---

# Project Status

## Version 1.0 — Completed

The initial end-to-end banking data platform has been implemented, including:

* Synthetic banking data generation
* Initial dataset generation
* RAW layer
* BRONZE layer
* SILVER layer
* Data profiling
* Data-quality handling
* Data standardization
* Data Vault 2.0
* Hubs
* Links
* Satellites
* Hash-key modeling
* Initial analytical foundation

## Version 1.1 — Completed

The platform has been extended with automated and near-real-time processing capabilities, including:

* Snowpipe configuration
* Snowpipe Streaming
* Snowpipe Streaming SDK
* Transaction event generation
* Incremental ingestion
* Snowflake Streams
* Snowflake Tasks
* Task dependency graphs
* Incremental Data Vault processing
* Suspicious transaction detection
* Snowflake Alerts
* Alert logging
* Notification integration

The project is now a complete end-to-end Data Engineering demonstration rather than only a batch-oriented data warehouse.

---

# Development Approach

The platform was developed incrementally, with each major capability building on the previous layer.

```text
Generate
   ↓
Profile
   ↓
Validate
   ↓
Transform
   ↓
Model
   ↓
Automate
   ↓
Stream
   ↓
Monitor
   ↓
Alert
   ↓
Analyze
```

The project demonstrates how an enterprise banking data platform can evolve from synthetic source data into a continuously processed, modeled, monitored, and analytics-ready data platform.

---

# Key Learning Outcomes

This project demonstrates practical experience with:

* Building an end-to-end Data Engineering pipeline
* Designing Medallion architectures
* Working with Snowflake
* Designing Data Vault 2.0 models
* Working with Hubs, Links, and Satellites
* Building synthetic data generators
* Handling imperfect source data
* Implementing data-quality processes
* Designing incremental transformations
* Working with Snowflake Streams and Tasks
* Building task dependency graphs
* Implementing Snowpipe Streaming
* Working with key-pair authentication
* Using OpenSSL for RSA key generation
* Implementing Snowflake Alerts
* Designing operational monitoring
* Using Git for structured project development

---

## Final Architecture

```text
                    ┌─────────────────────┐
                    │  Synthetic Banking  │
                    │      Generator      │
                    └──────────┬──────────┘
                               │
                 ┌─────────────┴─────────────┐
                 │                           │
                 ▼                           ▼
          INITIAL LOAD                 STREAMING
                 │                           │
                 │                    Snowpipe Streaming
                 │                           │
                 └─────────────┬─────────────┘
                               ▼
                             RAW
                               │
                               ▼
                            BRONZE
                               │
                               ▼
                            SILVER
                               │
                               ▼
                      DATA VAULT 2.0
                            GOLD
                               │
                 ┌─────────────┴─────────────┐
                 │                           │
                 ▼                           ▼
             ANALYTICS               SNOWFLAKE ALERT
                                             │
                                             ▼
                                      ALERT LOG /
                                      NOTIFICATION
```

The result is an end-to-end **Enterprise Banking Data Platform** demonstrating modern Data Engineering practices across data generation, ingestion, transformation, quality, modeling, streaming, monitoring, and alerting.
