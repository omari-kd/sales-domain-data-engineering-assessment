# Sales Domain Data Engineering Assessment

This project is a data engineering assessment focused on the sales domain. It demonstrates the process of loading sales data into a database, creating tables, and running analytical queries.

## Project Structure

- `data/`: Contains CSV files with sales data
  - `clients.csv`: Client information
  - `products.csv`: Product details
  - `sales.csv`: Sales transactions
- `db/`: Database files (e.g., SQLite database)
- `pipeline/`: Data pipeline scripts
  - `load_data.py`: Python script to load data into the database
- `sql/`: SQL scripts
  - `create_tables.sql`: SQL to create database tables
  - `queries.sql`: Analytical queries

## Prerequisites

- Python 3.x
- SQLite (or your preferred database)
- Required Python packages (install via `pip install -r requirements.txt` if available)

## Setup

1. Clone the repository:

   ```
   git clone <repository-url>
   cd assessment
   ```

2. Install dependencies (if requirements.txt exists):

   ```
   pip install -r requirements.txt
   ```

3. Run the table creation script:
   ```
   sqlite3 sales.db < sql/create_tables.sql
   ```
   (Adjust for your database system)

## Usage

1. Load the data into the database:

   ```
   python pipeline/load_data.py
   ```

2. Run queries:
   ```
   sqlite3 sales.db < sql/queries.sql
   ```

## Contributing

Feel free to submit issues and pull requests.

## License

This project is for assessment purposes.
