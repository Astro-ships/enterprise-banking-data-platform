from event_generator.generators.customer_generator import generate_customer 
from event_generator.generators.account_generator import generate_account
from event_generator.generators.merchant_generator import generate_merchant
from event_generator.generators.transaction_generator import generate_transaction


def run_simulation():
    customer=generate_customer()
    account=generate_account(customer.customer_id)
    merchant=generate_merchant() 
    transaction=generate_transaction(source_account_id=account.account_id,merchant_id=merchant.merchant_id)

    return{
        "customer":customer,
        "account":account,
        "merchant":merchant,
        "transaction":transaction
    }
