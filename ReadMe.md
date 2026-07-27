# Enterprise Banking Data Platform with Data Vault 2.0

## Overview

Enterprise Banking Data Platform is a modern Data Engineering project that simulates a real-world banking system using event-driven architecture. The platform ingests banking transactions through REST APIs, streams data into Snowflake, applies the Medallion Architecture, and models enterprise data using Data Vault 2.0.

This project is designed to demonstrate industry-standard Data Engineering practices, including real-time ingestion, scalable data modeling, automation, and analytics.

---

## Objectives

* Simulate banking transactions using Python and Faker
* Ingest real-time events through REST APIs
* Stream data into Snowflake using Snowpipe Streaming
* Implement the Medallion Architecture (Raw → Bronze → Silver → Gold)
* Model enterprise data using Data Vault 2.0
* Build automated deployment with GitHub Actions
* Produce real-time analytical views

---

## Planned Architecture

```text
Banking Transaction Simulator
        │
        ▼
    FastAPI REST API
        │
        ▼
 Snowpipe Streaming
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
 Data Vault 2.0 (Gold)
        │
        ▼
 Business Analytics
```

---

## Technology Stack

* Python
* Faker
* FastAPI
* Snowflake
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

🚧 Currently under development.

The project is being built incrementally using feature branches and milestone-based releases.

---

## Repository Structure

```
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

---

## Roadmap

* [ ] Build Banking Transaction Simulator
* [ ] Develop REST API
* [ ] Configure Snowpipe Streaming
* [ ] Implement Bronze Layer
* [ ] Implement Silver Layer
* [ ] Design Data Vault 2.0
* [ ] Develop Analytics Layer
* [ ] Configure CI/CD Pipeline
* [ ] Complete Project Documentation

---

## License

This project is intended for educational and portfolio purposes.
