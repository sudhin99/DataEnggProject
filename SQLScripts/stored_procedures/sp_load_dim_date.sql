DELIMITER $$

DROP PROCEDURE IF EXISTS sp_load_dim_date$$

CREATE PROCEDURE sp_load_dim_date()
BEGIN
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'sp_load_dim_date';
    DECLARE v_layer VARCHAR(20) DEFAULT 'GOLD';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.DIM_DATE';
    DECLARE v_error_msg TEXT;
    DECLARE v_max_date DATE;
    DECLARE v_rows INT DEFAULT 0;

    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()), v_max_date, v_rows, 'FAILED', v_error_msg);
    END;

    SET v_started_at = NOW();

    SELECT COALESCE(MAX(the_date), '1900-01-01') INTO v_max_date FROM RELIANT_DWH_GOLD.DIM_DATE;

    INSERT INTO RELIANT_DWH_GOLD.DIM_DATE
        (the_date, year, quarter, month, month_name, day, day_of_week, is_weekend, created_at, updated_at)
    SELECT DISTINCT
        d AS the_date,
        YEAR(d) AS year,
        QUARTER(d) AS quarter,
        MONTH(d) AS month,
        MONTHNAME(d) AS month_name,
        DAY(d) AS day,
        DAYOFWEEK(d) AS day_of_week,
        CASE WHEN DAYOFWEEK(d) IN (1,7) THEN 1 ELSE 0 END AS is_weekend,
        NOW(), NOW()
    FROM (
        SELECT order_date AS d FROM RELIANT_DWH_SILVER.SILVER_ORDERS
        UNION
        SELECT inventory_date FROM RELIANT_DWH_SILVER.SILVER_INVENTORY
        UNION
        SELECT feedback_date FROM RELIANT_DWH_SILVER.SILVER_FEEDBACK
        UNION
        SELECT review_date FROM RELIANT_DWH_SILVER.SILVER_REVIEWS
    ) src
    WHERE d IS NOT NULL AND d > v_max_date
    ON DUPLICATE KEY UPDATE
        year = VALUES(year),
        quarter = VALUES(quarter),
        month = VALUES(month),
        month_name = VALUES(month_name),
        day = VALUES(day),
        day_of_week = VALUES(day_of_week),
        is_weekend = VALUES(is_weekend),
        updated_at = NOW();

    SET v_rows = ROW_COUNT();

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()), v_max_date, v_rows, 'SUCCESS', NULL);

    SELECT CONCAT(v_sp_name, ': ', v_rows, ' date rows upserted. Max source date used=', v_max_date) AS result;
END$$

DELIMITER ;