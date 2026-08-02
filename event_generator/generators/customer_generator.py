from faker import Faker 
from datetime import date 
from event_generator.models.customer import Customer 
fake=Faker()

def generate_customer() -> Customer :
    customer=Customer(
        customer_id=fake.uuid4(),
        first_name=fake.first_name(),
        last_name= fake.last_name(),
        date_of_birth=fake.date_of_birth(
            minimum_age=18,
            maximum_age=80
        ),
        country=fake.country(),
        city=fake.city(),
        address = fake.street_address(),
        postal_code=fake.postcode(),
        phone_number=fake.phone_number(),
        email=fake.email(),
        customer_since=fake.date_between(start_date='-6y',
                                         end_date='today')




    )
    return customer
