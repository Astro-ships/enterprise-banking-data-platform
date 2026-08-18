from event_generator.streaming.base_data_loader import load_base_data
from event_generator.streaming.controller import generate_transactions
from api.test_client import send_transaction
def main():
    accounts,merchants=load_base_data() 
    transactions=generate_transactions(accounts,merchants,5)
    for transaction in transactions:
        response=send_transaction(transaction)
        print(response.json())


if __name__ == "__main__":
    main()