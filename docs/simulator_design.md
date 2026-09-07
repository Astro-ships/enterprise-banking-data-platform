# Banking Simulator Design

## Purpose

The **Banking Simulator** is the upstream data-generation and event-simulation component of the **Enterprise Banking Data Platform**.

It creates a synthetic banking environment containing customers, accounts, merchants, and transactions and continuously produces realistic banking transaction events.

Unlike a simple fake-data generator, the simulator maintains relationships between banking entities and applies business rules when generating transactions.

The simulator supports two primary workloads:

1. **Initial Data Generation** — creates the historical foundation of the banking platform.
2. **Continuous Transaction Streaming** — continuously generates new transaction events for Snowpipe Streaming ingestion.

---

# Design Goals

The simulator is designed to:

* Generate realistic synthetic banking entities.
* Maintain relationships between customers, accounts, merchants, and transactions.
* Generate consistent transaction events.
* Introduce controlled data-quality issues.
* Generate suspicious/high-value transactions for alert testing.
* Support configurable simulation parameters.
* Support large-scale initial dataset generation.
* Continuously generate transaction events.
* Integrate with Snowpipe Streaming.
* Produce data suitable for Medallion Architecture.
* Provide realistic source data for Data Vault 2.0 processing.
* Keep data-generation logic separate from business behavior and ingestion logic.

---

# Simulator Architecture

The simulator is divided into several logical components:

```text
                    BANKING SIMULATOR
                           │
             ┌─────────────┴─────────────┐
             │                           │
             ▼                           ▼
      INITIAL GENERATION           EVENT STREAMING
             │                           │
             ▼                           ▼
       Customers                   Transaction
       Accounts                     Generator
       Merchants                        │
       Transactions                     ▼
             │                    Quality Rules
             │                           │
             │                           ▼
             │                    Streaming Writer
             │                           │
             │                           ▼
             │                    Snowpipe Streaming
             │                           │
             └──────────────┬────────────┘
                            ▼
                       Snowflake RAW
```

The initial generation process establishes the historical banking environment.

The streaming process then operates on that environment and continuously generates new transaction events.

---

# Simulator Lifecycle

The simulator operates in two distinct phases.

## Phase 1 — Initial Data Generation

The initial generation phase creates the foundational banking dataset.

The simulator generates:

* Customers
* Accounts
* Merchants
* Historical transactions

The current project configuration generates approximately:

* **100,000 customers**
* **100,000 accounts**
* **10,000 merchants**
* **1,000,000 transactions**

These records provide the initial population of the banking platform.

The initial data is subsequently loaded into Snowflake and processed through:

```text
RAW
 ↓
BRONZE
 ↓
SILVER
 ↓
DATA VAULT 2.0
```

The initial generation phase is therefore responsible for establishing the historical state of the simulated banking environment.

---

# Phase 2 — Continuous Event Generation

After the initial environment has been established, the simulator can operate in streaming mode.

The transaction generator continuously creates new banking transactions using the existing customers, accounts, and merchants.

Example transaction types include:

* Purchases
* Transfers
* ATM withdrawals
* Deposits
* Other configured banking activities

Each generated transaction represents an immutable business event.

The streaming flow is:

```text
Existing Banking State
        │
        ▼
Transaction Generator
        │
        ▼
Business Rules
        │
        ▼
Data Quality Rules
        │
        ▼
Streaming Writer
        │
        ▼
Snowpipe Streaming
        │
        ▼
Snowflake RAW
```

---

# Project Structure

```text
event_generator/
│
├── initial_data_generation/
│   └── run.py
│
├── run.py
├── controller.py
├── state.py
├── config.py
├── config.yaml
│
├── models/
│   ├── customer.py
│   ├── account.py
│   ├── merchant.py
│   └── transaction.py
│
├── generators/
│   ├── customer_generator.py
│   ├── account_generator.py
│   ├── merchant_generator.py
│   └── transaction_generator.py
│
├── quality/
│   └── ...
│
├── services/
│   ├── customer_service.py
│   ├── account_service.py
│   ├── merchant_service.py
│   └── transaction_service.py
│
├── streaming/
│   └── ...
│
├── writers/
│   └── ...
│
└── utils.py
```

---

# Component Responsibilities

## `initial_data_generation/`

Responsible for generating the initial historical banking dataset.

The initial generator creates the large foundational dataset used by the first-stage Snowflake load.

It is intentionally separated from the continuous streaming simulator because initial data generation and real-time event generation have different requirements.

The initial generator can be started with:

```bash
python -m event_generator.initial_data_generation.run
```

---

# `run.py`

The main entry point for the continuous simulator.

Responsibilities include:

* Loading simulator configuration.
* Initializing simulator components.
* Starting the simulation.
* Coordinating continuous transaction generation.
* Handling simulator shutdown.

---

# `controller.py`

The controller coordinates the simulator lifecycle.

Responsibilities include:

