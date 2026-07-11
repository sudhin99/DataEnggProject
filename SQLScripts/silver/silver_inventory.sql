USE RELIANT_DWH_SILVER;

DROP TABLE IF EXISTS SILVER_INVENTORY;

CREATE TABLE SILVER_INVENTORY (
    store_id       INT,
    product_id     INT,
    quantity       INT,
    closing_stock  INT,
    opening_stock  INT,
    inventory_date DATE,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (store_id, product_id, inventory_date)
);
