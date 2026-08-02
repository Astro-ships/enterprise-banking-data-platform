from dataclasses import dataclass 
from datetime import date 
@dataclass 
class Merchant:
    merchant_id: str
    merchant_name: str
    merchant_type: str
    country: str
    city: str