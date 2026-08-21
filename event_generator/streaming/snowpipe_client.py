import os

from dotenv import load_dotenv
from snowflake.ingest.streaming import StreamingIngestClient


load_dotenv()


def main():

    # ---------------------------------------------------------
    # 1. Create Snowpipe Streaming client
    # ---------------------------------------------------------

    client = StreamingIngestClient(
        client_name="enterprise_banking_stream",
        db_name=os.getenv("SNOWFLAKE_DATABASE"),
        schema_name=os.getenv("SNOWFLAKE_SCHEMA"),
        pipe_name="TRANSACTION_PIPE",
        properties={
            "authorization_type": "JWT",
            "url": os.getenv("SNOWFLAKE_URL"),
            "account": os.getenv("SNOWFLAKE_ACCOUNT"),
            "user": os.getenv("SNOWFLAKE_USER"),
            "private_key_file": os.getenv("SNOWFLAKE_PRIVATE_KEY_PATH"),
            "private_key_passphrase": os.getenv(
                "SNOWFLAKE_PRIVATE_KEY_PASSPHRASE"
            ),
            "role": os.getenv("SNOWFLAKE_ROLE"),
        },
    )

    print("Streaming client created successfully")


    # ---------------------------------------------------------
    # 2. Open a streaming channel
    # ---------------------------------------------------------

    channel, status = client.open_channel(
        "TRANSACTION_CHANNEL"
    )

    print("Channel:", status.channel_name)
    print("Initial status:", status.status_code)


    # ---------------------------------------------------------
    # 3. Create ONE test transaction
    # ---------------------------------------------------------

    test_transaction = {
        "PAYLOAD": {
            "TRANSACTION_ID": "TXN_TEST_001",
            "CUSTOMER_ID": "CUST-001",
            "AMOUNT": 50000.00,
            "TRANSACTION_TYPE": "TRANSFER",
        }
    }


    # ---------------------------------------------------------
    # 4. Append the row to the channel
    # ---------------------------------------------------------

    print("Appending transaction...")

    channel.append_row(
        test_transaction,
        "TXN_TEST_001"
    )

    print("Transaction appended successfully")


    # ---------------------------------------------------------
    # 5. Flush the channel
    # ---------------------------------------------------------

    print("Waiting for Snowflake to flush the channel...")

    channel.wait_for_flush()

    print("Channel flushed successfully")   

    # ---------------------------------------------------------
    # 6. Ask Snowflake what happened
    # ---------------------------------------------------------

    status = channel.get_channel_status()

    print()
    print("========== CHANNEL STATUS ==========")
    print("Channel:", status.channel_name)
    print("Status:", status.status_code)
    print("====================================")


    # ---------------------------------------------------------
    # 7. Close cleanly
    # ---------------------------------------------------------

    channel.close()
    client.close()


    print("="*60)
    print("ENDING SESSION")

if __name__ == "__main__":
    main()