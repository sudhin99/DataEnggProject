USE RELIANT_DWH_GOLD;

CREATE OR REPLACE VIEW VW_STORE_PERFORMANCE AS
SELECT
    s.store_id,
    s.store_name,
    s.city,
    s.state,
    st.country_name,
    s.store_type,
    s.store_area_sqft,
    s.store_age_years,
    COUNT(f.order_id)           AS total_orders,
    SUM(f.revenue)              AS total_revenue,
    ROUND(AVG(f.revenue), 2)    AS avg_order_value,
    SUM(f.quantity)             AS total_units_sold
FROM FACT_SALES f
JOIN DIM_STORE s          ON f.store_key = s.store_key
LEFT JOIN DIM_STATE st    ON s.state = st.state_code
GROUP BY 
    s.store_id, 
    s.store_name, 
    s.city, 
    s.state, 
    st.country_name, 
    s.store_type, 
    s.store_area_sqft, 
    s.store_age_years;
