# Architecture

## 1. Overview

The **Enterprise Banking Data Platform** is a Snowflake-based data engineering platform designed to simulate the ingestion, processing, storage, historical modeling, monitoring, and analysis of banking transactions.

The platform combines:

* Initial batch processing for large-scale historical data.
* Near-real-time transaction ingestion using Snowpipe Streaming.
* Medallion Architecture for progressive data transformation.
* Data Vault 2.0 for enterprise historical modeling.
* Snowflake Streams and Tasks for incremental processing.
* Snowflake Alerts for suspicious transaction monitoring.
* Notification integration for operational events.

The architecture separates data ingestion, transformation, historical modeling, analytics, and operational monitoring into distinct components.

---

# 2. High-Level Architecture

The completed architecture is:

```text id="4w8k2m"
                 Synthetic Banking Generator
                           │
             ┌─────────────┴─────────────┐
             │                           │
        Initial Data                 Live Events
             │                           │
             ▼                           ▼
       Batch Loading             Snowpipe Streaming
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
                    DATA VAULT GOLD
                           │
                ┌──────────┴──────────┐
                ▼                     ▼
             Analytics          Snowflake Alert
                                      │
                              ┌───────┴────────┐
                              ▼                ▼
                         Alert Log       Notification
```

---

# 3. Major Components

## 3.1 Synthetic Banking Generator

The simulator represents upstream banking systems and generates synthetic banking data.

It is responsible for:

* Generating customers.
* Generating accounts.
* Generating merchants.
* Generating transactions.
* Performing the initial data generation.
* Continuously generating transaction events.
* Introducing configurable data-quality scenarios.
* Generating suspicious high-value transactions.

The simulator is intentionally separated from the data platform so that it can represent an external source system.

---

# 4. Initial Data Generation

The initial load establishes the historical foundation of the platform.

The generator currently produces approximately:

| Entity       | Approximate Volume |
| ------------ | -----------------: |
| Customers    |            100,000 |
| Accounts     |            100,000 |
| Merchants    |             10,000 |
| Transactions |          1,000,000 |

The initial processing flow is:

```text id="5v7m1p"
Initial Data Generator
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
 Data Vault GOLD
```

This workflow is optimized for establishing the initial historical dataset.

---

# 5. Continuous Transaction Generation

After the initial load, the simulator can continuously generate transaction events.

The continuous ingestion path is:

```text id="7r2n8q"
Transaction Generator
        │
        ▼
Transaction Event
        │
        ▼
Snowpipe Streaming SDK
        │
        ▼
       RAW
```

The current implementation uses the **Snowpipe Streaming SDK** rather than the previously planned REST/FastAPI ingestion path.

This allows transaction events to be written into Snowflake with low ingestion latency.

---

# 6. RAW Layer

The RAW layer is the landing area for incoming data.

Its primary purpose is to preserve the incoming source representation before downstream transformations are applied.

Characteristics include:

* Minimal transformation.
* Source-oriented representation.
* Preservation of incoming data.
* Support for traceability.
* Foundation for downstream processing.

Both initial batch data and continuously streamed transaction events enter the platform through the RAW layer.

```text id="f1q4z8"
Initial Load ─────────┐
                      ├──► RAW
Streaming Events ─────┘
```

---

# 7. BRONZE Layer

The BRONZE layer provides a structured representation of the raw data.

Typical responsibilities include:

* Technical transformations.
* Parsing source data.
* Standardizing technical representations.
* Structuring incoming records.
* Maintaining source business values.

The BRONZE layer prepares data for business-level processing in SILVER.

```text id="x8q3p5"
RAW
 │
 ▼
BRONZE
 │
 └── Structured Source Data
```

---

# 8. SILVER Layer

The SILVER layer is responsible for business-level transformation and data quality processing.

Responsibilities include:

* Data validation.
* Standardization.
* Business-rule enforcement.
* Duplicate handling.
* Preparation of trusted records.
* Preparing data for Data Vault loading.

The SILVER layer represents the trusted transformation layer of the platform.

```text id="d5j2v9"
BRONZE
   │
   ├── Validation
   ├── Standardization
   ├── Data Quality
   └── Business Rules
   │
   ▼
 SILVER
```

---

# 9. Data Vault GOLD Layer

The GOLD layer implements **Data Vault 2.0** as the enterprise historical data model.

