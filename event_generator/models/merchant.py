from dataclasses import dataclass 
from datetime import date 
@dataclass 
class Merchant:
    merchant_id: str
    merchant_name: str
    country: str
    city: str