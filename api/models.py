# ==========================================================
# FastAPI Request Model
# =========================================================
from pydantic import BaseModel
from datetime import datetime


class TransactionRequest(BaseModel):

    # ======================================================
    # Transaction Identifiers
    # ======================================================
    transaction_id: str
    source_account_id: str
    destination_account_id: str | None
    merchant_id: str | None

    # ======================================================
    # Transaction Details
    # ======================================================
    amount: float
    currency: str
    transaction_type: str

    # ======================================================
    # Transaction Metadata
    # ======================================================
    transaction_timestamp: datetime
    status: str