# Enterprise Banking Data Platform

# Data Model

## 1. Purpose

This document defines the enterprise data model used by the **Enterprise Banking Data Platform**.

The platform uses **Data Vault 2.0** as the enterprise modeling approach in the GOLD layer.

Data Vault separates the banking domain into three primary structures:

```text
HUBS
  │
  ├── Business Keys
  │
  ▼
LINKS
  │
  ├── Business Relationships
  │
  ▼
SATELLITES
  │
  └── Descriptive & Historical Attributes
```

This separation allows the platform to preserve business history, maintain relationships between entities, and evolve the model as new banking requirements are introduced.

The Data Vault is populated from the validated and standardized **SILVER layer**.

---

# 2. Data Model Architecture

The overall data-modeling flow is:

```text
SILVER
   │
   ▼
Data Vault 2.0
   │
   ├── Hubs
   ├── Links
   └── Satellites
   │
   ▼
Analytics
```

The Data Vault therefore represents the enterprise historical layer rather than performing the primary source-data cleansing.

Data quality and standardization are primarily handled before the data reaches the Data Vault.

---

# 3. Business Entities

The platform currently models four core banking entities.

| Business Entity | Description                                                 | Data Vault Object |
| --------------- | ----------------------------------------------------------- | ----------------- |
| Customer        | Individual or organization associated with banking accounts | `HUB_CUSTOMER`    |
| Account         | Financial account used to hold or transfer funds            | `HUB_ACCOUNT`     |
| Transaction     | Immutable business event representing financial activity    | `HUB_TRANSACTION` |
| Merchant        | Business associated with merchant transactions              | `HUB_MERCHANT`    |

These entities form the core business vocabulary of the simulated banking environment.

---

# 4. Hubs

Hubs represent core business entities and contain their stable business keys.

The current model contains:

```text id="a4n8b0"
HUB_CUSTOMER
HUB_ACCOUNT
HUB_TRANSACTION
HUB_MERCHANT
```

A Hub is intentionally kept relatively stable.

Descriptive attributes are not stored directly in the Hub. Instead, they are maintained in Satellites.

---

# 5. Hub Business Keys

Each Hub contains a business key representing the corresponding entity.

| Hub               | Business Key     |
| ----------------- | ---------------- |
| `HUB_CUSTOMER`    | `customer_id`    |
| `HUB_ACCOUNT`     | `account_id`     |
| `HUB_TRANSACTION` | `transaction_id` |
| `HUB_MERCHANT`    | `merchant_id`    |

The platform generates deterministic hash keys from these business identifiers.

For example, the Transaction Hub uses:

```sql id="2wzq83"
MD5(transaction_id)
```

as the transaction hash key.

Conceptually:

```text id="6hqb2m"
Business Key
     │
     ▼
 Hash Function
     │
     ▼
Business Hash Key
```

This hash key is then used by downstream Links and Satellites.

---

# 6. Hub Structure

A typical Hub contains:

```text
Business Hash Key
Business Key
Load Date
Load Source
```

For example, the Transaction Hub contains the conceptual attributes:

```text id="h9d6ad"
TRANSACTION_HK
TRANSACTION_ID
LOAD_DATE
LOAD_SOURCE
```

The Hub therefore establishes the stable identity of a transaction without storing its descriptive transaction attributes.

---

# 7. Links

Links represent relationships between business entities.

The current implementation contains relationships involving:

```text id="6xj6jw"
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

The implemented transaction relationship is:

```text id="v0l8vh"
ACCOUNT
   │
   ▼
TRANSACTION
```

and is represented by:

```text
LINK_ACCOUNT_TRANSACTION
```

---

# 8. Account–Transaction Link

`LINK_ACCOUNT_TRANSACTION` represents the relationship between an account and a transaction.

The Link contains the hash keys required to associate the two business entities.

Conceptually:

```text id="7g5u6n"
HUB_ACCOUNT
     │
     │ ACCOUNT_HK
     ▼
LINK_ACCOUNT_TRANSACTION
     ▲
     │ TRANSACTION_HK
     │
HUB_TRANSACTION
```

The Link therefore separates the relationship itself from the descriptive information stored in the Transaction Satellite.

---

# 9. Link Business Key

The Account–Transaction relationship is represented by a deterministic hash key derived from the source account and transaction identifiers.

Conceptually:

```sql id="9g7x5n"
MD5(source_account_id || '|' || transaction_id)
```

This produces a deterministic relationship identifier.

The delimiter is used to avoid ambiguous concatenation of the two business keys.

The Link therefore contains the conceptual structure:

```text id="n5s2dd"
ACCOUNT_TRANSACTION_HK
ACCOUNT_HK
TRANSACTION_HK
LOAD_DATE
RECORD_SOURCE
```

---

# 10. Satellites

Satellites contain descriptive and historical attributes associated with Hubs or Links.

The current model contains Satellites for the major banking entities.

```text id="ykv4yq"
HUB_CUSTOMER
      │
      ▼
