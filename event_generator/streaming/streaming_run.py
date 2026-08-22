from event_generator.streaming.base_data_loader import load_base_data 
from event_generator.streaming.streaming_controller import generate_transactions
from event_generator.streaming.snowpipe_client import stream_transactions


def main():
    accounts,merchants=load_base_data() 

    transactions=generate_transactions(
        accounts,
        merchants,
        5
    )
    stream_transactions(transactions)


if __name__ == "__main__":
    main()