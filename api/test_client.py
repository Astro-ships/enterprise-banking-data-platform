# ==========================================================
# FastAPI Client Test
# ==========================================================
# Generates one transaction using the existing transaction
# generator and sends it to the FastAPI server.

from event_generator.generators.transaction_generator import generate_transaction
from api.client import send_transaction
# ==========================================================
# Test Transaction
# ==========================================================
transactions=generate_transaction(
    source_account_id="ACC-1001",
    destination_account_id="ACC-2001",
    merchant_id=None,
    transaction_type="TRANSFER",
    currency="EUR"
)
# ==========================================================
# Send Transaction
# ==========================================================

response=send_transaction(transactions)
print(response)