USE RELIANT_DWH_GOLD;

CREATE OR REPLACE VIEW VW_PRODUCT_PERFORMANCE AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.selling_price,
    p.profit_margin,
    COUNT(f.order_id)   AS total_orders,
    SUM(f.quantity)     AS total_units_sold,
    SUM(f.revenue)      AS total_revenue
FROM FACT_SALES f
JOIN DIM_PRODUCT p ON f.product_key = p.product_key
GROUP BY 
    p.product_id, 
    p.product_name, 
    p.category, 
    p.brand, 
    p.selling_price, 
    p.profit_margin;
