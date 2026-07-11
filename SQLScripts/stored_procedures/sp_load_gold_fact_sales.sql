USE RELIANT_DWH_GOLD;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_load_gold_fact_sales$$

CREATE PROCEDURE sp_load_gold_fact_sales()
BEGIN
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'sp_load_gold_fact_sales';
    DECLARE v_layer VARCHAR(20) DEFAULT 'GOLD';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'GOLD.FACT_SALES';
    DECLARE v_error_msg TEXT;
    
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()), NULL, v_rows_merged, 'FAILED', v_error_msg);
    END;

    SET v_started_at = NOW();

    -- Insert/Update FACT_SALES
    INSERT INTO RELIANT_DWH_GOLD.FACT_SALES
        (order_id, date_key, product_key, customer_key, store_key, quantity, selling_price, revenue)
    SELECT
        o.order_id,
        CAST(DATE_FORMAT(o.order_date, '%Y%m%d') AS UNSIGNED) AS date_key,
        p.product_key,
        c.customer_key,
        s.store_key,
        o.quantity,
        o.selling_price,
        o.revenue
    FROM RELIANT_DWH_SILVER.SILVER_ORDERS o
    JOIN RELIANT_DWH_GOLD.DIM_PRODUCT p ON o.product_id = p.product_id
    JOIN RELIANT_DWH_GOLD.DIM_CUSTOMER c ON o.customer_id = c.customer_id
    JOIN RELIANT_DWH_GOLD.DIM_STORE s ON o.store_id = s.store_id
    ON DUPLICATE KEY UPDATE
        quantity = VALUES(quantity),
        revenue = VALUES(revenue),
        updated_at = NOW();

    SET v_rows_merged = ROW_COUNT();

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()), NULL, v_rows_merged, 'SUCCESS', NULL);

    SELECT CONCAT(v_sp_name, ': ', v_rows_merged, ' rows merged') AS result;
END$$

DELIMITER ;
