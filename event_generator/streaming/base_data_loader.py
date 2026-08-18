import json 
from pathlib import Path 
import gzip 

# ==========================================================
# Base Data Paths
# ==========================================================

directory= Path("data/base")

account_file=directory/"accounts.ndjson.gz"
merchant_file=directory/"merchants.ndjson.gz"

# ==========================================================
# Generic NDJSON Loader
# ==========================================================

def load_ndjson_gz(file_path):
    """
    Load a gzip-compressed ndjson file
    Each line in the file represents one Json record
    """
    records=[]

    with gzip.open(file_path,"rt",encoding="utf-8") as file:
        for line in file: 
            records.append(json.loads(line))
        return records 

# ==========================================================
# Load Base Reference Data
# ==========================================================

def load_base_data():
    """
    Load the existing accounts and merchants
    used as reference data by the streaming generator
    """
    accounts=load_ndjson_gz(account_file)
    merchants=load_ndjson_gz(merchant_file)

    return accounts,merchants

if __name__ == "__main__":
    accounts, merchants = load_base_data()

    print("Accounts:", len(accounts))
    print("Merchants:", len(merchants))

    print("\nFirst account:")
    print(accounts[0])

    print("\nFirst merchant:")
    print(merchants[0])