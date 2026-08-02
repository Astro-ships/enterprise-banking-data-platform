from faker import Faker 
import random
from event_generator.models.merchant import Merchant 
fake=Faker() 


MERCHANT_NAMES = [
    "Am azon",
    "Walmart",
    "Target",
    "Costco",
    "Best Buy",
    "Home Depot",
    "IKEA",
    "Macy's",
    "Kroger",
    "Whole Foods",
    "Safeway",
    "Aldi",
    "Lidl",
    "Tesco",
    "Carrefour",
    "Metro",
    "McDonald's",
    "KFC",
    "Burger King",
    "Subway",
    "Pizza Hut",
    "Domino's",
    "Starbucks",
    "Dunkin'",
    "Costa Coffee",
    "eBay",
    "AliExpress",
    "Etsy",
    "Temu",
    "Daraz",
    "Noon",
    "Uber",
    "Careem",
    "Lyft",
    "Bolt",
    "Shell",
    "BP",
    "Chevron",
    "ExxonMobil",
    "TotalEnergies",
    "PSO",
    "Attock Petroleum",
    "Marriott",
    "Hilton",
    "Hyatt",
    "Holiday Inn",
    "Emirates",
    "Qatar Airways",
    "PIA",
    "Turkish Airlines",
    "Etihad",
    "Netflix",
    "Spotify",
    "Steam",
    "PlayStation Store",
    "Xbox Store",
    "Apple App Store",
    "Google Play",
    "AT&T",
    "Verizon",
    "T-Mobile",
    "Jazz",
    "Zong",
    "Ufone",
    "Telenor",
    "Electric Company",
    "Water Authority",
    "Gas Company",
    "Internet Provider",
    "CVS Pharmacy",
    "Walgreens",
    "Boots",
    "Nike",
    "Adidas",
    "H&M",
    "Zara",
    "Uniqlo",
    "Apple Store",
    "Samsung Store",
    "Dell",
    "Lenovo",
    "City Pharmacy",
    "Fresh Mart",
    "Tech World",
    "Book Corner",
    "Coffee House",
    "Fashion Hub",
     "Amazon",
    "amazon",
    " AMAZON ",
    "Amazon.com",
    "AMZN",

    "Walmart",
    "walmart",
    " WALMART ",
    "Wal-Mart",

    "Target",
    "TARGET",
    " target ",

    "Costco",
    "COSTCO",
    "Cost Co",

    "Best Buy",
    "BestBuy",
    "BEST BUY",

    "Home Depot",
    "HOME DEPOT",

    "McDonald's",
    "McDonalds",
    "Mc Donald's",
    "MCDONALDS",

    "Starbucks",
    "STARBUCKS",
    "Star bucks",

    "KFC",
    "kfc",
    "K.F.C.",

    "Burger King",
    "burger king",
    "BURGER KING",

    "Pizza Hut",
    "PIZZA HUT",
    "PizzaHut",

    "Domino's",
    "Dominos",
    "DOMINO'S",

    "Shell",
    "SHELL",
    "Shell Petrol",

    "PSO",
    "Pakistan State Oil",
    "pso",

    "Uber",
    "UBER",
    "Uber Eats",

    "Careem",
    "CAREEM",
    "Careem Ride",

    "Netflix",
    "NETFLIX",
    "Netflix Inc.",

    "Spotify",
    "SPOTIFY",

    "Steam",
    "STEAM",
    "Steam Store",

    "Apple Store",
    "APPLE STORE",
    "Apple",

    "Samsung Store",
    "Samsung",

    "Daraz",
    "DARAZ",
    "Daraz.pk",

    "AliExpress",
    "ALIEXPRESS",

    "eBay",
    "EBAY",
    "E-bay",

    "Tesco",
    "TESCO",

    "Carrefour",
    "CARREFOUR",

    "Nike",
    "NIKE",

    "Adidas",
    "ADIDAS",

    "H&M",
    "H and M",
    "H&M Store",

    "Zara",
    "ZARA",

    "CVS Pharmacy",
    "CVS",
    "CVS PHARMACY",

    "Walgreens",
    "WALGREENS",

    "Fresh Mart",
    "FreshMart",
    " fresh mart ",

    "Coffee House",
    "COFFEE HOUSE",
    "CoffeeHouse",

    "Tech World",
    "TECH WORLD",
    "TechWorld",

    "Book Corner",
    "BOOK CORNER",

    "Fashion Hub",
    "fashion hub"
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

