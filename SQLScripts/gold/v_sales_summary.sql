USE RELIANT_DWH_GOLD;

CREATE OR REPLACE VIEW VW_SALES_SUMMARY AS
SELECT
    d.the_date,
    d.year,
    d.month_name,
    d.quarter,
    d.day_of_week,
    d.is_weekend,
    s.store_name,
    s.city AS store_city,
    s.store_type,
    p.product_name,
    p.category,
    p.brand,
    c.customer_name,
    c.city AS customer_city,
    c.gender,
    f.quantity,
    f.selling_price,
    f.revenue
FROM FACT_SALES f
JOIN DIM_DATE d     ON f.date_key = d.date_key
JOIN DIM_PRODUCT p  ON f.product_key = p.product_key
JOIN DIM_CUSTOMER c ON f.customer_key = c.customer_key
JOIN DIM_STORE s    ON f.store_key = s.store_key;
