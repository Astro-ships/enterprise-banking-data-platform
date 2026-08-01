from faker import Faker 
import random
from event_generator.models.merchant import Merchant 
fake=Faker() 

def generate_merchant()-> Merchant:
    """
    Defining Merchant
    """
    merchant=Merchant(
        merchant_id =fake.uuid4(),
        merchant_name=random.choice(["AmaZon","StarBUcks","Shell","Costco","Walmart","McDOnals","KFC","CHeezious","Uber","CAreeM", " careem"," PepSico","pepsico"]),
        city=fake.city()
        )
    return merchant

