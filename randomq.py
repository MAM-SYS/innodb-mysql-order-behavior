import mysql.connector
import random

# MySQL database configuration
config = {
    'user': 'root',
    'password': 'rootpassword',
    'host': '127.0.0.1',
    'database': 'test_db',
    'raise_on_warnings': True
}

def execute_query(query, params=None):
    cursor.execute(query, params or ())
    return cursor.fetchall()

try:
    conn = mysql.connector.connect(**config)
    cursor = conn.cursor()

    # Step 1: Randomly query 1000 rows with different start and end
    limit_5_results = []

    for i in range(1000):  # Perform 1000 iterations to cover different ranges
        start_id = random.randint(1, 2000000000)
        end_id = start_id + 999
        query = "SELECT * FROM test_table WHERE id BETWEEN %s AND %s"
        results = execute_query(query, (start_id, end_id))
        print(f"Iteration {i+1}: Queried rows between {start_id} and {end_id}, got {len(results)} rows.")

        # Step 2: Query with LIMIT 5 after populating the buffer pool
        final_query = "SELECT * FROM test_table LIMIT 5"
        final_results = execute_query(final_query)
        limit_5_results.append([row[0] for row in final_results])  # Store the IDs of the LIMIT 5 results

    # Step 3: Compare sequences of returned IDs
    print("\nSequences of IDs returned by SELECT * FROM test_table LIMIT 5:")
    for i, result in enumerate(limit_5_results):
        print(f"Iteration {i+1}: {result}")

    # Check if the sequences are different
    sequences_are_different = any(result != limit_5_results[0] for result in limit_5_results)
    if sequences_are_different:
        print("\nThe sequences of returned IDs changed between iterations.")
    else:
        print("\nThe sequences of returned IDs remained consistent across all iterations.")

except mysql.connector.Error as err:
    print(f"Error: {err}")
finally:
    if 'cursor' in locals() and cursor:
        cursor.close()
    if 'conn' in locals() and conn:
        conn.close()
    print("MySQL connection is closed.")
