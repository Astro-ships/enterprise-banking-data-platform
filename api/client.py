# ==========================================================
# FastAPI Client
# ==========================================================
# Sends generated transaction events to the FastAPI server
# through the POST /transactions endpoint.

import requests as req 

API_URL="http://127.0.0.1:8000/transactions"
def send_transaction(transaction):
      payload = {
        "transaction_id": transaction.transaction_id,
        "source_account_id": transaction.source_account_id,
        "destination_account_id": transaction.destination_account_id,
        "merchant_id": transaction.merchant_id,
        "amount": transaction.amount,
        "currency": transaction.currency,
        "transaction_type": transaction.transaction_type,
        "transaction_timestamp": transaction.transaction_timestamp.isoformat(),
        "status": transaction.status
    }
      response=req.post(
            API_URL,
            json=payload
        
      )
      return response