SAT_CUSTOMER

HUB_ACCOUNT
      │
      ▼
SAT_ACCOUNT

HUB_TRANSACTION
      │
      ▼
SAT_TRANSACTION

HUB_MERCHANT
      │
      ▼
SAT_MERCHANT
```

Satellites allow descriptive information to change over time without modifying the underlying Hub business key.

---

# 11. Customer Satellite

`SAT_CUSTOMER` stores descriptive attributes associated with customers.

Conceptual attributes include:

* Customer name
* Email
* Phone
* Address
* Date of birth
* Other customer descriptive attributes

The Customer Hub identifies the customer, while the Satellite stores information describing that customer.

```text id="4q5t3x"
HUB_CUSTOMER
      │
      ▼
SAT_CUSTOMER
```

---

# 12. Account Satellite

`SAT_ACCOUNT` stores descriptive attributes associated with bank accounts.

Conceptual attributes include:

* Account type
* Account status
* Currency
* Opening date
* Other account attributes

The structure separates account identity from account characteristics.

```text id="v0j4xk"
HUB_ACCOUNT
      │
      ▼
SAT_ACCOUNT
```

---

# 13. Transaction Satellite

`SAT_TRANSACTION` stores the descriptive attributes associated with a transaction.

The implemented transaction Satellite contains attributes including:

```text id="5q8y7z"
TRANSACTION_HK
SOURCE_ACCOUNT_ID
DESTINATION_ACCOUNT_ID
MERCHANT_ID
AMOUNT
CURRENCY
TRANSACTION_TYPE
TRANSACTION_TIMESTAMP
STATUS
```

The relationship is:

```text id="wquw5c"
HUB_TRANSACTION
      │
      │ TRANSACTION_HK
      ▼
SAT_TRANSACTION
```

The Transaction Satellite therefore contains the details of the transaction while the Transaction Hub maintains its stable business identity.

---

# 14. Merchant Satellite

`SAT_MERCHANT` stores descriptive attributes associated with merchants.

Conceptual attributes include:

* Merchant name
* Merchant category
* City
* Country
* Other merchant attributes

The Merchant Hub identifies the merchant, while the Satellite contains its descriptive information.

```text id="gjf9wm"
HUB_MERCHANT
      │
      ▼
SAT_MERCHANT
```

---

# 15. Complete Data Vault Model

The current conceptual model can be represented as:

```text id="3l3wpi"
                         HUB_CUSTOMER
                              │
                              ▼
                        SAT_CUSTOMER
                             
                             
                         HUB_ACCOUNT
                              │
                              │
                              ▼
                  LINK_ACCOUNT_TRANSACTION
                              ▲
                              │
                              │
                       HUB_TRANSACTION
                              │
                              ▼
                      SAT_TRANSACTION


                         HUB_MERCHANT
                              │
                              ▼
                       SAT_MERCHANT
```

The Account–Transaction Link establishes the relationship between accounts and transactions, while the Transaction Satellite contains the descriptive transaction attributes.

---

# 16. Transaction Data Flow

Transactions enter the Data Vault from the validated Silver layer.

```text id="q4clp7"
SILVER_TRANSACTIONS
        │
        ▼
HUB_TRANSACTION
        │
        ├──────────────┐
        │              │
        ▼              ▼
LINK_ACCOUNT_       SAT_TRANSACTION
TRANSACTION
```

The loading process is incremental.

New transaction records are identified through Snowflake Streams and processed through the Data Vault task dependency graph.

---

# 17. Incremental Data Vault Loading

The Data Vault transaction pipeline uses a task dependency graph.

The current transaction-loading sequence is:

```text id="7xv2fh"
GOLD_LOAD_HUB_TRANSACTION
          │
          ▼
LINK_TRANSACTION_TASK
          │
          ▼
SAT_TRANSACTION_TASK
```

The Hub task acts as the root task.

The Link task runs after the Hub task.

The Satellite task runs after the Link task.

This ensures that dependent records are processed in the required order.

---

# 18. Hash-Key Strategy

Hash keys are used throughout the Data Vault to provide deterministic identifiers.

For example:

```text id="f4tx7q"
transaction_id
      │
      ▼
     MD5
      │
      ▼
TRANSACTION_HK
```

For relationships:

```text id="s9c4hm"
source_account_id + transaction_id
              │
              ▼
             MD5
              │
              ▼
ACCOUNT_TRANSACTION_HK
```

This approach provides consistent identifiers for Hubs and Links and simplifies relationships between Data Vault objects.

---

# 19. Historical Data

One of the primary benefits of the Data Vault model is the ability to preserve historical descriptive information.

Instead of overwriting historical Satellite information, new records can be inserted when descriptive attributes change.

Conceptually:

```text id="kw4t1x"
Time 1
Customer
   │
   ▼
