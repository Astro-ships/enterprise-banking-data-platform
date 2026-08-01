# Business Requirements

## 1. Project Overview

### Project Name

Enterprise Banking Data Platform with Data Vault 2.0

### Overview

The Enterprise Banking Data Platform is a modern data engineering project that simulates how a financial institution ingests, processes, stores, and analyzes banking transactions.

The platform is designed using an event-driven architecture where every banking transaction is treated as a business event. These events are ingested through a REST API and processed using a hybrid architecture that combines batch processing for analytical workloads with near real-time processing for suspicious transactions.

The project demonstrates modern data engineering concepts including Data Vault 2.0, Snowflake, event-driven ingestion, REST APIs, CI/CD, and analytical reporting.

---

## 2. Business Problem

Banks process millions of financial transactions every day from multiple channels including mobile banking, ATMs, online banking, point-of-sale terminals, and physical branches.

Traditional reporting systems are often designed for scheduled analytical workloads and are not always suitable for responding quickly to suspicious activities such as potential fraud.

The organization requires a scalable platform capable of:

* Ingesting banking transaction events.
* Preserving complete historical records.
* Supporting analytical reporting.
* Identifying suspicious transactions for near real-time processing.
* Providing a reliable foundation for future business intelligence solutions.

---

## 3. Business Objectives

The platform shall:

* Ingest transaction events through a REST API.
* Simulate realistic banking activity using a transaction simulator.
* Store historical data without losing business history.
* Implement Data Vault 2.0 as the enterprise data model.
* Support hybrid processing using both batch and near real-time workflows.
* Produce analytical datasets for business reporting.
* Demonstrate enterprise-grade CI/CD deployment practices.

---

## 4. Project Scope

### In Scope

* Banking transaction simulation.
* REST API ingestion.
* Snowflake data platform.
* RAW, Bronze, Silver, and Gold layers.
* Data Vault 2.0 implementation.
* Batch processing.
* Near real-time processing for suspicious transactions.
* Data quality validation.
* Alerts and notifications.
* Analytics and reporting.
* GitHub Actions CI/CD.

### Out of Scope

* Customer authentication.
* Online banking user interface.
* Core banking operations.
* Payment authorization.
* Account balance calculations.
* Machine learning fraud detection.

---

## 5. Primary Business Event

The primary business event for this platform is:

**Transaction Occurred**

A transaction event represents a completed or attempted financial operation performed within the banking system, including deposits, withdrawals, transfers, card payments, and loan payments.

---

## 6. Success Criteria

The project will be considered successful when it can:

* Generate realistic banking transactions.
* Ingest transaction events successfully.
* Preserve historical business data.
* Process normal transactions in batch.
* Process suspicious transactions with low latency.
* Produce business-ready analytical outputs.
* Demonstrate an end-to-end automated deployment pipeline.

---

## 7. Assumptions

* The banking simulator represents upstream banking systems.
* Every transaction is treated as an immutable business event.
* Historical business data must never be overwritten.
* The platform is designed for learning enterprise data engineering concepts rather than implementing a complete banking system.
