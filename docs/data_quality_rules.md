# Enterprise Banking Data Platform

# Data Quality Rules Documentation

## 1. Overview

This document defines the data-quality rules and validation approach used by the **Enterprise Banking Data Platform**.

The Banking Simulator intentionally generates imperfect source data to simulate the types of issues commonly encountered in operational banking systems.

These imperfections provide realistic scenarios for testing:

* Data profiling
* Data validation
* Standardization
* Null handling
* Duplicate handling
* Referential-integrity validation
* Business-rule validation
* Incremental data processing

The platform follows a layered approach in which the source data is preserved before quality rules are progressively applied.

```text
Banking Simulator
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

The **RAW layer preserves the source representation**, while the **Bronze and Silver layers progressively structure, validate, cleanse, and standardize the data**.

The Data Vault then provides the historical enterprise model.

---

# 2. Data Quality Dimensions

The platform considers several core data-quality dimensions.

## 2.1 Completeness

Ensures that required fields contain values.

Example:

```json
{
    "account_id": null
}
```

A missing business identifier can prevent the record from being correctly related to other entities.

Required fields are therefore validated before records are promoted to trusted downstream layers.

---

## 2.2 Validity

Ensures that values conform to defined business rules and accepted formats.

Example:

```text
ACT
```

may be standardized to:

```text
ACTIVE
```

The same principle applies to transaction types, currencies, statuses, and other controlled values.

---

## 2.3 Consistency

Ensures that equivalent values are represented consistently.

For example:

```text
PKR
pkr
Pakistani Rupee
```

should ultimately be represented consistently as:

```text
PKR
```

This prevents logically identical values from being treated as separate categories during analytics.

---

## 2.4 Accuracy

Ensures that data is logically appropriate for its business context.

For example, relationships between:

```text
Customer → Account → Transaction
```

must be valid.

Accuracy checks therefore include business-rule and relationship validation rather than only checking data types.

---

## 2.5 Uniqueness

Ensures that records that should be unique are not duplicated.

Examples include:

* Customer identifiers
* Account identifiers
* Account numbers
* Merchant identifiers
* Transaction identifiers

Duplicate detection is particularly important for streaming ingestion because the same event may potentially be received more than once.

---

## 2.6 Referential Integrity

Ensures that relationships between banking entities are valid.

For example:

```text
Transaction
     │
     ▼
Source Account
```

The referenced account should exist in the account dataset.

Similarly:

```text
Account
   │
   ▼
Customer
```

An account should reference an existing customer.

---

# 3. Source Data Quality Strategy

The Banking Simulator intentionally creates source data that is not assumed to be perfect.

The purpose is to allow the platform to demonstrate how downstream Data Engineering processes deal with imperfect operational data.

Potential source-data issues include:

* Missing values
* Duplicate records
* Inconsistent representations
* Invalid relationships
* Invalid business values
* Transaction anomalies
* High-value transactions

The important principle is:

> **Do not assume source data is clean. Profile and validate it before trusting it.**

---

# 4. Customer Data Quality Rules

## 4.1 Required Fields

Customer records should contain the required business attributes.

| Field          | Rule                              |
| -------------- | --------------------------------- |
| `customer_id`  | Must not be NULL                  |
| `first_name`   | Should not be NULL                |
| `last_name`    | Should not be NULL                |
| `email`        | Should not be NULL                |
| `phone_number` | Should not be NULL where required |

The customer identifier is particularly important because it is used to establish relationships with accounts.

---

## 4.2 Customer Identifier

`customer_id` must uniquely identify a customer.

Rules:

* Must not be NULL.
* Must be unique.
* Must maintain a consistent format.
* Must remain stable across downstream processing.

---

## 4.3 Email Validation

Where email data is available, it should follow a valid email structure.

Example:

```text
Valid:
customer@gmail.com

