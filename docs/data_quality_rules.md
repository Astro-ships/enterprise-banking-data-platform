
# Enterprise Banking Data Platform

# Data Quality Rules Documentation

## 1. Overview

This document defines the data quality rules and validation standards for the Enterprise Banking Data Platform.

The event generator intentionally produces imperfect banking data to simulate real-world source systems. In real enterprise environments, data received from operational systems often contains missing values, inconsistent formats, duplicate records, invalid values, and relationship issues.

The purpose of the data quality process is to identify, validate, and correct these issues before the data reaches analytical and reporting layers.

The quality process follows the platform architecture:

```

Source Systems
|
|
Event Generator
(Messy Banking Data)
|
|
Bronze Layer
(Raw Data Storage)
|
|
Silver Layer
(Data Cleaning & Validation)
|
|
Data Vault 2.0
(Historical Enterprise Model)
|
|
Gold Layer
(Analytics & Reporting)

````

---

# 2. Data Quality Dimensions

The platform evaluates data quality using the following dimensions.

---

## 2.1 Completeness

### Definition

Ensures required fields contain values and are not missing.

### Example Problem

```json
{
    "account_number": null
}
````

### Expected Behavior

Required business fields should always contain valid values.

---

## 2.2 Validity

### Definition

Ensures data values follow predefined business rules and accepted formats.

### Example Problem

Invalid account status:

```
ACT
```

Expected:

```
ACTIVE
```

---

## 2.3 Consistency

### Definition

Ensures the same data is represented in the same format across the platform.

### Example Problem

The same currency represented differently:

```
PKR
pkr
Pakistani Rupee
```

Expected:

```
PKR
```

---

## 2.4 Accuracy

### Definition

Ensures data represents the correct business meaning.

### Example Problem

A Pakistani customer account:

```
Country: Pakistan
Currency: USD
```

may require validation.

---

## 2.5 Uniqueness

### Definition

Ensures duplicate records are identified and controlled.

### Example:

Duplicate customers:

```
Customer ID: 101
Email: ali@test.com
```

and

```
Customer ID: 202
Email: ali@test.com
```

---

## 2.6 Referential Integrity

### Definition

Ensures relationships between entities are maintained.

### Example:

A transaction references an account that does not exist.

Invalid:

```
Transaction
     |
     X
Account
```

---

# 3. Customer Data Quality Rules

## 3.1 Required Fields

The following fields are mandatory:

| Column       | Rule               |
| ------------ | ------------------ |
| customer_id  | Must not be NULL   |
| first_name   | Must not be NULL   |
| last_name    | Must not be NULL   |
| email        | Must not be NULL   |
| phone_number | Should not be NULL |

---

## 3.2 Email Validation

Customer emails must follow a valid email format.

Valid:

```
customer@gmail.com
```

Invalid:

```
customer@
gmail
```

---

## 3.3 Duplicate Customer Detection

Potential duplicates should be identified using business keys.

Possible duplicate identifiers:

* email
* phone number
* national identity number

Example SQL logic:

```sql
ROW_NUMBER()
OVER(
PARTITION BY email
ORDER BY created_timestamp
)
```

---

## 3.4 Customer Name Standardization

Problem:

```
ALI KHAN
Ali Khan
ali khan
```

Expected:

```
Ali Khan
```

---

# 4. Account Data Quality Rules

## 4.1 Required Fields

Mandatory fields:

| Column         | Rule               |
| -------------- | ------------------ |
| account_id     | Must not be NULL   |
| customer_id    | Must not be NULL   |
| account_number | Should not be NULL |
| account_type   | Should not be NULL |
| currency       | Must not be NULL   |
| opening_date   | Must not be NULL   |
| status         | Must not be NULL   |

---

## 4.2 Account Number Validation

Every account must have a unique account number.

Invalid:

```json
{
"account_number": null
}
```

Rules:

* Account number cannot be NULL.
* Account number must be unique.
* Account number format must follow banking standards.

---

## 4.3 Account Type Standardization

Accepted account types:

```
SAVINGS
CURRENT
BUSINESS
LOAN
CREDIT
```

