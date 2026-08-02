
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