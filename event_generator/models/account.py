

from dataclasses import dataclass 
from datetime import date 

@dataclass 
class Account: 
    """
    Represent Bank account 
    """ 
    account_id: str
    customer_id: str
    account_number: str
    account_type: str
    currency: str
    country: str
    opening_date: date
    status: str
    balance: float