Invalid examples:

```
saving
saving account
sav
unknown
```

---

## 4.4 Account Status Standardization

Source values may contain:

```
ACT
Active
active
Dormant
DORM
closed
```

Standardized values:

```
ACTIVE
DORMANT
CLOSED
FROZEN
```

---

## 4.5 Currency Validation

Currency must follow ISO currency codes.

Accepted:

```
PKR
USD
EUR
GBP
```

Invalid:

```
Pakistani Rupee
Dollar
US Dollars
pkr
```

---

## 4.6 Customer Relationship Validation

Every account must belong to an existing customer.

Rule:

```
account.customer_id
must exist in
customer.customer_id
```

---

# 5. Merchant Data Quality Rules

## 5.1 Required Fields

Mandatory fields:

| Column            | Rule               |
| ----------------- | ------------------ |
| merchant_id       | Must not be NULL   |
| merchant_name     | Must not be NULL   |
| merchant_category | Should not be NULL |

---

## 5.2 Merchant Name Standardization

Source examples:

```
Amazon
amazon
AMAZON.COM
Amazon Inc
```

Expected:

```
Amazon
```


---

## 5.3 Duplicate Merchant Detection

Potential duplicates identified by:

* merchant name
* merchant website
* merchant identifier

---

# 6. Transaction Data Quality Rules

## 6.1 Required Fields

Mandatory fields:

| Column                | Rule             |
| --------------------- | ---------------- |
| transaction_id        | Must not be NULL |
| source_account_id     | Must not be NULL |
| amount                | Must not be NULL |
| currency              | Must not be NULL |
| transaction_timestamp | Must not be NULL |
| transaction_type      | Must not be NULL |

---

## 6.2 Transaction Amount Validation

Rules:

```
amount > 0
```

Invalid:

```
-1000
0
NULL
```

---

## 6.3 Transaction Type Validation

Accepted values:

```
PURCHASE
TRANSFER
ATM_WITHDRAWAL
```

---

## 6.4 Transfer Validation

For transfer transactions:

Rule:

```
source_account_id != destination_account_id
```

Invalid:

```
Account A → Account A
```

---

## 6.5 Transaction Account Validation

Every transaction account reference must exist.

Rule:

```
transaction.source_account_id
exists in
account.account_id
```

---

## 6.6 Closed Account Transaction Validation

A closed account should not generate transactions.

Invalid scenario:

```
Account Status:
CLOSED

Transaction:
PURCHASE
```

---

# 7. Data Quality Handling Strategy

## Bronze Layer

Purpose:

* Store raw source data.
* Preserve original records.
* No transformations.
* Maintain audit history.

Example:

```
raw_accounts
raw_transactions
raw_customers
```

---

# Silver Layer

Purpose:

* Apply data quality rules.
* Standardize values.
* Remove duplicates.
* Handle missing values.
* Validate relationships.

Examples:

## Null Handling

```sql
COALESCE(account_type,'UNKNOWN')
```

---

## Standardizing Status

```sql
CASE
WHEN status IN ('ACT','Active','active')
THEN 'ACTIVE'
END
```

---

## Duplicate Removal

```sql
QUALIFY ROW_NUMBER()
OVER(
PARTITION BY account_number
ORDER BY load_timestamp DESC
)=1
```

---

# Gold Layer

Purpose:

Create business-ready datasets for:

* Reporting
* Dashboards
* Analytics
* Machine Learning

Examples:

```
Customer Analytics
Transaction Analytics
Revenue Analysis
Fraud Detection Features
```

---

# 8. Data Quality Monitoring

The platform should track:

* Number of rejected records
* Number of duplicate records
* Missing field counts
* Invalid value counts
* Referential integrity failures

Example:

```
Total Transactions Loaded: 1,500,000

Rejected:
    Missing Account ID: 120
    Invalid Currency: 500
    Duplicate Transactions: 230
```
# 9. Final Objective

The goal of data quality processing is to transform unreliable operational data into trusted enterprise data that can support banking analytics, reporting, and decision-making.


