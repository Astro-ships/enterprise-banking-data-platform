# ===========================
# transaction_generator.py
# ===========================

from faker import Faker
import random
from datetime import datetime

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
    " penDing"
]


def generate_transaction( source_account_id: str,merchant_id: str) -> Transaction:

    """
    Generate a banking transaction event.
    """

    transaction = Transaction(

        transaction_id=fake.uuid4(),
        source_account_id=source_account_id,
        destination_account_id=None,
        merchant_id=merchant_id,
        amount=round(random.uniform(1, 100000),2),
        currency=random.choice(["USD","PKR","EUR", "GBP"  ]),
        transaction_type=random.choice(TRANSACTION_TYPES),
        transaction_timestamp=datetime.now(),
        status=random.choice( STATUSES)

    )

    return transaction