Invalid:
customer@
gmail
```

---

## 4.4 Customer Name Standardization

Equivalent representations should be standardized.

Source examples:

```text
ALI KHAN
Ali Khan
ali khan
```

Expected standardized representation:

```text
Ali Khan
```

---

# 5. Account Data Quality Rules

## 5.1 Required Fields

| Field            | Rule               |
| ---------------- | ------------------ |
| `account_id`     | Must not be NULL   |
| `customer_id`    | Must not be NULL   |
| `account_number` | Must not be NULL   |
| `account_type`   | Must not be NULL   |
| `currency`       | Must not be NULL   |
| `opening_date`   | Should not be NULL |
| `status`         | Must not be NULL   |

---

## 5.2 Account Uniqueness

Each account should have a unique identifier and account number.

Rules:

* `account_id` must be unique.
* `account_number` must be unique.
* Account identifiers must not be NULL.

---

## 5.3 Account Type Standardization

The platform recognizes configured account types such as:

```text
SAVINGS
CURRENT
BUSINESS
LOAN
CREDIT
```

Source variations should be standardized.

Examples:

```text
saving
saving account
sav
```

should map to the appropriate standardized account type where a valid mapping exists.

Unknown or unmappable values should be handled according to the configured Silver-layer quality strategy.

---

## 5.4 Account Status Standardization

Source systems may provide inconsistent status representations.

Examples:

```text
ACT
Active
active
DORM
Dormant
closed
```

These should be standardized to controlled values such as:

```text
ACTIVE
DORMANT
CLOSED
FROZEN
```

---

## 5.5 Currency Standardization

Currency values must use consistent currency codes.

Examples:

```text
PKR
USD
EUR
GBP
```

Source variations such as:

```text
pkr
Pakistani Rupee
Dollar
US Dollars
```

should be mapped to the appropriate standardized currency code where possible.

---

## 5.6 Customer Relationship Validation

Every account should reference an existing customer.

Conceptually:

```text
account.customer_id
        │
        ▼
customer.customer_id
```

If the customer does not exist, the relationship is considered invalid.

This validation is important because the Data Vault ultimately relies on valid business relationships.

---

# 6. Merchant Data Quality Rules

## 6.1 Required Fields

| Field               | Rule               |
| ------------------- | ------------------ |
| `merchant_id`       | Must not be NULL   |
| `merchant_name`     | Must not be NULL   |
| `merchant_category` | Should not be NULL |

---

## 6.2 Merchant Identifier

`merchant_id` must uniquely identify a merchant.

Rules:

* Must not be NULL.
* Must be unique.
* Must maintain a consistent format.

---

## 6.3 Merchant Name Standardization

Equivalent merchant representations should be standardized.

Examples:

```text
Amazon
amazon
AMAZON.COM
Amazon Inc
```

should be mapped to a consistent representation where the appropriate business mapping exists.

---

## 6.4 Duplicate Merchant Detection

Potential duplicates can be identified using available business attributes such as:

* Merchant identifier
* Merchant name
* Merchant website

The final rule depends on which attributes are available in the source data.

---

# 7. Transaction Data Quality Rules

Transactions are particularly important because they form the primary event stream of the platform.

## 7.1 Required Fields

| Field                   | Rule             |
| ----------------------- | ---------------- |
| `transaction_id`        | Must not be NULL |
| `source_account_id`     | Must not be NULL |
| `amount`                | Must not be NULL |
| `currency`              | Must not be NULL |
| `transaction_timestamp` | Must not be NULL |
| `transaction_type`      | Must not be NULL |
| `status`                | Must not be NULL |

---

## 7.2 Transaction Identifier

`transaction_id` must uniquely identify a transaction event.

Rules:

* Must not be NULL.
* Should be unique.
* Must remain stable throughout the pipeline.
* Is used for downstream traceability and Data Vault modeling.

---

## 7.3 Transaction Amount Validation

Normal transactions must have a positive monetary amount.

```text
amount > 0
```

Invalid examples:

```text
-1000
0
NULL
```

---

## 7.4 Transaction Type Validation

The current simulator supports transaction types including:

```text
PURCHASE
TRANSFER
ATM_WITHDRAWAL
```

Only configured transaction types should be accepted by downstream transformations.

---

## 7.5 Transfer Validation

Transfers require both a source and destination account.

The source and destination should not be the same account.

```text
source_account_id != destination_account_id
```

Invalid:

```text
Account A
   │
   └──────► Account A
