"""
MySQL Configuration for Reliant DigiTech Data Warehouse
Configure your MySQL connection details here before running the load scripts.
"""

# ==============================================================================
# MySQL Connection Configuration
# ==============================================================================
# Update these values with your MySQL server details

MYSQL_CONFIG = {
    'host': 'localhost',             # MySQL server hostname
    'port': 3306,                    # MySQL server port (default: 3306)
    'user': 'root',                    # MySQL username
    'password': 'your_password',        # MySQL password
    'charset': 'utf8mb4',
    'collation': 'utf8mb4_unicode_ci'
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
    """Create SQLAlchemy connection string for given database."""
    return (
        f"mysql+pymysql://{MYSQL_CONFIG['user']}:{MYSQL_CONFIG['password']}"
        f"@{MYSQL_CONFIG['host']}:{MYSQL_CONFIG['port']}/{database}"
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
    'google_reviews': 'STG_GOOGLE_REVIEWS',
    'date_dim': 'STG_DATE_DIM',
}
