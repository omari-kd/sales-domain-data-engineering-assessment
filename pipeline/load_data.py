import pandas as pd
import psycopg2
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# File  paths
clients_csv = os.path.join(BASE_DIR, "..", "data", "clients.csv")
products_csv = os.path.join(BASE_DIR, "..", "data", "products.csv")
sales_csv = os.path.join(BASE_DIR, "..", "data","sales.csv")


# PostgreSQL Connection
conn = psycopg2.connect (
    host="localhost",
    port=5432,
    database="sales_db",
    user='postgres',
    password='ben/junior'
)

cur = conn.cursor()


# 1. Create tables 
create_tables_sql = """
CREATE TABLE IF NOT EXISTS clients (
    client_id     INTEGER PRIMARY KEY,
    client_name   VARCHAR(255),
    region        VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS products (
    product_id    INTEGER PRIMARY KEY,
    product_name  VARCHAR(255),
    category      VARCHAR(255),
    unit_price    NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS sales (
    sale_id     INTEGER PRIMARY KEY,
    product_id  INTEGER REFERENCES products(product_id),
    client_id   INTEGER REFERENCES clients(client_id),
    quantity    INTEGER,
    sale_date   DATE
);
"""

cur.execute(create_tables_sql)
conn.commit()

# 2. Load CSVs
clients = pd.read_csv(clients_csv) 
products = pd.read_csv(products_csv)
sales = pd.read_csv(sales_csv)

# 3. Insert data
def insert_dataframe(df, table):
    cols = ",".join(df.columns)
    placeholders = ",".join(["%s"] * len(df.columns))

    for _, row in df.iterrows():
        cur.execute(
            f"INSERT INTO {table} ({cols}) VALUES ({placeholders}) ON CONFLICT DO NOTHING", tuple(row)
        )
    
    conn.commit()

insert_dataframe(clients, "clients")
insert_dataframe(products, "products")
insert_dataframe(sales, "sales")

cur.close()
conn.close()

print("Data loaded successfully")