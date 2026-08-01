def format_event(event):

    customer = event["customer"]
    account = event["account"]
    merchant = event["merchant"]
    transaction = event["transaction"]

    return f"""
================================================================================
Transaction Event
================================================================================
Time        : {transaction.transaction_timestamp}

Customer    : {customer.first_name} {customer.last_name}
Customer ID : {customer.customer_id}

Account     : {account.account_number}
Account ID  : {account.account_id}

Merchant    : {merchant.merchant_name}
Location    : {merchant.city}, {merchant.country}

Type        : {transaction.transaction_type}
Amount      : {transaction.amount} {transaction.currency}
Status      : {transaction.status}

================================================================================
"""