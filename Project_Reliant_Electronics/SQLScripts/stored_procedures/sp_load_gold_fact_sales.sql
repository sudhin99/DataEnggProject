USE RELIANT_DWH_GOLD;

DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_GOLD.SP_LOAD_GOLD_FACT_SALES$$

CREATE PROCEDURE RELIANT_DWH_GOLD.SP_LOAD_GOLD_FACT_SALES()
BEGIN
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.SP_LOAD_GOLD_FACT_SALES';
    DECLARE v_layer VARCHAR(20) DEFAULT 'GOLD';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.FACT_SALES';
    DECLARE v_error_msg TEXT;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_result_message VARCHAR(512);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs,
             watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()), NULL, v_rows_merged, 'FAILED', v_error_msg);

        SELECT CONCAT(v_sp_name, ': ERROR - ', v_error_msg) AS result;
    END;

    SET v_started_at = NOW();

    START TRANSACTION;

    INSERT INTO RELIANT_DWH_GOLD.FACT_SALES (
        order_id,
        date_key,
        product_key,
        customer_key,
        store_key,
        quantity,
        selling_price,
        revenue,
        created_at,
        updated_at
    )
    SELECT *
    FROM (
        SELECT
            o.order_id,
            d.date_key,
            p.product_key,
            c.customer_key,
            s.store_key,
            o.quantity,
            o.selling_price,
            o.revenue,
            NOW() AS created_at,
            NOW() AS updated_at
        FROM RELIANT_DWH_SILVER.SILVER_ORDERS o
        JOIN RELIANT_DWH_GOLD.DIM_PRODUCT  p ON o.product_id  = p.product_id
        JOIN RELIANT_DWH_GOLD.DIM_CUSTOMER c ON o.customer_id = c.customer_id
        JOIN RELIANT_DWH_GOLD.DIM_STORE    s ON o.store_id    = s.store_id
        JOIN RELIANT_DWH_GOLD.DIM_DATE d     ON o.order_date = d.the_date
    ) AS src
    ON DUPLICATE KEY UPDATE
        quantity    = src.quantity,
        revenue     = src.revenue,
        updated_at  = NOW();

    SET v_rows_merged = ROW_COUNT();

    COMMIT;

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs,
         watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()), NULL, v_rows_merged, 'SUCCESS', NULL);

    SET v_result_message = CONCAT(v_sp_name, ': ', v_rows_merged, ' sales rows merged');

    SELECT v_result_message AS result;
END$$

DELIMITER ;
