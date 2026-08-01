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

    )
    return customer
