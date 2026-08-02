from event_generator.controller import  generate_customers

def main():
    customers= generate_customers(20000)
    for customer in customers:
        print(customer)
if __name__=="__main__":
    main()