# import time
# from event_generator.generators.customer_generator import generate_customer 
# from event_generator.generators.account_generator import generate_account
# from event_generator.generators.merchant_generator import generate_merchant
# from event_generator.generators.transaction_generator import generate_transaction
# from event_generator.formatter import format_event

# def run_simulation():
#     customer=generate_customer()
#     account=generate_account(customer.customer_id)
#     merchant=generate_merchant() 
#     transaction=generate_transaction(source_account_id=account.account_id,merchant_id=merchant.merchant_id)

#     return{
#         "customer":customer,
#         "account":account,
#         "merchant":merchant,
#         "transaction":transaction
#     }


# # def run_event_generator():
# #     while True:
# #         event=run_simulation()
# #         print(event["customer"])
# #         print(event["account"])
# #         print(event["merchant"])
# #         print(event["transaction"])
# #         print("-" * 80)
# #         time.sleep(1)
      
# def run_event_generator():
#     while True:
#         event = run_simulation()
#         print(format_event(event))
#         time.sleep(1)


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