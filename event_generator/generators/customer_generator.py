from faker import Faker
import random

from event_generator.models.customer import Customer

# ==========================================
# Faker Initialization
# ==========================================

fake = Faker()



# ==========================================
# Customer Generator
# ==========================================

def generate_customer() -> Customer:
    """
    Generate a synthetic customer record.
    """
    
    # ==========================================
    # Generate Postal Code
    # Introduce a small percentage of records
    # with missing leading zeros to simulate
    # real-world data quality issues.
    # ==========================================

    postal_code = fake.postcode()

    if (
            random.random() < 0.05
            and postal_code.startswith("0")
    ):
            postal_code = postal_code[1:]

    customer = Customer(


        # --------------------------
        # Customer Identification
        # --------------------------
        customer_id=fake.uuid4(),
        first_name=fake.first_name(),
        last_name=fake.last_name(),

        # --------------------------
        # Personal Information
        # --------------------------
        date_of_birth=fake.date_of_birth(
            minimum_age=18,
            maximum_age=80
        ),

        # --------------------------
        # Contact Information
        # --------------------------
        country=fake.country(),
        city=fake.city(),
        address=fake.street_address(),
        postal_code=postal_code,
        phone_number=fake.phone_number(),
        email=fake.email(),

        # --------------------------
        # Banking Metadata
        # --------------------------
        customer_since=fake.date_between(
            start_date="-6y",
            end_date="today"
        )

    )

    return customer