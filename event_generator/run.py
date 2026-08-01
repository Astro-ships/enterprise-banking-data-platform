from event_generator.controller import run_simulation
def main():
    result=run_simulation()

    print(result["customer"])
    print(result["account"])
    print(result["merchant"])
    print(result["transaction"])

if __name__=="__main__":
    main()