* Starting the simulator.
* Pausing the simulator.
* Resuming the simulator.
* Stopping the simulator.
* Reporting simulator status.
* Coordinating simulator components.

The controller separates simulator lifecycle management from individual generators and services.

---

# `state.py`

Maintains the current state of the simulated banking environment.

The simulator state contains information such as:

* Customers
* Accounts
* Merchants
* Account balances
* Banking relationships
* Recent transaction information

The shared state allows generated transactions to represent activity occurring within an existing banking environment rather than being independent random records.

For example, a transfer can use an existing source account and an existing destination account rather than generating unrelated account identifiers.

---

# `config.py`

Responsible for loading the simulator configuration.

Configuration values are loaded from:

```text
config.yaml
```

The configuration layer provides a centralized interface for accessing simulation parameters.

This prevents configuration values from being hard-coded throughout the application.

---

# `config.yaml`

Contains configurable simulator parameters.

Examples include:

* Initial customer count
* Initial account count
* Initial merchant count
* Transaction generation parameters
* Transaction rates
* Suspicious transaction probability
* Transaction amount ranges
* Other simulator settings

No application or business logic is implemented inside the configuration file.

---

# Models

Models represent the core banking entities.

The primary models are:

```text
Customer
Account
Merchant
Transaction
```

Each model defines the structure and attributes of its corresponding business entity.

Models are intentionally kept separate from:

* Data generation
* Business services
* Streaming
* Data-quality logic

This allows the underlying business entities to evolve independently from the mechanisms that create and process them.

---

# Customer Model

The Customer model represents a banking customer.

Typical attributes include:

* Customer ID
* First name
* Last name
* Date of birth
* Country
* City

Customers form the foundation of the simulated banking environment.

---

# Account Model

The Account model represents a customer's banking account.

Accounts maintain relationships with customers and contain account-specific information such as:

* Account ID
* Customer relationship
* Account type
* Balance
* Other account attributes

The simulator uses these relationships when generating transactions.

---

# Merchant Model

The Merchant model represents a merchant participating in banking transactions.

Merchants provide transaction participants for activities such as purchases.

---

# Transaction Model

The Transaction model represents an immutable banking business event.

A transaction contains information such as:

* Transaction ID
* Source account
* Destination account
* Merchant
* Transaction amount
* Currency
* Transaction type
* Timestamp
* Status

Transactions are generated using the existing simulated banking entities.

---

# Generators

Generators are responsible for creating synthetic banking objects and events.

The major generators include:

```text
Customer Generator
Account Generator
Merchant Generator
Transaction Generator
```

Each generator has a focused responsibility.

For example:

```text
Customer Generator
        │
        ▼
    Customers

Account Generator
        │
        ▼
     Accounts

Merchant Generator
        │
        ▼
    Merchants

Transaction Generator
        │
        ▼
   Transactions
```

---

# Transaction Generation

The transaction generator is responsible for producing realistic transaction events.

The generator selects appropriate participants from the simulated banking state and generates transaction attributes according to configured business rules.

For example:

```text
Transaction
     │
     ├── Source Account
     ├── Destination Account
     ├── Merchant
     ├── Transaction Type
     ├── Amount
     ├── Currency
     ├── Timestamp
     └── Status
```

The generator therefore produces transactions that are connected to the simulated banking environment.

---

# Transaction Amount Generation

Transaction amounts are generated according to transaction type.

Normal transaction amounts use probability distributions designed to produce positive and right-skewed financial values.

The simulator also deliberately generates suspicious high-value transactions.

Currently, approximately **3% of generated transactions** can be high-value transactions used to exercise the platform's anomaly-detection and Snowflake Alert functionality.

The suspicious transaction range is approximately:

```text
100,000 – 200,000
```

This allows the downstream Snowflake alert to detect transactions meeting the configured high-value threshold.

---

# Services

Services contain the business behavior used by the simulator.

Examples include:

* Selecting eligible accounts.
* Selecting transaction participants.
* Validating transaction rules.
* Updating account balances.
* Determining transaction participants.
* Applying transaction business logic.
* Coordinating entity relationships.

Services operate on the models and simulator state rather than directly implementing data-generation mechanics.

---

# Data Quality

Data quality is treated as a deliberate part of the simulation rather than something assumed to be perfect at the source.

The simulator can introduce controlled source-data imperfections for downstream testing.

Examples include:

* Missing values
* Duplicate records
* Inconsistent values
* Invalid or inconsistent relationships
* Other configurable source-data variations

This allows the downstream platform to demonstrate:

```text
Generate Imperfect Data
          ↓
       Profile
          ↓
       Validate
          ↓
       Transform
          ↓
       Standardize
```

The purpose is to simulate the type of imperfect source data that a real Data Engineering platform may receive.

---

# Streaming

The streaming components are responsible for delivering newly generated transaction events to Snowflake.

The streaming architecture separates:

```text
Event Generation
        │
        ▼
Data Quality
        │
        ▼
Serialization / Writing
        │
        ▼
Snowpipe Streaming
```

