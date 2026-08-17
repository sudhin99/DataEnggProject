DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_GOLD.SP_LOAD_DIM_PRODUCT$$

CREATE PROCEDURE RELIANT_DWH_GOLD.SP_LOAD_DIM_PRODUCT()
BEGIN
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.SP_LOAD_DIM_PRODUCT';
    DECLARE v_layer VARCHAR(20) DEFAULT 'GOLD';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.DIM_PRODUCT';
    DECLARE v_error_msg TEXT;
    DECLARE v_watermark TIMESTAMP;
    DECLARE v_new_watermark TIMESTAMP;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_result_message VARCHAR(512);

    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()), v_watermark, v_rows_merged, 'FAILED', v_error_msg);
         
        SELECT CONCAT(v_sp_name, ': ERROR - ', v_error_msg) AS result;
    END;

    SET v_started_at = NOW();

    SELECT COALESCE(MAX(updated_at), MAX(created_at), CAST('1999-01-01 00:00:01' AS DATETIME)) 
    INTO v_watermark 
    FROM RELIANT_DWH_GOLD.DIM_PRODUCT;

    SELECT MAX(updated_at) INTO v_new_watermark FROM RELIANT_DWH_SILVER.SILVER_PRODUCTS WHERE updated_at > v_watermark;

    IF v_new_watermark IS NULL THEN
        SET v_rows_merged = 0;
        SET v_result_message = 'No new records to process in SILVER_PRODUCTS';

        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'SUCCESS', 'No new records to process');
    ELSE
        START TRANSACTION;

        INSERT INTO RELIANT_DWH_GOLD.DIM_PRODUCT (
            product_id,
            product_name,
            category,
            brand,
            purchase_price,
            mrp,
            warranty_months,
            created_at,
            updated_at
        )
        SELECT *
        FROM (
            SELECT
                product_id,
                product_name,
                category,
                brand,
                purchase_price,
                mrp,
                warranty_months,
                NOW() AS created_at,
                NOW() AS updated_at
            FROM RELIANT_DWH_SILVER.SILVER_PRODUCTS
            WHERE updated_at > v_watermark
              AND updated_at <= v_new_watermark
        ) AS src
        ON DUPLICATE KEY UPDATE
            product_name    = src.product_name,
            category        = src.category,
            brand           = src.brand,
            purchase_price  = src.purchase_price,
            mrp             = src.mrp,
            warranty_months = src.warranty_months,
            updated_at      = NOW();


    SET v_rows_merged = ROW_COUNT();

    COMMIT;

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()), v_new_watermark, v_rows_merged, 'SUCCESS', NULL);

        SET v_result_message = CONCAT(v_sp_name, ': ', v_rows_merged, ' product rows merged. Watermark was ', v_watermark);
    END IF;

    SELECT v_result_message AS result;
END$$

DELIMITER ;
