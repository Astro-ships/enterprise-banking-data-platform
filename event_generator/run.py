from event_generator.controller import  generate_customers, generate_accounts


def main():
    customers= generate_customers(20000)   
    accounts=generate_accounts(customers)

    print(f"Customers: {len(customers)}")
    print(f"Accounts: {len(accounts)}")

    # print("\nFirst 5 Customers")
    # for customer in customers[:5]:
    #     print(customer)

    # print("\nFirst 5 Accounts")
    # for account in accounts[:5]:
    #     print(account)

if __name__=="__main__":
    main()