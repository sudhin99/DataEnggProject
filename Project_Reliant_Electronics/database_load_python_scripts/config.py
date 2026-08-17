"""
MySQL Configuration for Reliant DigiTech Data Warehouse
Configure your MySQL connection details here before running the load scripts.
"""

from sqlalchemy.engine import URL

# ==============================================================================
# MySQL Connection Configuration
# ==============================================================================
# Update these values with your MySQL server details

MYSQL_CONFIG = {
    'host': 'localhost',             # MySQL server hostname
    'port': 3306,                    # MySQL server port (default: 3306)
    'user': 'root',                    # MySQL username
    'password': 'MyNewPass@1'       # MySQL password
}

# ==============================================================================
# Database Names
# ==============================================================================
DATABASE_BRONZE = 'RELIANT_DWH_BRONZE'
DATABASE_SILVER = 'RELIANT_DWH_SILVER'
DATABASE_GOLD = 'RELIANT_DWH_GOLD'

# ==============================================================================
# Helper Functions
# ==============================================================================
def get_connection_string(database):
    """Create a safe SQLAlchemy connection URL for the requested database."""
    return URL.create(
        "mysql+pymysql",
        username=MYSQL_CONFIG['user'],
        password=MYSQL_CONFIG['password'],
        host=MYSQL_CONFIG['host'],
        port=MYSQL_CONFIG['port'],
        database=database,
    )

# ==============================================================================
# File to Table Mapping
# ==============================================================================
# Maps filename prefixes to their target staging tables
FILE_TABLE_MAP = {
    'orders': 'STG_ORDERS',
    'products': 'STG_PRODUCTS',
    'customers': 'STG_CUSTOMERS',
    'store_details': 'STG_STORES',
    'inventory': 'STG_INVENTORY',
    'customer_feedback': 'STG_FEEDBACK',
    'google_reviews': 'STG_REVIEWS',
    'date_dim': 'STG_DATE_DIM',
}
