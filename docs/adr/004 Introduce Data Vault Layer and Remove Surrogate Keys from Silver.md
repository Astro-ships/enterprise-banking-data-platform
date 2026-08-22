# ADR-004: Introduce Data Vault Layer and Remove Surrogate Keys from Silver

## Status

Accepted

## Context

The initial implementation introduced surrogate keys in the Silver layer to support future dimensional modeling. During the architecture review, it became clear that this approach mixed transformation responsibilities with warehouse modeling.

The Silver layer is intended to contain clean, standardized, and validated business data. It should remain independent of any downstream modeling technique.

To better align the project with enterprise data warehouse practices, a Data Vault layer will be introduced between Silver and Gold.

## Decision

The architecture has been updated as follows:

```text
RAW
   ↓
BRONZE
   ↓
SILVER
   ↓
VAULT
   ↓
GOLD
```

The following changes will be made:

* Remove all surrogate keys from the Silver layer.
* Build Data Vault objects (Hubs, Links, and Satellites) directly from the Silver tables.
* Generate Hash Keys (HKs) in the Vault layer using business keys.
* Generate integer surrogate keys only when building Gold dimension tables.

## Responsibilities

### Silver

* Clean and standardize source data.
* Apply business rules and data quality corrections.
* Preserve original business keys.
* Do not generate warehouse-specific identifiers.

### Vault

* Create Hubs for business entities.
* Create Links to model business relationships.
* Create Satellites to store descriptive attributes and historical changes.
* Generate Hash Keys for entity identification.

### Gold

* Build dimensional models (Fact and Dimension tables).
* Generate surrogate keys for dimensions.
* Optimize data structures for reporting and analytics.

## Consequences

### Advantages

* Maintains a clear separation of responsibilities between layers.
* Keeps Silver independent of downstream modeling approaches.
* Aligns the project with Data Vault 2.0 methodology.
* Supports future incremental loads and historical tracking.
* Produces a cleaner Star Schema in the Gold layer.

### Trade-offs

* Introduces additional ETL steps.
* Increases the number of tables maintained.
* Requires additional storage for Hubs, Links, and Satellites.

## Rationale

Surrogate keys are a dimensional modeling construct and therefore belong in the Gold layer, not in Silver. Introducing a dedicated Data Vault layer allows business keys to remain unchanged throughout Silver while providing an enterprise-grade integration layer before constructing analytical star schemas.
