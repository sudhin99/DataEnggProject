-- 03_time_series_analysis.sql
-- Explore theft patterns over time.

SELECT
    YEAR(sv.date_stolen) AS theft_year,
    MONTH(sv.date_stolen) AS theft_month,
    MONTHNAME(sv.date_stolen) AS month_name,
    DAYNAME(sv.date_stolen) AS theft_weekday,
    COUNT(*) AS theft_count
FROM stolen_vehicles AS sv
WHERE sv.date_stolen IS NOT NULL
GROUP BY
    YEAR(sv.date_stolen),
    MONTH(sv.date_stolen),
    MONTHNAME(sv.date_stolen),
    DAYNAME(sv.date_stolen)
ORDER BY theft_year, theft_month, theft_weekday;