```

---

## 7.6 Transaction Account Validation

Transaction account references must correspond to existing accounts.

For example:

```text
transaction.source_account_id
              │
              ▼
       account.account_id
```

An unknown account reference represents a referential-integrity failure.

---

## 7.7 Merchant Relationship Validation

Transactions involving merchants should reference a valid merchant.

```text
Transaction
     │
     ▼
merchant_id
     │
     ▼
Merchant
```

This prevents transactions from referencing merchants that do not exist in the simulated environment.

---

## 7.8 Closed Account Validation

Transactions should not normally originate from accounts whose status is:

```text
CLOSED
```

Example invalid scenario:

```text
Account Status
      │
      ▼
    CLOSED

      +

Transaction
      │
      ▼
   PURCHASE
```

Such records should be identified by the transaction validation process.

---

# 8. Duplicate Handling

Duplicate records can occur in both batch and streaming environments.

The platform therefore considers transaction uniqueness when processing incoming data.

A typical deduplication strategy is based on the business identifier:

```text
transaction_id
```

For example:

```sql
QUALIFY ROW_NUMBER()
OVER (
    PARTITION BY transaction_id
    ORDER BY load_timestamp DESC
) = 1
```

This retains the selected record while eliminating duplicate representations of the same transaction event.

The exact deduplication strategy may vary depending on the source and ingestion mechanism.

---

# 9. Null Handling

NULL handling is performed primarily during the transformation process.

The appropriate strategy depends on the field.

For example, a controlled categorical field may use:

```sql
COALESCE(account_type, 'UNKNOWN')
```

However, business identifiers should generally **not** be replaced with arbitrary placeholder values because doing so can create false relationships.

For example:

```text
customer_id
account_id
transaction_id
```

require stricter validation.

---

# 10. Standardization

The Silver layer is responsible for transforming inconsistent source representations into standardized values.

Examples include:

```text
Source                  Silver
------                  ------
pkr              →      PKR
usd              →      USD
Active           →      ACTIVE
ACT              →      ACTIVE
```

Standardization allows downstream Data Vault and analytical processes to operate on consistent values.

---

# 11. Bronze Layer Quality Strategy

The Bronze layer primarily provides a structured representation of the incoming source data.

Its responsibilities include:

* Parsing incoming records.
* Extracting source attributes.
* Applying appropriate data types.
* Preserving source information.
* Preparing data for Silver-layer processing.

The Bronze layer should not attempt to hide the original source-data problems.

Conceptually:

```text
RAW
 │
 ▼
BRONZE
 │
 │ Structured source representation
 ▼
SILVER
```

---

# 12. Silver Layer Quality Strategy

The Silver layer is the primary data-quality and transformation layer.

Its responsibilities include:

* Applying validation rules.
* Standardizing values.
* Handling NULL values.
* Identifying duplicates.
* Validating relationships.
* Applying business rules.
* Preparing trusted records for downstream modeling.

The resulting data is suitable for loading into the Data Vault.

```text
BRONZE
   │
   ▼
Validation
   │
   ▼
Standardization
   │
   ▼
Deduplication
   │
   ▼
Relationship Validation
   │
   ▼
SILVER
```

---

# 13. Data Vault Quality Considerations

The Data Vault 2.0 layer depends on reliable business keys and relationships.

The Silver layer therefore needs to provide sufficiently validated records before they enter the Data Vault.

The relationship is:

```text
SILVER
   │
   ├── Valid Business Keys
   │
   ├── Valid Relationships
   │
   └── Standardized Attributes
            │
            ▼
      DATA VAULT 2.0
```

The Data Vault then separates the information into:

```text
HUBS
LINKS
SATELLITES
```

For example:

```text
Transaction
    │
    ├──────────────► HUB_TRANSACTION
    │
    ├──────────────► LINK_ACCOUNT_TRANSACTION
    │
    └──────────────► SAT_TRANSACTION
