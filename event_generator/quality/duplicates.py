
# ==========================================
# duplicates.py
# ==========================================
# Purpose:
# Intentionally inject duplicate records into
# generated datasets.
#
# These duplicates simulate common data quality
# issues found in operational source systems.
#
# NOTE:
# This module DOES NOT detect or remove duplicates.
# It only creates them.
# ==========================================

import random
import copy


# ==========================================
# Customer Duplicate Injection
# ==========================================
# Randomly duplicates existing customer records.
#
# Example:
# Customer A
# Customer B
#
# ↓
#
# Customer A
# Customer B
# Customer A
# ==========================================

def inject_duplicate_customers(customers, duplicate_rate=0.02):
    """
    Randomly duplicate customer records.

    duplicate_rate = 0.02 means roughly 2%
    of the customer dataset will be duplicated.
    """

    # Calculate how many duplicate records
    # should be injected.
    number_of_duplicates = int(len(customers) * duplicate_rate)

    # Randomly select customers and append
    # deep copies back into the collection.
    for _ in range(number_of_duplicates):
        duplicate = copy.deepcopy(random.choice(customers))
        customers.append(duplicate)

    return customers


# ==========================================
# Account Duplicate Injection
# ==========================================
# Randomly duplicates existing account records.
#
# These duplicate accounts will later be
# identified and handled in the Silver layer.
# ==========================================

def inject_duplicate_accounts(accounts, duplicate_rate=0.01):
    """
    Randomly duplicate account records.

    duplicate_rate = 0.01 means roughly 1%
    of the account dataset will be duplicated.
    """

    # Calculate number of duplicates to create.
    number_of_duplicates = int(len(accounts) * duplicate_rate)

    # Randomly copy existing accounts and
    # append them back into the collection.
    for _ in range(number_of_duplicates):
        duplicate = copy.deepcopy(random.choice(accounts))
        accounts.append(duplicate)

    return accounts
