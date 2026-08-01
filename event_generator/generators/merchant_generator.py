from faker import Faker 
import random
from event_generator.models.merchant import Merchant 
fake=Faker() 



MERCHANT_NAMES = [
    "AmaZon",
    "StarBUcks",
    "Shell",
    "Costco",
    "Walmart",
    "McDonald's",
    "KFC",
    "CHeezious",
    "Uber",
    "CAreeM",
    " careem",
    "PepSico",
    "pepsico",
]

def generate_merchant()-> Merchant:
    """
    Defining Merchant
    """

    merchant=Merchant(
        merchant_id =fake.uuid4(),
        merchant_name=random.choice(MERCHANT_NAMES),
        country=fake.country(),
        city=fake.city()
        )
    return merchant