```

Data-quality validation before this stage helps prevent invalid business relationships from entering the enterprise model.

---

# 14. High-Value Transaction Monitoring

The simulator deliberately generates a small percentage of high-value transactions for operational monitoring and alert testing.

Approximately **3% of generated transactions** can be generated within a suspicious high-value range.

Example:

```text
100,000 – 200,000
```

These transactions are not necessarily “fraud” in the real-world sense.

They are **synthetic suspicious transactions used to demonstrate monitoring and alerting functionality**.

The downstream platform detects transactions meeting the configured threshold.

```text
Transaction
     │
     ▼
SAT_TRANSACTION
     │
     ▼
AMOUNT >= 100000
     │
     ▼
Snowflake Alert
     │
     ├────────────► Alert Log
     │
     └────────────► Notification
```

This demonstrates how data-quality and operational-monitoring concepts can work together within a banking data platform.

---

# 15. Streaming Data Quality

The streaming pipeline introduces additional considerations because transactions arrive continuously.

The platform therefore needs to consider:

* Duplicate events
* Missing attributes
* Invalid relationships
* Unexpected transaction values
* Out-of-order events
* Incremental processing
* Stream consumption
* Task dependencies

The downstream architecture processes newly arriving data incrementally:

```text
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
 Data Vault 2.0
```

Snowflake Streams and Tasks allow the downstream layers to process changes without rebuilding the complete dataset.

---

# 16. Data Quality Monitoring

The platform can be extended to track data-quality metrics such as:

* Total records processed
* Records rejected
* Duplicate records
* Missing required fields
* Invalid values
* Referential-integrity failures
* Standardization failures
* Suspicious transactions

Example monitoring output:

```text
Transactions Processed:       1,500,000

Quality Issues:

Missing Account ID:                  120
Invalid Currency:                    500
Duplicate Transactions:             230
Invalid Relationships:                75
Suspicious Transactions:          45,000
```

These metrics provide visibility into the quality of incoming source data and the effectiveness of the transformation pipeline.

---

# 17. Quality Processing Philosophy

The project follows a progressive data-quality approach:

```text
SOURCE
  │
  ▼
PROFILE
  │
  ▼
VALIDATE
  │
  ▼
STANDARDIZE
  │
  ▼
DEDUPLICATE
  │
  ▼
RELATIONSHIP VALIDATION
  │
  ▼
TRUSTED DATA
```

The objective is not to make the source data artificially perfect.

Instead, the platform demonstrates how an enterprise Data Engineering system can receive imperfect data and progressively transform it into trusted information.

---

# 18. Final Data Quality Architecture

The complete data-quality architecture is:

```text
                  BANKING SIMULATOR
                         │
                         ▼
                 Imperfect Source Data
                         │
                         ▼
                       RAW
                         │
                         │ Preserve Source
                         ▼
                      BRONZE
                         │
                         │ Structure
                         ▼
                 Quality Processing
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
       Validate     Standardize    Deduplicate
          │              │              │
          └──────────────┼──────────────┘
                         ▼
                      SILVER
                         │
                         │ Trusted Data
                         ▼
                  DATA VAULT 2.0
                       GOLD
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
          Analytics            Monitoring
                                    │
                                    ▼
                               Alerts /
                              Notifications
```

---

# 19. Final Objective

The objective of the data-quality process is to transform imperfect synthetic banking source data into **trusted, standardized, validated, and historically modeled enterprise data**.

The platform demonstrates how data quality is not a single transformation step, but a continuous process spanning:

```text
Generation
     ↓
Ingestion
     ↓
Profiling
     ↓
Validation
     ↓
Standardization
     ↓
Deduplication
     ↓
Relationship Validation
     ↓
Data Vault Modeling
     ↓
Analytics & Monitoring
```

This approach provides the foundation for reliable banking analytics, historical tracking, operational monitoring, and downstream Data Engineering workloads.
