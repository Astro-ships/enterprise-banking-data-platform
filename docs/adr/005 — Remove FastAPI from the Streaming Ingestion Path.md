# ADR 005 — Remove FastAPI from the Streaming Ingestion Path

**Status:** Accepted
**Date:** 2026-08-22
**Decision:** Remove FastAPI from the transaction streaming architecture.

## Context

The original implementation introduced FastAPI between the transaction generator and Snowflake.

The intended flow was:

```text
Transaction Generator
        ↓
FastAPI
        ↓
Snowflake
```

FastAPI was introduced as an HTTP interface through which generated transactions could be sent to the backend.

During implementation, we determined that this added an unnecessary layer for the current project.

The transaction generator is an internal application component, not an external client that requires an HTTP API. The actual requirement is to generate banking transaction events and stream them into Snowflake in real time.

Snowflake Streaming Ingest already provides the required programmatic ingestion interface through the Snowflake Python SDK.

Therefore, the FastAPI layer did not provide functionality that was required by the streaming pipeline.

## Decision

FastAPI will be removed completely from the transaction ingestion path.

The transaction generator will communicate directly with the Snowflake Streaming Ingest SDK.

The resulting architecture is:

```text
                         run.py
                           │
                           ▼
                 Transaction Generator
                           │
                           ▼
                 Streaming Controller
                           │
                           ▼
              Snowflake Streaming Ingest SDK
                           │
                           ▼
                  Snowpipe Streaming
                           │
                           ▼
                       Snowflake
```

The responsibilities are now separated as follows:

* **Transaction Generator** — creates realistic banking transaction events.
* **Streaming Controller** — controls transaction generation and timing.
* **Snowpipe Streaming Client** — manages authentication, channel creation, and ingestion into Snowflake.
* **run.py** — orchestrates the application workflow.
* **Snowflake** — receives and stores the streaming events.

## Why FastAPI Was Removed

### 1. It was not required

The generator is not an external consumer requiring an HTTP endpoint.

Adding an HTTP API merely to move data from one Python component to another introduced unnecessary communication overhead.

### 2. It duplicated functionality

The Snowflake Streaming SDK already provides a direct programmatic interface for sending rows to Snowflake.

The FastAPI layer therefore became:

```text
Python → HTTP → Python → Snowflake
```

instead of:

```text
Python → Snowflake Streaming SDK → Snowflake
```

The second approach is simpler and more appropriate for this use case.

### 3. It increased application complexity

FastAPI introduced additional components:

* API routes
* HTTP requests
* request/response handling
* Pydantic request models
* API testing code
* Uvicorn
* additional error-handling paths

None of these were necessary for the core streaming requirement.

### 4. It blurred component responsibilities

The API layer made the architecture look like a service-to-service architecture even though the transaction generator and streaming client are part of the same application.

Removing FastAPI gives each component a clearer responsibility.

### 5. It reduces unnecessary dependencies

The project no longer requires FastAPI, Uvicorn, or API-specific Pydantic models solely for transaction ingestion.

This keeps the streaming application smaller and easier to maintain.

## Consequences

### Positive

* Simpler architecture.
* Fewer dependencies.
* Fewer failure points.
* Direct use of Snowflake Streaming Ingest.
* Easier local development and testing.
* Clearer separation between data generation and data ingestion.
* More representative of a streaming data-engineering pipeline.

### Negative

FastAPI would have been useful if the project required an external HTTP interface.

For example:

```text
External Application
        ↓
      REST API
        ↓
Transaction Processing
        ↓
Snowflake
```

That capability is no longer present.

However, this is acceptable because an HTTP API is not currently a project requirement.

## Alternatives Considered

### Keep FastAPI

Rejected because it adds an unnecessary intermediary between the internal transaction generator and Snowflake.

### Send data directly through the Snowflake Python Connector

Rejected for the real-time ingestion path because the Snowflake Connector is primarily a database interaction interface, whereas Snowflake Streaming Ingest is specifically designed for continuous row ingestion.

### Use Snowflake Streaming Ingest directly

**Accepted.**

It provides the required direct streaming path and removes unnecessary application infrastructure.

## Resulting Principle

The project will use the simplest architecture that satisfies the actual requirement.

> **Do not introduce an application layer merely because it is technically possible.**

FastAPI may be reintroduced in the future if the project evolves to require an external REST API, but it will not be part of the current streaming ingestion pipeline.
