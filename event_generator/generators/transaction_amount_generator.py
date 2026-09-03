# ============================
# Transaction Amount Generator
# ============================

# =========================================================================
# Normal transaction amounts are modeled using log-normal distributions
# because financial transaction values are positive and typically
# right-skewed.
#
# 3% of transactions are deliberately generated as suspicious
# high-value transactions for Snowflake Alert testing.
# =========================================================================

import random


def generate_transaction_amount(transaction_type: str) -> float:
    """
    Generate a synthetic transaction amount based on transaction type.

    Approximately 3% of transactions are generated with a suspicious
    high-value amount for alert testing.
    """

    # 3% chance of generating a suspicious transaction
    if random.random() < 0.03:
        return round(random.uniform(100000, 200000), 2)

    if transaction_type == "PURCHASE":
        return round(
            min(random.lognormvariate(3.9, 0.8), 2500),
            2
        )

    elif transaction_type == "TRANSFER":
        return round(
            min(random.lognormvariate(7.8, 1.0), 2500),
            2
        )

    elif transaction_type == "ATM_WITHDRAWAL":
        return round(
            min(random.lognormvariate(5.3, 0.7), 1000),
            2
        )

    else:
        raise ValueError(
            f"Unsupported transaction type: {transaction_type}"
        )