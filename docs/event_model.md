# Event Model

## 1. Purpose

This document defines the business events processed by the Enterprise Banking Data Platform.

The event model acts as the contract between the transaction simulator, the REST API, and the downstream data platform.

Every component within the platform is designed around the Transaction Event.

---

# 2. Primary Business Event

## TransactionOccurred

### Description

A TransactionOccurred event represents a financial transaction that has taken place within the banking system.

Each event is immutable and represents a single business occurrence.

Examples include:

* Deposit
* Withdrawal
* Transfer
* Card Payment
* Loan Payment

---

# 3. Event Contract

Every transaction event shall contain the following information.

| Field                  | Required    | Description                            |
| ---------------------- | ----------- | -------------------------------------- |
| transaction_id         | Yes         | Unique identifier of the transaction   |
| transaction_type       | Yes         | Business transaction type              |
| amount                 | Yes         | Monetary amount                        |
| currency               | Yes         | Currency provided by the source system |
| status                 | Yes         | Current transaction status             |
| channel                | Yes         | Originating banking channel            |
| transaction_timestamp  | Yes         | Time the transaction occurred          |
| source_account_id      | Conditional | Account sending money                  |
| destination_account_id | Conditional | Account receiving money                |
| merchant_id            | Conditional | Merchant receiving payment             |

---

# 4. Supported Transaction Types

The platform supports the following transaction types.

| Transaction Type | Description                        |
| ---------------- | ---------------------------------- |
| DEPOSIT          | Funds deposited into an account    |
| WITHDRAWAL       | Funds withdrawn from an account    |
| TRANSFER         | Funds transferred between accounts |


---

# 5. Transaction Status

A transaction may exist in one of the following states.

| Status    | Description                        |
| --------- | ---------------------------------- |
| PENDING   | Transaction has been initiated     |
| COMPLETED | Transaction completed successfully |
| FAILED    | Transaction failed                 |
| REVERSED  | Transaction has been reversed      |

---

# 6. Banking Channels

Transactions may originate from multiple banking channels.

| Channel        | Description                |
| -------------- | -------------------------- |
| ATM            | Automated Teller Machine   |
| MOBILE_APP     | Mobile banking application |
| ONLINE_BANKING | Internet banking           |
| BRANCH         | Physical bank branch       |
| POS            | Point-of-Sale terminal     |

---

# 7. Event Lifecycle

The lifecycle of a transaction event is:

Business Transaction

↓

Transaction Event Created

↓

REST API

↓

RAW Layer

↓

Bronze Layer

↓

Silver Layer

↓

Data Vault 2.0

↓

Analytics

---

# 8. Design Principles

The event model follows these principles:

* Every event represents a single business occurrence.
* Events are immutable and are never updated.
* The event model is technology-independent.
* The event contract is shared by all platform components.
* Additional transaction types can be introduced without changing the API endpoint.



                    Event Model
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
    Simulator        REST API      Snowflake RAW
        │               │               │
        └───────────────┼───────────────┘
                        │
                        ▼
                   Silver Layer
                        │
                        ▼
                 Data Vault 2.0
                        │
                        ▼
                    Analytics