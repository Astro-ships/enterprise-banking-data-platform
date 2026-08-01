# Data Model

## 1. Purpose

This document defines the conceptual data model for the Enterprise Banking Data Platform.

The platform adopts Data Vault 2.0 as its enterprise data model. Business entities are represented as Hubs, business relationships as Links, and descriptive attributes as Satellites.

This document serves as the blueprint for implementing the Gold layer.

---

# 2. Business Entities

The platform models the following core business entities.

| Business Entity | Description                                                    | Data Vault Object |
| --------------- | -------------------------------------------------------------- | ----------------- |
| Customer        | Individual or organization that owns one or more bank accounts | HUB_CUSTOMER      |
| Account         | Financial account used to perform banking transactions         | HUB_ACCOUNT       |
| Transaction     | Immutable business event representing a financial transaction  | HUB_TRANSACTION   |
| Merchant        | Business receiving card payments                               | HUB_MERCHANT      |

---

# 3. Business Relationships

The following business relationships exist between entities.

| Relationship              | Description                                                                 | Data Vault Object         |
| ------------------------- | --------------------------------------------------------------------------- | ------------------------- |
| Customer owns Account     | A customer may own one or more accounts                                     | LINK_CUSTOMER_ACCOUNT     |
| Transaction uses Account  | A transaction is associated with one or more accounts depending on its type | LINK_TRANSACTION_ACCOUNT  |
| Transaction pays Merchant | Card payment transactions reference a merchant                              | LINK_TRANSACTION_MERCHANT |

---

# 4. Hub Business Keys

Each Hub stores a stable business key supplied by the business domain.

| Hub             | Business Key   |
| --------------- | -------------- |
| HUB_CUSTOMER    | customer_id    |
| HUB_ACCOUNT     | account_id     |
| HUB_TRANSACTION | transaction_id |
| HUB_MERCHANT    | merchant_id    |

Business keys are immutable and uniquely identify business entities.

---

# 5. Satellites

Satellites store descriptive attributes that may change over time.

## SAT_CUSTOMER

* customer_name
* email
* phone
* address
* date_of_birth

---

## SAT_ACCOUNT

* account_type
* account_status
* account_currency
* opened_date

---

## SAT_TRANSACTION

* transaction_type
* amount
* currency
* status
* channel
* transaction_timestamp

---

## SAT_MERCHANT

* merchant_name
* merchant_category
* city
* country

---

# 6. Conceptual Model

Customer

↓

Account

↓

Transaction

↓

Merchant

The model separates business entities from business relationships to minimize redundancy and preserve business history.

---

# 7. Design Principles

The data model follows these principles:

* Business entities are represented as Hubs.
* Relationships between entities are represented as Links.
* Descriptive attributes are stored in Satellites.
* Business history is preserved by inserting new Satellite records rather than updating existing records.
* Business keys remain stable throughout the lifetime of an entity.

---

# 8. Future Enhancements

The model is designed to evolve as additional banking capabilities are introduced.

Potential future Hubs include:

* HUB_BRANCH
* HUB_LOAN
* HUB_CARD
* HUB_DEVICE

These additions can be incorporated without redesigning the existing model, supporting the extensibility goals of Data Vault 2.0.
