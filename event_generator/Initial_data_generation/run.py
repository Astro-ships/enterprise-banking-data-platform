# ==========================================================
# Enterprise Banking Data Platform
# Main Application Entry Point
# ==========================================================
# This file orchestrates the complete data generation workflow.
# It generates the banking entities in the correct order and
# exports them as NDJSON files for Snowflake ingestion.
import time 
from event_generator.Initial_data_generation.controller import (
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
    print("="*80)
    print("Generating customers...")
    print("="*80)
    customers = generate_customers(100000)
    
    print("Generating accounts...")
    accounts = generate_accounts(customers)
    print("="*80)
    print("Generating merchants...")
    print("="*80)
    merchants = generate_merchants(10000)



    # ==========================================================
    # Generate Transaction History
    # ==========================================================
    # Generate realistic banking transactions using the previously
    # created accounts and merchants.
    print("Generating transactions...")
    transactions = generate_transactions(
        accounts,
        merchants,
        1500000
    )


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

    print("="*100)
    print("Process Completed!")
    print("="*100)

# ==========================================================
# Application Entry Point
# ==========================================================

if __name__ == "__main__":
    main()