The Data Vault consists of:

* Hubs.
* Links.
* Satellites.

The current core business entities are:

```text id="z6q4t8"
HUB_CUSTOMER
HUB_ACCOUNT
HUB_TRANSACTION
HUB_MERCHANT
```

The current transaction relationship includes:

```text id="h3m7w2"
LINK_ACCOUNT_TRANSACTION
```

Descriptive information is stored in corresponding Satellites.

The Data Vault provides:

* Stable business-key management.
* Relationship modeling.
* Historical preservation.
* Extensibility.
* Incremental loading.

---

# 10. Incremental Processing

The platform uses Snowflake Streams to identify newly available data.

Snowflake Tasks then process those changes through the transformation and Data Vault pipeline.

The transaction Data Vault processing sequence is:

```text id="u8k3m1"
SILVER Stream
     │
     ▼
HUB_TRANSACTION
     │
     ▼
LINK_ACCOUNT_TRANSACTION
     │
     ▼
SAT_TRANSACTION
```

The transaction loading tasks form a dependency graph so that dependent objects are processed in the appropriate order.

---

# 11. Task Dependency Architecture

The Data Vault transaction tasks follow:

```text id="c7v5x2"
GOLD_LOAD_HUB_TRANSACTION
             │
             │ AFTER
             ▼
     LINK_TRANSACTION_TASK
             │
             │ AFTER
             ▼
      SAT_TRANSACTION_TASK
```

The Hub acts as the root task.

The Link depends on the successful execution of the Hub task.

The Satellite depends on the Link task.

This provides a controlled incremental processing sequence.

---

# 12. Suspicious Transaction Monitoring

Suspicious transactions are **not routed through a completely separate ingestion pipeline**.

Instead, transactions follow the normal ingestion and transformation path.

After the transaction reaches the Data Vault, Snowflake Alert evaluates the transaction data.

```text id="8n2p5r"
Transaction
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
SAT_TRANSACTION
    │
    ▼
Snowflake Alert
```

The current suspicious transaction rule identifies transactions where:

```text id="x4m7q2"
AMOUNT >= 100000
```

Approximately 3% of generated transactions may intentionally contain high-value amounts to demonstrate this monitoring capability.

---

# 13. Alert and Notification Architecture

When the alert condition is met, the platform records the detected transaction in the suspicious transaction alert log.

The monitoring flow is:

```text id="m9c4t7"
SAT_TRANSACTION
       │
       ▼
Snowflake Alert
       │
       ├──────────────► SUSPICIOUS_TRANSACTION_ALERT_LOG
       │
       └──────────────► Notification
```

This demonstrates how operational monitoring can be integrated directly into the data platform.

---

# 14. Analytics Layer

The Data Vault provides the historical foundation for downstream analytics.

Analytical workloads can use the Data Vault to derive datasets such as:

* Transaction activity.
* Customer activity.
* Merchant activity.
* Transaction trends.
* High-value transaction analysis.
* Historical business analysis.

The conceptual flow is:

```text id="w6q2p8"
DATA VAULT GOLD
       │
       ▼
Analytics / Reporting
```

The Data Vault is therefore separated from analytical presentation models.

---

# 15. Batch and Streaming Architecture

The platform supports two ingestion modes.

## Initial Batch Processing

Used to establish the historical dataset.

```text id="f2n8q5"
Initial Generator
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
 Data Vault
```

## Continuous Streaming

Used for ongoing transaction events.

```text id="s5x3m7"
Transaction Generator
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
 Data Vault
```

Both paths converge into the same downstream data platform.

---

# 16. Why Suspicious Transactions Are Not a Separate Pipeline

The original architectural concept separated normal and suspicious transactions at ingestion.

The completed implementation instead treats suspicious transactions as a **business condition detected after ingestion**.

This provides a simpler architecture:

```text id="n4k8p2"
                  All Transactions
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
                  Data Vault GOLD
                         │
                         ▼
                  Snowflake Alert
                         │
                         ▼
                Suspicious Transactions
```

This avoids duplicating the ingestion and transformation pipeline.

It also demonstrates an important data-engineering principle: **operational monitoring can consume the same trusted data used by downstream analytical processes**.

---

# 17. Data Flow

The complete platform data flow is:

