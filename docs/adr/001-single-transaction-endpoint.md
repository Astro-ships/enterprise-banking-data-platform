# ADR-001: Use a Single Transaction Endpoint

## Status

Accepted

---

## Context

The Enterprise Banking Data Platform ingests banking transactions from a transaction simulator that represents events occurring within a banking system.

During the design phase, we considered whether the REST API should expose multiple endpoints for different transaction types (such as deposits, withdrawals, and transfers) or a single endpoint capable of accepting all transaction events.

The objective was to design an API that is scalable, easy to maintain, and representative of modern event-driven data platforms.

---

## Decision

The platform will expose a single REST endpoint:

```
POST /transactions
```

All transaction events will be submitted through this endpoint.

The type of transaction will be identified using the `transaction_type` attribute within the request payload.

Examples include:

* DEPOSIT
* WITHDRAWAL
* TRANSFER
* CARD_PAYMENT
* LOAN_PAYMENT

---

## Rationale

A banking transaction is fundamentally a business event.

Regardless of its type, every transaction shares a common set of core attributes, including:

* Transaction Identifier
* Timestamp
* Amount
* Currency
* Status

Using a single endpoint provides several advantages:

* Aligns with event-driven architecture principles.
* Simplifies API maintenance.
* Makes it easy to introduce new transaction types without changing the API contract.
* Produces a consistent event stream for downstream processing.
* Simplifies ingestion into Snowflake.

---

## Alternatives Considered

### Option 1 — Separate Endpoints

Examples:

```
POST /deposit
POST /withdrawal
POST /transfer
POST /card-payment
```

**Advantages**

* Simpler validation for each transaction type.
* Clear separation of business operations.

**Disadvantages**

* More endpoints to maintain.
* Requires API changes whenever new transaction types are introduced.
* Produces multiple event sources instead of a unified transaction stream.

---

### Option 2 — Single Transaction Endpoint (Selected)

Example:

```
POST /transactions
```

**Advantages**

* Single event contract.
* Easier to extend.
* Better suited for streaming architectures.
* Cleaner integration with downstream data pipelines.
* Consistent API design.

**Disadvantages**

* Validation logic is more complex because required fields vary depending on the transaction type.

---

## Consequences

The simulator will generate a single transaction event format.

The REST API will validate incoming events based on the value of `transaction_type`.

Downstream components, including Snowflake ingestion, the Medallion architecture, and the Data Vault model, will consume a unified transaction event stream.

This decision establishes the Transaction Event as the central business event for the platform.


                                                                                                                                                                                           
                                                                                                                                                                                            Decision Date: 2026-07-30
                                                                                                                                                                                            Project Phase: Sprint 1 - Architecture
                                                                                                                                                                                            Decision Owner: Muhammad Adnan