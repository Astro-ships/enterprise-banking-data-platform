import random
from faker import Faker

from event_generator.models.account import Account

fake = Faker()


def generate_account(customer_id: str) -> Account:
    """
    Generate a bank account with intentionally inconsistent
    data for the Bronze layer.
    """

    status = random.choice(
        [
            "ACTIVE",
            "Active",
            "active",
            "Act",
            "ACT",

            "DORMANT",
            "Dormant",
            "dormant",

            "CLOSED",
            "Closed",
            "closed",

            "FROZEN",
            "Frozen",
            "frozen",

            "Non-Active",
            "non-active",

            None
        ]
    )

    if status in [
        "ACTIVE",
        "Active",
        "active",
        "Act",
        "ACT"
    ]:
        balance = round(random.uniform(100, 100000), 2)

    elif status in [
        "DORMANT",
        "Dormant",
        "dormant"
    ]:
        balance = round(random.uniform(0, 50000), 2)

    else:
        balance = 0.0

    account = Account(

        account_id=fake.uuid4(),

        customer_id=customer_id,

        account_number=random.choice(
            [
                fake.bban(),
                fake.iban(),
                fake.bban().replace("-", ""),
                fake.bban().replace(" ", ""),
            ]
        ),
        account_type=random.choice(
            [
                "Savings",
                "saving",
                "SAVINGS",
                "Current",
                "current",
                "CURRENT",
                "CUrentg",
                "curreng",
                "Current",
                "business",
                "Loan",
                None
            ]
        ),
        currency=random.choice(
            [
                "USD",
                "usd",
                "US Dollar",
                "U.S. Dollar",
                "PKR",
                "pkr",
                "Pakistani Rupee",
                "Pak Rupee",
                "GBP",
                "gbp",
                "British Pound",
                "INR",
                "Indian Rupee",
                "MYR",
                "Malaysian Ringgit",
                None
            ]
        ),
        country=random.choice(
            [
                "Pakistan",
                "pakistan",
                "PAKISTAN",
                "United States",
                "USA",
                "US",
                "America",
                "United Kingdom",
                "UK",
                "Britain",
                "Malaysia",
                "India",
                fake.country(),
                None
            ]
        ),
        opening_date=fake.date_between(
            start_date="-10y",
            end_date="today"
        ),
        status=status,
        balance=balance
    )
    return account