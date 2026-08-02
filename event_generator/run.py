# ==========================================================
# Enterprise Banking Data Platform
# Main Application Entry Point
# ==========================================================
# This file orchestrates the complete data generation workflow.
# It generates the banking entities in the correct order and
# exports them as NDJSON files for Snowflake ingestion.

from event_generator.controller import (
    generate_customers,
    generate_accounts,
    generate_merchants,
    generate_transactions
)

from event_generator.writers.ndjson_writer import write_ndjson


def main():

    # ==========================================================
    # Generate Master Data
    # ==========================================================
    # Generate the core business entities required by the banking
    # platform before any transactions can occur.

    customers = generate_customers(1)

    accounts = generate_accounts(customers)

    merchants = generate_merchants(1)


    # ==========================================================
    # Generate Transaction History
    # ==========================================================
    # Generate realistic banking transactions using the previously
    # created accounts and merchants.

    transactions = generate_transactions(
        accounts,
        merchants,
        1
    )


    # ====================================
    #  Testings 
    # ===================================
    print(f"Customers: {len(customers):,}")
    print(f"Accounts: {len(accounts):,}")
    print(f"Merchants: {len(merchants):,}")
    print(f"Transactions: {len(transactions):,}")

    # ==========================================================
    # Export Collections to NDJSON
    # ==========================================================
    # Persist each collection as newline-delimited JSON files.
    # These files will later be uploaded into a Snowflake Stage
    # and ingested into the Landing layer.

    write_ndjson("customers.ndjson", customers)

    write_ndjson("accounts.ndjson", accounts)

    write_ndjson("merchants.ndjson", merchants)

    write_ndjson("transactions.ndjson", transactions)


# ==========================================================
# Application Entry Point
# ==========================================================

if __name__ == "__main__":
    main()