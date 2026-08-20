from dotenv import load_dotenv
import os 
import getpass 
import snowflake.connector 

load_dotenv() 

def main(): 
    private_key_path=os.getenv("SNOWFLAKE_PRIVATE_KEY_PATH")
    passphrase=getpass.getpass("Enter your passphrase to proceed further: ")
    connection=snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),

        private_key_file=private_key_path,
        private_key_file_pwd=passphrase,

        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA"),
        role=os.getenv("SNOWFLAKE_ROLE"),  
    )

    cursor=connection.cursor()
    try:
       
        cursor.execute("SELECT CURRENT_ROLE()")
        role = cursor.fetchone()[0]

        cursor.execute("SELECT CURRENT_DATABASE()")
        database = cursor.fetchone()[0]

        cursor.execute("SELECT CURRENT_SCHEMA()")
        schema = cursor.fetchone()[0]

        print("Role:", role)
        print("Database:", database)
        print("Schema:", schema)

    finally:
        cursor.close()
        connection.close()

if __name__ == "__main__":
    main()
        