```text id="q7m3x9"
                    Synthetic Banking Generator
                              │
             ┌────────────────┴────────────────┐
             │                                 │
        Initial Dataset                   Transaction Events
             │                                 │
             ▼                                 ▼
      Batch Loading                    Snowpipe Streaming
             │                                 │
             └────────────────┬────────────────┘
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
                 ┌────────────┴────────────┐
                 ▼                         ▼
              Analytics              Snowflake Alert
                                           │
                                  ┌────────┴────────┐
                                  ▼                 ▼
                              Alert Log       Notification
```

---

# 18. Design Principles

The architecture follows the following principles.

### Event-Driven Data Generation

Banking transactions are represented as events generated continuously by the simulator.

### Batch + Streaming

The platform supports both large-scale initial loading and continuous event ingestion.

### Immutable Business Events

Transaction events are treated as immutable business events after ingestion.

### Layered Processing

RAW, BRONZE, SILVER, and GOLD have distinct responsibilities.

### Separation of Concerns

Data ingestion, transformation, historical modeling, analytics, and monitoring are separated into distinct stages.

### Historical Preservation

Data Vault Satellites preserve descriptive history rather than continuously overwriting historical records.

### Incremental Processing

Streams and Tasks process new data incrementally.

### Configuration-Driven Simulation

Simulator behavior is controlled through configuration rather than hard-coded operational parameters.

### Extensibility

New banking entities, relationships, event types, and downstream processes can be added without fundamentally redesigning the platform.

---

# 19. Security Considerations

The architecture incorporates basic secure-development practices.

Sensitive authentication information is externalized from application code.

The streaming implementation uses RSA key-pair authentication for Snowflake connectivity.

Private keys and environment files containing credentials must not be committed to source control.

```text id="c8p5v1"
Application
    │
    ├── Environment Configuration
    └── RSA Private Key
              │
              ▼
        Snowflake Authentication
```

---

# 20. Future Enhancements

The architecture can be extended with additional capabilities such as:

* Kafka-based event ingestion.
* Apache Flink-style stream processing.
* Additional banking products.
* Multiple upstream source systems.
* Event replay.
* Streaming analytics.
* Advanced fraud detection.
* Machine-learning-based anomaly detection.
* Additional Data Vault Hubs, Links, and Satellites.
* Business-ready analytical marts.

These enhancements can be introduced without fundamentally changing the core Medallion and Data Vault architecture.

---

# 21. Final Architecture

The completed architecture can be summarized as:

```text id="r8q4m6"
                         ┌────────────────────────┐
                         │ Synthetic Banking      │
                         │ Generator              │
                         └───────────┬────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
                    ▼                                 ▼
             Initial Dataset                    Live Transactions
                    │                                 │
                    ▼                                 ▼
             Batch Loading                    Snowpipe Streaming
                    │                                 │
                    └────────────────┬────────────────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │     RAW     │
                              └──────┬──────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │   BRONZE    │
                              └──────┬──────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │   SILVER    │
                              └──────┬──────┘
                                     │
                                     ▼
                         ┌──────────────────────┐
                         │   DATA VAULT GOLD    │
                         │                      │
                         │ Hubs / Links /       │
                         │ Satellites           │
                         └──────────┬───────────┘
                                    │
                       ┌────────────┴────────────┐
                       │                         │
                       ▼                         ▼
                Analytics &              Snowflake Alert
                  Reporting                     │
                                                │
                                      ┌─────────┴─────────┐
                                      ▼                   ▼
                                  Alert Log          Notification
```

---

# 22. Architecture Summary

The Enterprise Banking Data Platform combines **batch and streaming ingestion within a single Snowflake-based architecture**.

The initial dataset establishes the historical foundation, while Snowpipe Streaming continuously introduces new transaction events.

All data follows the Medallion Architecture:

```text
RAW → BRONZE → SILVER → GOLD
```

The GOLD layer implements Data Vault 2.0, while Snowflake Streams and Tasks provide incremental processing.

Suspicious transactions are detected from the trusted transaction data using Snowflake Alerts rather than being routed through a separate ingestion pipeline.

The resulting architecture demonstrates an end-to-end modern data platform incorporating **synthetic data generation, batch ingestion, streaming ingestion, data quality, Data Vault 2.0, incremental processing, analytics, operational alerting, notifications, and CI/CD**.
