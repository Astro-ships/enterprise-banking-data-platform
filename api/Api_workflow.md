SERVER STARTUP
────────────────────────────────────────────

main.py loaded
     │
     ├── import FastAPI
     ├── import TransactionRequest
     │
     ├── app = FastAPI(...)
     │
     └── @app.post("/transactions")
             │
             └── register receive_transaction()
                         │
                         ▼
                   FastAPI waits


CLIENT EXECUTION
────────────────────────────────────────────

generate_transaction()
     │
     ▼
Transaction object
     │
     ▼
send_transaction(transaction)
     │
     ├── create payload dictionary
     │
     ├── requests.post()
     │
     ▼
HTTP POST /transactions
     │
     ▼
Uvicorn
     │
     ▼
FastAPI
     │
     ├── find matching route
     │
     ├── validate JSON with Pydantic
     │
     ├── create TransactionRequest
     │
     └── call receive_transaction()
                    │
                    ▼
                 response
                    │
                    ▼
              HTTP 200 + JSON
                    │
                    ▼
             requests.Response
                    │
                    ▼
              response.json()