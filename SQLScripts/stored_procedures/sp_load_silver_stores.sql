DELIMITER $$

DROP PROCEDURE IF EXISTS sp_load_silver_stores$$

CREATE PROCEDURE sp_load_silver_stores()
BEGIN
    DECLARE v_watermark TIMESTAMP;
    DECLARE v_new_watermark TIMESTAMP;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'sp_load_silver_stores';
    DECLARE v_layer VARCHAR(20) DEFAULT 'SILVER';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'SILVER.SILVER_STORES';
    DECLARE v_error_msg TEXT;
    
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'FAILED', v_error_msg);
    END;

    SET v_started_at = NOW();

    -- Step 1: Get watermark from silver table
    SELECT COALESCE(MAX(loaded_at), '1900-01-01 00:00:00')
    INTO v_watermark
    FROM RELIANT_DWH_SILVER.SILVER_STORES;

    -- Step 2: Get new batch ceiling
    SELECT MAX(loaded_at) INTO v_new_watermark
    FROM RELIANT_DWH_BRONZE.STG_STORES
    WHERE is_processed = FALSE AND loaded_at > v_watermark;

    IF (v_new_watermark IS NULL) THEN
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, 0, 'SUCCESS', 'No new records to process');
        
        SELECT 'No new records to process in STG_STORES' AS result;
        LEAVE proc_label;
    END IF;

    proc_label: BEGIN
        -- Step 3: INSERT/UPDATE using INSERT...ON DUPLICATE KEY UPDATE
        INSERT INTO RELIANT_DWH_SILVER.SILVER_STORES
            (store_id, store_name, city, state, country, region, created_at, updated_at)
        SELECT
            CAST(store_id AS UNSIGNED) AS store_id,
            TRIM(store_name) AS store_name,
            TRIM(city) AS city,
            TRIM(state) AS state,
            TRIM(country) AS country,
            TRIM(region) AS region,
            NOW() AS created_at,
            NOW() AS updated_at
        FROM RELIANT_DWH_BRONZE.STG_STORES
        WHERE is_processed = FALSE
          AND loaded_at > v_watermark
          AND loaded_at <= v_new_watermark
          AND store_id IS NOT NULL
          AND store_id REGEXP '^[0-9]+$'
        ON DUPLICATE KEY UPDATE
            store_name = VALUES(store_name),
            city = VALUES(city),
            state = VALUES(state),
            country = VALUES(country),
            region = VALUES(region),
            updated_at = NOW();

        SET v_rows_merged = ROW_COUNT();

        -- Step 4: Mark processed
        UPDATE RELIANT_DWH_BRONZE.STG_STORES
        SET is_processed = TRUE
        WHERE is_processed = FALSE
          AND loaded_at > v_watermark
          AND loaded_at <= v_new_watermark;

        -- Step 5: Delete processed records
        DELETE FROM RELIANT_DWH_BRONZE.STG_STORES WHERE is_processed = TRUE;

        -- Step 6: Log success
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'SUCCESS', NULL);

        SELECT CONCAT(v_sp_name, ': ', v_rows_merged, ' rows merged. Watermark was ', v_watermark) AS result;
    END proc_label;

END$$

DELIMITER ;
