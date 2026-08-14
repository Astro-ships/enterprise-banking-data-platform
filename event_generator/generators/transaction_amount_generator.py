# ============================
# Transaction Amount generator
# ============================
# =========================================================================
# Transaction amounts are modeled using a log-normal distribution
# because financial transaction values are positive and typically
# right-skewed. Transaction-specific upper bounds prevent the
# synthetic generator from producing implausibly large everyday
# transactions.
# =========================================================================
import random
def generate_transaction_amount(transaction_type:str)->float:

    """
    Generate a synthetic transaction amount based on transaction type.
    """
    if transaction_type == 'PURCHASE':
        return round(min(random.lognormvariate(3.9,0.8),2500),2
                     )
    elif transaction_type == "TRANSFER":
        return round(min(random.lognormvariate(7.8,1.0),2500),2)

    elif transaction_type == "ATM_WITHDRAWAL":
        return round(min(random.lognormvariate(5.3,0.7),1000),2)
    else:
        raise ValueError(
            f"Unsupported transaction type: {transaction_type}"
        )