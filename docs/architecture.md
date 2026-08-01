# Architecture

## 1. Overview

The Enterprise Banking Data Platform is an event-driven data platform designed to simulate the ingestion, processing, storage, and analysis of banking transactions.

The architecture combines batch processing for analytical workloads with near real-time processing for suspicious transactions.

The platform is built using a layered Medallion Architecture with Data Vault 2.0 implemented in the Gold layer.

---

# 2. High-Level Architecture

Banking Simulator

↓

REST API

↓

Snowflake RAW Layer

↓

Bronze Layer

↓

Silver Layer

↓

Gold (Data Vault 2.0)

↓

Analytics & Reporting

---

# 3. Components

## Banking Simulator

Responsible for generating realistic banking events.

Responsibilities:

* Generate customers.
* Generate accounts.
* Generate merchants.
* Generate transactions.
* Simulate realistic banking activity.
* Introduce configurable data quality issues.

---

## REST API

Acts as the ingestion layer.

Responsibilities:

* Receive transaction events.
* Validate the event contract.
* Accept banking events from the simulator.
* Forward events to Snowflake.

---

## RAW Layer

Stores events exactly as they were received.

Characteristics:

* Immutable.
* No transformations.
* Original event preserved.
* Supports auditing and replay.

---

## Bronze Layer

Applies technical transformations.

Responsibilities:

* Standardize column names.
* Parse incoming data.
* Preserve original business values.

---

## Silver Layer

Applies business transformations.

Responsibilities:

* Standardize business values.
* Remove duplicate events.
* Validate transaction types.
* Clean invalid data.
* Apply business rules.

---

## Gold Layer

Implements the enterprise data model using Data Vault 2.0.

Components:

* Hubs
* Links
* Satellites

The Gold layer preserves historical business information while supporting enterprise-scale integration.

---

## Analytics Layer

Provides business-ready datasets and reports.

Example analytics include:

* Daily transaction volume.
* Customer activity.
* Merchant performance.
* Transaction trends.
* Fraud monitoring.

---

# 4. Processing Strategy

The platform uses a hybrid processing architecture.

Normal transactions follow the standard analytical pipeline.

Suspicious transactions are identified separately and processed with lower latency to support operational monitoring and alerting.

---

# 5. Design Principles

The platform follows these architectural principles:

* Event-driven ingestion.
* Immutable business events.
* Separation of storage and business logic.
* Historical data preservation.
* Modular system components.
* Scalable and extensible design.
* Configuration-driven simulator behavior.

---

# 6. Future Enhancements

The architecture is intentionally extensible.

Future capabilities may include:

* Additional banking products.
* Multiple event producers.
* Advanced fraud detection.
* Event replay.
* Multiple source systems.
* Streaming analytics.

# 7. Proposed architecture

                    Banking Simulator
                           │
                    Transaction Events
                           │
                    FastAPI REST API
                           │
                  Event Validation Layer
                           │
          ┌────────────────┴────────────────┐
          │                                 │
          ▼                                 ▼
Normal Transactions              Suspicious Transactions
          │                                 │
     Batch Pipeline              Near Real-Time Pipeline
          │                                 │
          ▼                                 ▼
RAW → Bronze → Silver → Gold       Alerts & Notifications
          │
          ▼
     Analytics & Reporting