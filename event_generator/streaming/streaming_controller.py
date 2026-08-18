# ==========================================================
# Transaction Collection Generation
# ==========================================================
# Generates banking transactions using existing accounts
# and merchants.
import random
import time
from event_generator.streaming.base_data_loader import load_base_data
from event_generator.generators.transaction_amount_generator import generate_transaction_amount
from event_generator.generators.transaction_generator import generate_transaction
TRANSACTION_TYPES = [
    "PURCHASE",
    "TRANSFER",
    "ATM_WITHDRAWAL"
]
def generate_transactions(accounts,merchants,total_transactions: int):
    """
    Generate a collection of transaction record 
    """
    ACTIVE_STATUSES = [
                        "ACTIVE",
                        "Active",
                        "active",
                        "ACT",
                        "Act"
    ]

    for _ in range(total_transactions):
        transaction_type=random.choice(TRANSACTION_TYPES)
        amount=generate_transaction_amount(transaction_type)

        # ==========================
        # PURCHASE
        # ==========================
        if transaction_type=="PURCHASE":
            # Only active accounts are allowed to initiate transactions.
            source_account=random.choice(accounts)
            while source_account["status"] not in ACTIVE_STATUSES:
                source_account = random.choice(accounts)
            merchant=random.choice(merchants)
            transaction=generate_transaction( 
                source_account_id=source_account["account_id"],
                destination_account_id=None,
                merchant_id=merchant["merchant_id"],
                transaction_type=transaction_type,
                currency=source_account["currency"]
                )

        # ==========================
        # TRANSFER
        # ==========================
        elif transaction_type=="TRANSFER":
            source_account = random.choice(accounts)
            while source_account["status"] not in ACTIVE_STATUSES:
                source_account = random.choice(accounts)
            destination_account=random.choice(accounts)
            # Prevent transferring to the same account 
            # Only active accounts are allowed to initiate transactions.
            while (
                    destination_account["account_id"]==source_account["account_id"]
                   or destination_account["status"] not in ACTIVE_STATUSES ):
                destination_account=random.choice(accounts)

            transaction=generate_transaction( 
                source_account_id=source_account["account_id"],
                destination_account_id=destination_account["account_id"],
                merchant_id=None,
                transaction_type=transaction_type,
                currency=source_account["currency"]
                )

        # ==========================
        # ATM WITHDRAWAL
        # ==========================

        else: 
            source_account = random.choice(accounts)
            while source_account["status"] not in ACTIVE_STATUSES:
                source_account = random.choice(accounts)
            transaction = generate_transaction(
                source_account_id=source_account["account_id"],
                destination_account_id=None,
                merchant_id=None,
                transaction_type=transaction_type,
                currency=source_account["currency"]
            )
        yield transaction
        time.sleep(5)
# ==========================================
# Test transaction payload
# ==========================================
if __name__=="__main__":
    accounts,merchants=load_base_data()
    transactions=generate_transactions(
        accounts,merchants,5
    )
    for transaction in transactions:
        print(transaction)
