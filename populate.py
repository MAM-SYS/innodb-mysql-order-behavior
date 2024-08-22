from datetime import datetime
import mysql.connector
from mysql.connector import errorcode
import random

# MySQL database configuration
config = {
    'user': 'root',
    'password': 'rootpassword',
    'host': '127.0.0.1',
    'database': 'test_db',
    'raise_on_warnings': True
}

# Establish a connection to the database
try:
    conn = mysql.connector.connect(**config)
    cursor = conn.cursor()

    # Step 1: Create the table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS test_table (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            created_at DATETIME NOT NULL,
            updated_at DATETIME NOT NULL
        )
    """)
    print("Table 'test_table' created successfully.")

    # Step 2: Insert 2 billion records in batches
    batch_size = 10000  # Commit every 10,000 records
    total_records = 2000000000  # Total records to insert
    current_time = str(datetime.now())

    for batch_start in range(0, total_records, batch_size):
        insert_query = "INSERT INTO test_table (created_at, updated_at) VALUES (%s, %s)"
        records = [(current_time, current_time) for _ in range(batch_size)]
        cursor.executemany(insert_query, records)
        conn.commit()
        print(f"Inserted {batch_start + batch_size} records so far...")

    print("Finished inserting 2 billion records.")

    # Step 3: Randomly delete 10,000 records
    delete_query = """
    DELETE FROM test_table
    WHERE id IN (
        SELECT id FROM (
            SELECT id FROM test_table
            ORDER BY RAND()
            LIMIT 10000
        ) AS temp_table
    )
    """
    cursor.execute(delete_query)
    conn.commit()
    print("Deleted 10,000 random records.")

except mysql.connector.Error as err:
    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Something is wrong with your user name or password")
    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist")
    else:
        print(err)
finally:
    cursor.close()
    conn.close()
    print("MySQL connection is closed.")
