from dataclasses import dataclass 
from datetime import datetime

@dataclass 
class Transactions:
    """
    Represents bankning transaction event
    """
    transaction_id: str
    source_account_id: str 
    destination_account_id: str | None 
    merchant_id: str | None 
    amount: float 
    currency: str 
    transaction_type : str 
    transaction_timestamp: datetime
    status: str
     


