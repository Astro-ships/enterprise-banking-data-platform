# ==========================================================
# FastAPI Application
# ==========================================================
# Creates the FastAPI application and exposes HTTP endpoints
# for receiving banking transaction events.

from fastapi import FastAPI as fapi 

from api.models import TransactionRequest
# ==========================================================
# Application Instance
# ==========================================================
app = fapi(
    title="Enterprise Banking Data Platform",
    description="API for receiving banking transaction events ",
    version="1.1.0"
)
# ==========================================================
# Transaction Endpoint
# ==========================================================
@app.post ("/transactions")
def receive_transaction(transaction: TransactionRequest): 
    return{
        "message": "Transaction recieved",
        "transaction_id" : transaction.transaction_id
    }