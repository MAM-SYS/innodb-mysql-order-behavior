# MySQL Large Data Operations and Buffer Pool Analysis

This repository contains Python scripts designed to interact with a MySQL database, particularly focusing on populating the buffer pool with random data and observing changes in query results. The scripts cover the following tasks:

 - Limit MySQL buffer_pool_size to 5242880
 - Populating a MySQL Table with 2 Billion Records
 - Randomly Querying 1000 Rows to Populate the Buffer Pool
 - Analyzing the Consistency of LIMIT 5 Query Results

Before running the scripts, ensure that you have the following installed:

 - Python 3.x
 - MySQL Server (version 8.0 or higher)
 - Docker (for running MySQL in a container, if needed)

Python Packages:
 - mysql-connector-python

You can install the required Python package using:
```bash
poetry install
```

Setup:

1. Setting Up MySQL Using Docker
```bash
docker compose up -d
```
2. Configuring MySQL User Authentication
If you encounter the error Authentication plugin 'caching_sha2_password' is not supported, modify the MySQL user's authentication plugin:
```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';
FLUSH PRIVILEGES;
```
3. Creating the Table and Populating with 2 Billion Records
Run the Python script to create the table and populate it with 2 billion records:
```python
python3 populate.py
```
4. Random Query Execution and Buffer Pool Analysis
```python
pytho3 randomq.py
```
# Observations

Buffer Pool Effects: The consistency of the LIMIT 5 query results will help determine whether changes in the buffer pool affect query results.
Result Consistency: If the LIMIT 5 query returns different sequences after different random queries, it suggests that the buffer pool or some other factors might be influencing the order of results.
 
# Conclusion

This set of scripts allows for the examination of how large datasets interact with MySQL's buffer pool, potentially revealing insights into query performance and data retrieval consistency in a heavily loaded database environment.