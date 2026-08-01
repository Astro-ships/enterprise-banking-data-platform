# Data Dictionary

## Purpose

This document defines every business attribute used by the Enterprise Banking Data Platform.

It provides a consistent definition of each field, its data type, whether it is required, and its business meaning.

---

# Transaction Event

| Field                  | Data Type     | Required    | Description                                                                                      |
| ---------------------- | ------------- | ----------- | ------------------------------------------------------------------------------------------------ |
| transaction_id         | VARCHAR       | Yes         | Unique business identifier for the transaction event.                                            |
| transaction_type       | VARCHAR       | Yes         | Type of financial transaction (DEPOSIT, WITHDRAWAL, TRANSFER, CARD_PAYMENT, LOAN_PAYMENT).       |
| source_account_id      | VARCHAR       | Conditional | Account initiating the transaction. Required for withdrawals, transfers, and card payments.      |
| destination_account_id | VARCHAR       | Conditional | Account receiving funds. Required for deposits and transfers.                                    |
| merchant_id            | VARCHAR       | Conditional | Merchant associated with a card payment.                                                         |
| amount                 | DECIMAL(18,2) | Yes         | Monetary value of the transaction.                                                               |
| currency               | VARCHAR       | Yes         | Currency received from the source system. Values may be standardized in the Silver layer.        |
| status                 | VARCHAR       | Yes         | Current transaction status (PENDING, COMPLETED, FAILED, REVERSED).                               |
| channel                | VARCHAR       | Yes         | Banking channel where the transaction originated (ATM, MOBILE_APP, ONLINE_BANKING, BRANCH, POS). |
| transaction_timestamp  | TIMESTAMP     | Yes         | Date and time when the business event occurred.                                                  |

---

# Customer

| Field         | Data Type | Description                                |
| ------------- | --------- | ------------------------------------------ |
| customer_id   | VARCHAR   | Unique business identifier for a customer. |
| customer_name | VARCHAR   | Full name of the customer.                 |
| email         | VARCHAR   | Customer email address.                    |
| phone         | VARCHAR   | Customer phone number.                     |
| address       | VARCHAR   | Customer mailing address.                  |
| date_of_birth | DATE      | Customer date of birth.                    |

---

# Account

| Field            | Data Type | Description                                       |
| ---------------- | --------- | ------------------------------------------------- |
| account_id       | VARCHAR   | Unique account identifier.                        |
| account_type     | VARCHAR   | Type of account (Checking, Savings, Business).    |
| account_status   | VARCHAR   | Current account status (ACTIVE, DORMANT, CLOSED). |
| account_currency | VARCHAR   | Primary currency of the account.                  |
| opened_date      | DATE      | Date the account was opened.                      |

---

# Merchant

| Field             | Data Type | Description                                                           |
| ----------------- | --------- | --------------------------------------------------------------------- |
| merchant_id       | VARCHAR   | Unique business identifier for a merchant.                            |
| merchant_name     | VARCHAR   | Registered merchant name.                                             |
| merchant_category | VARCHAR   | Merchant business category (Retail, Grocery, Fuel, Restaurant, etc.). |
| city              | VARCHAR   | Merchant city.                                                        |
| country           | VARCHAR   | Merchant country.                                                     |

---

# Business Rules

* Every transaction must have a unique `transaction_id`.
* Every account belongs to at least one customer.
* Transaction events are immutable and are never updated.
* Business relationships are modeled using Data Vault Links.
* Data quality improvements occur in the Silver layer.
* Historical business information is preserved within Data Vault Satellites.

---

# Data Quality Expectations

The simulator may intentionally generate:

* Duplicate transaction events.
* Invalid transaction types.
* Missing optional attributes.
* Non-standard currency values.
* Late-arriving events.
* Out-of-order events.

These scenarios are used to demonstrate data quality processing within the Medallion Architecture.
