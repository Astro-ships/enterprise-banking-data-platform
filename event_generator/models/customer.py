
# ==============================================================
# Creating a blueprint into which data will be stored as objects 
# ==============================================================
from dataclasses import dataclass      # Imports the dataclass decorator.
from datetime import date              # Imports the date class for storing dates.


@dataclass                             # Tells Python to automatically generate
                                       # common methods like __init__() for this class.
class Customer:
    customer_id: str
    first_name: str
    last_name: str
    date_of_birth: date
    country: str
    city: str
    address: str 
    postal_code: str 
    email : str 
    phone_number : str 
    customer_since : date 