Satellite Record 1

Time 2
Customer changes
   │
   ▼
Satellite Record 2

Time 3
Customer changes again
   │
   ▼
Satellite Record 3
```

This allows historical changes to be retained.

---

# 20. Separation of Responsibilities

The platform intentionally separates transformation and modeling responsibilities.

```text id="5y8c3p"
RAW
 │
 │ Source Representation
 ▼
BRONZE
 │
 │ Structured Source Data
 ▼
SILVER
 │
 │ Cleansing
 │ Standardization
 │ Validation
 ▼
DATA VAULT GOLD
 │
 │ Enterprise Historical Model
 ▼
ANALYTICS
```

This separation prevents the Data Vault from becoming a replacement for the data-quality layer.

The Silver layer prepares trusted data.

The Data Vault then organizes that data into an enterprise historical model.

---

# 21. Data Vault and Analytics

The Data Vault acts as the historical enterprise foundation for downstream analytics.

The relationship is:

```text id="zhk8g8"
DATA VAULT 2.0
      │
      ├── Hubs
      ├── Links
      └── Satellites
             │
             ▼
         Analytics
```

Analytical datasets can subsequently be derived from the Data Vault without changing the underlying historical model.

---

# 22. Data Vault and Transaction Monitoring

The Transaction Satellite also provides the foundation for operational monitoring.

For example, the platform monitors high-value transactions:

```text id="1kz1yn"
SAT_TRANSACTION
       │
       ▼
 AMOUNT >= 100000
       │
       ▼
Snowflake Alert
       │
       ├──────────────► Alert Log
       │
       └──────────────► Notification
```

This demonstrates that the Data Vault is not only used for historical storage but can also serve as a reliable source for downstream monitoring and analytical processes.

---

# 23. Design Principles

The Data Vault model follows these principles.

### Business Entities → Hubs

Core banking entities are represented as Hubs.

```text
Customer
Account
Transaction
Merchant
```

---

### Relationships → Links

Relationships between business entities are represented by Links.

The current implementation includes:

```text
Account ↔ Transaction
```

---

### Descriptive Data → Satellites

Descriptive and historical attributes are stored in Satellites.

```text
Customer → SAT_CUSTOMER
Account → SAT_ACCOUNT
Transaction → SAT_TRANSACTION
Merchant → SAT_MERCHANT
```

---

### Stable Business Keys

Business keys provide the stable identity of business entities.

```text
customer_id
account_id
transaction_id
merchant_id
```

---

### Deterministic Hash Keys

Hash keys provide deterministic identifiers for Hubs and Links.

---

### Historical Preservation

Historical descriptive information is retained through Satellite records rather than overwriting the existing history.

---

### Separation of Concerns

Data cleansing belongs primarily to the Silver layer, while enterprise historical modeling belongs to the Data Vault.

---

### Incremental Processing

New data is processed incrementally using Snowflake Streams and Tasks rather than rebuilding the entire Data Vault for every ingestion cycle.

---

# 24. Extensibility

The current model provides the foundation for additional banking entities.

Potential future Hubs include:

```text id="b74pj3"
HUB_BRANCH
HUB_LOAN
HUB_CARD
HUB_DEVICE
```

Additional Links could represent relationships such as:

```text id="7l0e6m"
Customer ↔ Loan
Customer ↔ Card
Account ↔ Card
Transaction ↔ Device
Transaction ↔ Branch
```

These can be added to the existing Data Vault without requiring a redesign of the existing Hubs.

This is one of the key advantages of Data Vault 2.0: the model can evolve as the business domain grows.

---

# 25. Final Data Model

The completed enterprise data model can be summarized as:

```text id="v4m8y7"
                         ┌───────────────┐
                         │ HUB_CUSTOMER  │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │ SAT_CUSTOMER  │
                         └───────────────┘


                         ┌───────────────┐
                         │ HUB_ACCOUNT   │
                         └───────┬───────┘
                                 │
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │ LINK_ACCOUNT_TRANSACTION│
                    └────────────┬────────────┘
                                 │
                                 │
                                 ▼
                       ┌──────────────────┐
                       │ HUB_TRANSACTION  │
                       └────────┬─────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │ SAT_TRANSACTION  │
                       └──────────────────┘


                         ┌───────────────┐
                         │ HUB_MERCHANT  │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │ SAT_MERCHANT  │
                         └───────────────┘
```

The resulting Data Vault 2.0 model provides the Enterprise Banking Data Platform with a scalable foundation for **business-key management, relationship modeling, historical tracking, incremental loading, analytics, and operational monitoring**.
