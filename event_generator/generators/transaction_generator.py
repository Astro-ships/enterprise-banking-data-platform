# ===========================
# transaction_generator.py
# ===========================

from faker import Faker
import random
from datetime import datetime
from event_generator.generators.transaction_amount_generator import generate_transaction_amount
from event_generator.models.transaction import Transaction

fake = Faker()

TRANSACTION_TYPES = [
    "PURCHASE",
    "TRANSFER",
    "ATM_WITHDRAWAL"
]

STATUSES = [
    "success",
    "failed",
    "pending",
    "penDing",
    "SucESs",
    " penDing",
    "reversed",
    "failed"
]


def generate_transaction(source_account_id: str,
                        destination_account_id: str | None,
                        merchant_id: str | None,
                        transaction_type: str,
                        currency:str
                        ) -> Transaction:

    """
    Generate a banking transaction event.
    """

    transaction = Transaction(

        transaction_id=fake.uuid4(),
        source_account_id=source_account_id,
        destination_account_id=destination_account_id,
        merchant_id=merchant_id,
        amount=generate_transaction_amount(transaction_type),
        currency=currency,
        transaction_type=transaction_type,
        transaction_timestamp=datetime.now(),
        status=random.choice(STATUSES)

    )

    return transaction