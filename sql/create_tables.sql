CREATE TABLE clients (
    client_id INTEGER PRIMARY KEY,
    client_name VARCHAR(255),
    region VARCHAR(255)
) CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(255),
    unit_price NUMERIC(10, 2)
) CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    client_id INTEGER REFERENCES clients(client_id),
    quantity INTEGER,
    sale_date DATE
)