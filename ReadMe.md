# Enterprise Banking Data Platform with Data Vault 2.0

## Overview

The **Enterprise Banking Data Platform** is a Data Engineering portfolio project that simulates a banking data platform using synthetic banking data, Snowflake, Medallion Architecture, and Data Vault 2.0.

The project is being developed incrementally to demonstrate real-world Data Engineering practices including synthetic data generation, data-quality handling, data transformation, enterprise data modeling, automated ingestion, and analytical processing.

The initial version focuses on establishing a complete data platform foundation, from synthetic source data through the Bronze and Silver layers and into a Data Vault 2.0 model.

---

## Objectives

* Simulate banking customers, accounts, merchants, and transactions using Python and Faker
* Generate realistic source-data variations and intentional data-quality issues
* Ingest and process banking data in Snowflake
* Implement the Medallion Architecture (Raw → Bronze → Silver → Gold)
* Perform data profiling, cleansing, standardization, and validation
* Model enterprise banking data using Data Vault 2.0
* Implement Hubs, Links, and Satellites
* Build automated ingestion and processing capabilities incrementally
* Develop analytical capabilities on top of the processed banking data
* Demonstrate Git-based versioning and incremental platform development

---

## Current Architecture

Version 1.0 establishes the following architecture:

```text
Banking Data Generator
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
 Data Vault 2.0
      GOLD
        │
        ▼
   Analytics
```

The current implementation is primarily focused on establishing the **data generation, transformation, data-quality, and Data Vault foundations**.

Future versions will introduce more automated and near-real-time ingestion mechanisms.

---

## Version 1.0 — Completed

Version 1.0 establishes the initial end-to-end data platform foundation.

Implemented:

* Synthetic banking data generation using Python and Faker
* Customer, account, merchant, and transaction generation
* Intentional source-data variations for data-quality and transformation testing
* Raw and Bronze data layers
* Silver-layer cleansing and standardization
* Data profiling and validation
* Lookup-based data standardization
* Handling of missing and inconsistent values
* Currency and country standardization
* Transaction/account relationship validation
* Data Vault 2.0 modeling
* Customer, Account, Transaction, and Merchant Hubs
* Customer–Account, Account–Transaction, and Merchant–Transaction Links
* Customer, Account, Transaction, and Merchant Satellites
* Hash-key based Data Vault relationships
* Git-based version control and milestone-based development

Version 1.0 serves as the **stable baseline** for future development.

---

## Synthetic Data Generation

The banking data used by this project is synthetically generated using Python and Faker.

The generator is **not intended to be a perfect representation of a real banking system**. It is primarily designed to provide realistic enough data to exercise Data Engineering concepts such as:

* Data profiling
* Data-quality validation
* Standardization
* Deduplication
* Null handling
* Referential integrity
* Data Vault modeling
* Incremental ingestion

The generator will continue to evolve throughout the development of the project.

Additional business rules, data-quality scenarios, transaction behaviors, account states, and other realistic variations may be introduced in future versions.

As the generated source data evolves, the **Silver layer and its transformation logic will naturally evolve with it**. This is intentional: changes in source-data characteristics should result in corresponding changes to profiling, cleansing, standardization, and transformation logic.

Therefore, the current Silver implementation should be viewed as the transformation logic appropriate for the current version of the synthetic source data rather than a final or immutable implementation.

---

## Technology Stack

* Python
* Faker
* FastAPI
* Snowflake
* Snowpipe
* Snowpipe Streaming
* Snowflake Streams
* Dynamic Tables
* SQL
* Data Vault 2.0
* Git
* GitHub
* GitHub Actions

---

## Project Status

🚧 **Version 1.0 — Completed**

The initial platform foundation has been implemented and is ready to serve as the baseline for subsequent development.

### Version 1.1 — In Progress

The next development phase focuses on **automated ingestion using Snowpipe**.

Planned Version 1.1 work includes:

* Configure Snowflake stages for automated file ingestion
* Implement Snowpipe
* Automatically load newly generated files into the Bronze layer
* Test continuous ingestion
* Validate ingestion history and failures
* Update ingestion documentation
* Preserve the existing Bronze → Silver → Data Vault architecture

Future versions may extend this further toward **Snowpipe Streaming and event-driven transaction ingestion**.

---

## Roadmap

### Version 1.0 — Foundation

* [x] Build Banking Data Simulator
* [x] Generate customers, accounts, merchants, and transactions
* [x] Implement Raw/Bronze ingestion
* [x] Implement Silver transformations
* [x] Implement data profiling and validation
* [x] Design Data Vault 2.0
* [x] Implement Hubs
* [x] Implement Links
* [x] Implement Satellites
* [x] Document the initial architecture

### Version 1.1 — Automated Ingestion

* [ ] Configure Snowflake stages
* [ ] Implement Snowpipe
* [ ] Automate file-based ingestion
* [ ] Test continuous ingestion
* [ ] Monitor ingestion history and errors
* [ ] Update ingestion documentation

### Future Versions

* [ ] Develop FastAPI REST API
* [ ] Implement Snowpipe Streaming
* [ ] Introduce event-driven transaction ingestion
* [ ] Implement Snowflake Streams
* [ ] Implement Dynamic Tables
* [ ] Expand real-time processing capabilities
* [ ] Develop Analytics Layer
* [ ] Configure CI/CD Pipeline
* [ ] Implement advanced data-quality monitoring
* [ ] Continue improving the synthetic banking simulator

---

## Repository Structure

```text
enterprise-banking-data-platform
│
├── .github/
├── api/
├── deployment/
├── docs/
├── simulator/
├── sql/
│   ├── raw/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   │   ├── hubs/
│   │   ├── links/
│   │   └── satellites/
│   └── analytics/
├── tests/
├── README.md
└── requirements.txt
```

> **Note:** The repository structure and implementation will evolve as new versions of the platform are introduced.

---

## Development Approach

The project is developed incrementally using **feature branches, versioned milestones, and Git-based change tracking**.

Each major version builds upon the previous version rather than replacing it.

The general development philosophy is:

```text
Generate
   ↓
Profile
   ↓
Transform
   ↓
Model
   ↓
Automate
   ↓
Stream
   ↓
Analyze
```

This allows the platform to gradually evolve from a synthetic batch-oriented banking data platform into a more automated and event-driven Data Engineering architecture.

---

## License

This project is intended for educational and portfolio purposes.