This separation allows the transaction generator to remain independent from the specific ingestion technology.

---

# Streaming Writer

The writer layer is responsible for preparing generated transactions for ingestion.

Its responsibility is to bridge the simulator's transaction objects and the configured streaming mechanism.

This keeps Snowpipe Streaming-specific implementation details outside of the transaction-generation logic.

---

# Snowpipe Streaming Integration

The completed project uses the **Snowpipe Streaming SDK** for continuous transaction ingestion.

The high-level flow is:

```text
Transaction Generator
        │
        ▼
Transaction Event
        │
        ▼
Streaming Writer
        │
        ▼
Snowpipe Streaming SDK
        │
        ▼
Snowflake RAW
```

This allows newly generated transactions to enter the banking data platform continuously.

The downstream Snowflake processing then handles the new data through the Bronze, Silver, and Data Vault layers.

---

# Simulator → Data Platform Integration

The complete relationship between the simulator and the Data Platform is:

```text
                    SIMULATOR
                        │
          ┌─────────────┴─────────────┐
          │                           │
          ▼                           ▼
    Initial Dataset             Live Events
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
                        ▼
                    ANALYTICS
```

The simulator is therefore completely separated from the downstream transformation and modeling layers.

Its responsibility ends at producing valid source events for ingestion.

---

# Simulator Data Flow

The simulator's internal flow can be summarized as:

```text
Configuration
     │
     ▼
Simulator State
     │
     ├──────────────┐
     ▼              ▼
Entity Generators   Existing Entities
     │              │
     └──────┬───────┘
            ▼
   Transaction Generator
            │
            ▼
      Business Rules
            │
            ▼
       Data Quality
            │
            ▼
      Streaming Writer
            │
            ▼
    Snowpipe Streaming
```

---

# Initial Load vs Streaming

The simulator deliberately separates historical dataset generation from real-time event generation.

### Initial Load

Used to establish the initial banking environment.

```text
Generate
100K Customers
100K Accounts
10K Merchants
1M Transactions
```

### Streaming

Used to continuously generate new transactions after the initial environment has been established.

```text
Existing State
      │
      ▼
Generate Transaction
      │
      ▼
Apply Business Rules
      │
      ▼
Write Event
      │
      ▼
Snowpipe Streaming
```

This separation allows the project to demonstrate both batch and streaming Data Engineering architectures.

---

# Guiding Principles

The simulator follows the following design principles.

## Separation of Responsibilities

Each component has a focused responsibility.

```text
Models       → Entity Structure
Generators   → Data Creation
Services     → Business Behavior
Quality      → Data Quality
State        → Simulation State
Streaming    → Event Delivery
Writers      → Ingestion Interface
Controller   → Lifecycle Management
Config       → Configuration
```

---

## Configurable Behavior

Simulation behavior should be controlled through configuration rather than hard-coded values.

This allows different simulation scenarios to be tested without changing application logic.

---

## Realistic Relationships

Generated transactions should reference entities that exist within the simulated banking environment.

The simulator therefore models relationships between:

```text
Customer
   │
   ▼
Account
   │
   ▼
Transaction
   ▲
   │
Merchant
```

---

## Immutable Events

Once generated, a transaction represents a business event.

The simulator does not treat historical transaction events as mutable objects.

Changes to the banking environment are represented through subsequent events rather than modifying historical transactions.

---

## Controlled Imperfection

The source data is intentionally not perfect.

Controlled imperfections allow the downstream Data Platform to demonstrate real Data Engineering processes such as:

* Validation
* Cleansing
* Standardization
* Deduplication
* Null handling
* Referential-integrity checks

---

## Extensibility

The architecture is designed so that additional:

* Entity types
* Transaction types
* Business rules
* Data-quality scenarios
* Streaming destinations
* Generation strategies

can be added without requiring a complete redesign of the simulator.

---

# Complete Simulator Lifecycle

The final simulator lifecycle is:

```text
              CONFIGURATION
                    │
                    ▼
          INITIALIZE BANKING STATE
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
    Customers                Accounts
        │                       │
        └───────────┬───────────┘
                    │
                    ▼
                Merchants
                    │
                    ▼
          Initial Transactions
                    │
                    ▼
             INITIAL LOAD
                    │
                    ▼
              SNOWFLAKE
                    │
                    │
          ┌─────────┴─────────┐
          │                   │
          │   STREAMING MODE  │
          │                   │
          ▼                   │
    Transaction Event         │
          │                   │
          ▼                   │
     Business Rules           │
          │                   │
          ▼                   │
      Data Quality            │
          │                   │
          ▼                   │
     Streaming Writer         │
          │                   │
          ▼                   │
   Snowpipe Streaming         │
          │                   │
          ▼                   │
       Snowflake              │
          │                   │
          └───────────────────┘
```

The simulator therefore acts as a controlled synthetic banking source system capable of supporting both **large-scale initial data generation** and **continuous transaction-event generation** for the Enterprise Banking Data Platform.
