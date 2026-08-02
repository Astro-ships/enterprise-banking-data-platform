
# ==========================================================
# Customer Collection Generation
# ==========================================================
# Generates the master list of banking customers.
# Each customer is created independently and stored in a list.

from event_generator.generators.customer_generator import generate_customer

def generate_customers(total_customers : int):
    """
    Generate a list of customers
    """
    customers=[]
    for _ in range(total_customers):
        customer=generate_customer() 
        customers.append(customer)
    return customers 
# ==========================================================
# Account Collection Generation
# ==========================================================
# Generates banking accounts for existing customers.
# Each customer owns between 1 and 3 accounts.

from event_generator.generators.account_generator import generate_account
import random

def generate_accounts(customers): 
    """
    Generate a list of accounts
    """

    accounts=[]
    for customer in customers:
         # Randomly assign 1–3 accounts to each customer
        number_of_accounts=random.randint(1,3)
        for _ in range(number_of_accounts):
            account=generate_account(customer.customer_id) 
            accounts.append(account)
    return accounts 

# ==========================================================
# Merchant Collection Generation
# ==========================================================

from event_generator.generators.merchant_generator import generate_merchant

def generate_merchants(total_merchants :int):
    """
    Generate a collection of Merchant 
    """
    merchants=[]
    for _ in range(total_merchants):
        merchant=generate_merchant() 
        merchants.append(merchant)

    return merchants
# ==========================================================
# Transaction Collection Generation
# ==========================================================
# Generates banking transactions using existing accounts
# and merchants.
import random
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
    transactions=[]

    for _ in range(total_transactions):
        transaction_type=random.choice(TRANSACTION_TYPES)

        # ==========================
        # PURCHASE
        # ==========================
        if transaction_type=="PURCHASE":
            source_account=random.choice(accounts)
            merchant=random.choice(merchants)
            transaction=generate_transaction( 
                source_account_id=source_account.account_id,
                destination_account_id=None,
                merchant_id=merchant.merchant_id,
                transaction_type=transaction_type)

        # ==========================
        # TRANSFER
        # ==========================
        elif transaction_type=="TRANSFER":
            source_account=random.choice(accounts)
            destination_account=random.choice(accounts)
            # Prevent transferring to the same account
            while destination_account.account_id==source_account.account_id:
                destination_account=random.choice(accounts)

            transaction=generate_transaction( 
                source_account_id=source_account.account_id,
                destination_account_id=destination_account,
                merchant_id=None,
                transaction_type=transaction_type)

        # ==========================
        # ATM WITHDRAWAL
        # ==========================

        else: 
            source_account=random.choice(accounts)

            transaction = generate_transaction(
                source_account_id=source_account.account_id,
                destination_account_id=None,
                merchant_id=merchant.merchant_id,
                transaction_type=transaction_type
            )    
        transactions.append(transaction)     
    return transactions