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
    DECLARE v_rows INT DEFAULT 0;

    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()), v_watermark, v_rows, 'FAILED', v_error_msg);
    END;

    SET v_started_at = NOW();

    SELECT COALESCE(MAX(updated_at), '1970-01-01') INTO v_watermark FROM RELIANT_DWH_GOLD.DIM_PRODUCT;

    SELECT MAX(updated_at) INTO v_new_watermark FROM RELIANT_DWH_SILVER.SILVER_PRODUCTS WHERE updated_at > v_watermark;
    IF v_new_watermark IS NULL THEN
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()), v_watermark, 0, 'NOOP', NULL);
        SELECT CONCAT(v_sp_name, ': no new product updates since ', v_watermark) AS result;
        LEAVE proc_end;
    END IF;

    INSERT INTO RELIANT_DWH_GOLD.DIM_PRODUCT
        (product_id, product_name, category, brand, purchase_price, mrp, warranty_months, created_at, updated_at)
    SELECT
        product_id,
        product_name,
        category,
        brand,
        purchase_price,
        mrp,
        warranty_months,
        NOW(), NOW()
    FROM RELIANT_DWH_SILVER.SILVER_PRODUCTS
    WHERE updated_at > v_watermark AND updated_at <= v_new_watermark
    ON DUPLICATE KEY UPDATE
        product_name = VALUES(product_name),
        category = VALUES(category),
        brand = VALUES(brand),
        purchase_price = VALUES(purchase_price),
        mrp = VALUES(mrp),
        warranty_months = VALUES(warranty_months),
        updated_at = NOW();

    SET v_rows = ROW_COUNT();

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()), v_new_watermark, v_rows, 'SUCCESS', NULL);

    SELECT CONCAT(v_sp_name, ': ', v_rows, ' product rows upserted. Watermark=', v_new_watermark) AS result;

    proc_end: BEGIN END;
END$$

DELIMITER ;
