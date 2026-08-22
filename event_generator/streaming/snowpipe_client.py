import os
from dataclasses import asdict
from dotenv import load_dotenv
from snowflake.ingest.streaming import StreamingIngestClient


load_dotenv()


def stream_transactions(transactions):

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
    # 3. Append transactions to the channel
    # ---------------------------------------------------------

    for transaction in transactions:

        print(
            f"Appending transaction: "
            f"{transaction.transaction_id}"
        )

        channel.append_row(
            {"PAYLOAD": asdict(transaction)},
            transaction.transaction_id
        )

        print("=" * 100)
        print("Transaction append successful")
        print("=" * 100)

    # ---------------------------------------------------------
    # 4. Wait for Snowflake to flush the channel
    # ---------------------------------------------------------

    print("Waiting for Snowflake to flush the channel...")

    channel.wait_for_flush()

    print("Channel flushed successfully")

    # ---------------------------------------------------------
    # 5. Ask Snowflake what happened
    # ---------------------------------------------------------

    status = channel.get_channel_status()

    print()
    print("========== CHANNEL STATUS ==========")
    print("Channel:", status.channel_name)
    print("Status:", status.status_code)
    print("====================================")

    # ---------------------------------------------------------
    # 6. Close cleanly
    # ---------------------------------------------------------

    channel.close()
    client.close()

    print("=" * 100)
    print("ENDING SESSION")