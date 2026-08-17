DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_SILVER.SP_LOAD_SILVER_PRODUCTS$$

CREATE PROCEDURE RELIANT_DWH_SILVER.SP_LOAD_SILVER_PRODUCTS()
BEGIN
    DECLARE v_watermark DATETIME;
    DECLARE v_new_watermark DATETIME;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_started_at DATETIME;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SP_LOAD_SILVER_PRODUCTS';
    DECLARE v_layer VARCHAR(20) DEFAULT 'SILVER';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SILVER_PRODUCTS';
    DECLARE v_error_msg TEXT;
    DECLARE v_result_message VARCHAR(512);

    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'FAILED', v_error_msg);

        -- Return the error message to the caller
        SELECT CONCAT(v_sp_name, ': ERROR - ', v_error_msg) AS result;
    END;

    SET v_started_at = NOW();

    SELECT COALESCE(MAX(updated_at), MAX(created_at), CAST('1999-01-01 00:00:01' AS DATETIME))
    INTO v_watermark
    FROM RELIANT_DWH_SILVER.SILVER_PRODUCTS;

    SELECT MAX(loaded_at) INTO v_new_watermark
    FROM RELIANT_DWH_BRONZE.STG_PRODUCTS
    WHERE is_processed <> TRUE AND loaded_at > v_watermark;

    IF v_new_watermark IS NULL THEN
        SET v_rows_merged = 0;
        SET v_result_message = 'No new records to process in STG_PRODUCTS';

        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'SUCCESS', 'No new records to process');
    ELSE
        INSERT INTO RELIANT_DWH_SILVER.SILVER_PRODUCTS (
            product_id,
            product_name,
            category,
            brand,
            purchase_price,
            MRP,
            warranty_months,
            created_at,
            updated_at
        )
        SELECT *
        FROM (
            SELECT
                CAST(NULLIF(TRIM(product_id), '') AS UNSIGNED) AS product_id,
                TRIM(product_name) AS product_name,
                TRIM(category) AS category,
                TRIM(brand) AS brand,
                CAST(NULLIF(REPLACE(TRIM(purchase_price), '$', ''), '') AS DECIMAL(12,2)) AS purchase_price,
                CAST(NULLIF(REPLACE(TRIM(MRP), '$', ''), '') AS DECIMAL(12,2)) AS MRP,
                CAST(NULLIF(TRIM(warranty_months), '') AS SIGNED) AS warranty_months,
                NOW() AS created_at,
                NOW() AS updated_at
            FROM RELIANT_DWH_BRONZE.STG_PRODUCTS
            WHERE is_processed <> TRUE
              AND loaded_at > v_watermark
              AND loaded_at <= v_new_watermark
              AND TRIM(product_id) <> ''
              AND TRIM(product_id) REGEXP '^[0-9]+$'
        ) AS src
        ON DUPLICATE KEY UPDATE
            product_name    = src.product_name,
            category        = src.category,
            brand           = src.brand,
            purchase_price  = src.purchase_price,
            MRP             = src.MRP,
            warranty_months = src.warranty_months,
            updated_at      = NOW();

    SET v_rows_merged = ROW_COUNT();

        UPDATE RELIANT_DWH_BRONZE.STG_PRODUCTS
        SET is_processed = TRUE
        WHERE is_processed <> TRUE
            AND loaded_at > v_watermark
            AND loaded_at <= v_new_watermark;

    DELETE FROM RELIANT_DWH_BRONZE.STG_PRODUCTS WHERE is_processed = TRUE;

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
        v_watermark, v_rows_merged, 'SUCCESS', NULL);

        SET v_result_message = CONCAT(v_sp_name, ': ', v_rows_merged, ' rows merged. Watermark was ', v_watermark);
    END IF;

    SELECT v_result_message AS result;
END$$

DELIMITER ;