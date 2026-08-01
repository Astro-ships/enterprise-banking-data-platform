# Banking Simulator Design

## Purpose

The Banking Simulator is responsible for creating and maintaining a realistic banking environment that continuously generates banking transaction events.

Unlike a simple fake data generator, the simulator maintains relationships between customers, accounts, merchants, and transactions so that generated events accurately represent business activity.

The simulator serves as the upstream banking system for the Enterprise Banking Data Platform.

---

# Design Goals

The simulator is designed to:

* Generate realistic banking entities.
* Maintain relationships between entities.
* Produce consistent business events.
* Support configurable simulation parameters.
* Generate both batch and near real-time events.
* Produce data suitable for Medallion Architecture and Data Vault 2.0.

---

# Simulator Lifecycle

The simulator operates in two distinct phases.

## Phase 1 — Initialization

During initialization the simulator creates the banking world.

This includes:

* Customers
* Accounts
* Merchants

These entities remain in memory throughout the simulation.

No transaction events are generated during this phase.

---

## Phase 2 — Event Generation

After initialization, the simulator continuously generates transaction events using the previously created banking entities.

Examples include:

* Deposits
* Withdrawals
* Transfers
* Card Payments
* Loan Payments

Each transaction is treated as an immutable business event.

---

# Project Structure

```text
simulator/      
│
├── run.py                         ⭐ Entry point of the simulator.
├── controller.py                  ⭐ Coordinates the simulator lifecycle.
├── state.py                       ⭐ Maintains the current state of the simulated banking system.
├── config.py                      ⭐ Loads and validates configuration values from `config.yaml`.
├── config.yaml                    ⭐ Stores configurable simulation settings 
│
├── models/                        * Models represent business entities.
│   ├── customer.py                
│   ├── account.py
│   ├── merchant.py
│   └── transaction.py
│
├── generators/                    * Generators are responsible for creating business entities and transaction events.
│   ├── customer_generator.py
│   ├── account_generator.py
│   ├── merchant_generator.py
│   └── transaction_generator.py
│
├── services/                      * Services implement the business behavior required during transaction simulation.
│   ├── customer_service.py
│   ├── account_service.py
│   ├── merchant_service.py
│   └── transaction_service.py
│
└── utils.py                        * Utility functions provide reusable helper functionality such as:
```

---

# Component Responsibilities

## run.py

Entry point of the simulator.

Responsibilities:

* Load configuration.
* Initialize simulator components.
* Start the simulation.
* Handle graceful shutdown.

---

## controller.py

Coordinates the simulator lifecycle.

Responsibilities:

* Initialize the banking environment.
* Start the simulator.
* Pause the simulator.
* Resume the simulator.
* Stop the simulator.
* Report simulator status.

---

## state.py

Maintains the current state of the simulated banking system.

Stores:

* Customers
* Accounts
* Merchants
* Current account balances (simulation state)
* Recent transaction history

The simulator relies on this shared state to generate consistent business events.

---

## config.py

Loads and validates configuration values from `config.yaml`.

Provides a single configuration interface for the simulator.

---

## config.yaml

such as:

* Initial customer count
* Initial merchant count
* Maximum accounts per customer
* Transactions per second
* Fraud simulation parameters

No application logic exists within this file.

---

# Models

Models represent business entities.

Each model defines the structure of a single business object.

Examples include:

* Customer
* Account
* Merchant
* Transaction

Models do not generate data or implement business workflows.

---

# Generators

Generators are responsible for creating business entities and transaction events.

Each generator focuses on one entity type.

Examples:

* Customer Generator
* Account Generator
* Merchant Generator
* Transaction Generator

---

# Services

Services implement the business behavior required during transaction simulation.

Examples include:

* Selecting eligible accounts for a transaction.
* Validating simulated transaction rules.
* Updating simulated account balances.
* Determining transaction participants.
* Classifying suspicious transactions.

---

# Utilities

Utility functions provide reusable helper functionality such as:

* Identifier generation.
* Random weighted selection.
* Date and time utilities.
* Common formatting functions.

Utilities should remain generic and independent of business logic.

---

# Guiding Principles

The simulator follows these principles:

* Separation of responsibilities.
* Configurable behavior.
* Realistic business relationships.
* Immutable transaction events.
* Extensible architecture.
* Reproducible simulations.
