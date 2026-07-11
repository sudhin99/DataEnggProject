DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_SILVER.SP_LOAD_SILVER_STORES$$

CREATE PROCEDURE RELIANT_DWH_SILVER.SP_LOAD_SILVER_STORES()
BEGIN
    DECLARE v_watermark TIMESTAMP;
    DECLARE v_new_watermark TIMESTAMP;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SP_LOAD_SILVER_STORES';
    DECLARE v_layer VARCHAR(20) DEFAULT 'SILVER';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SILVER_STORES';
    DECLARE v_error_msg TEXT;
    DECLARE v_result_message VARCHAR(512);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'FAILED', v_error_msg);
    END;

    SET v_started_at = NOW();

    SELECT COALESCE(MAX(updated_at), MAX(created_at), CAST('1999-01-01 00:00:01' AS DATETIME))
    INTO v_watermark
    FROM RELIANT_DWH_SILVER.SILVER_STORES;

    SELECT MAX(loaded_at) INTO v_new_watermark
    FROM RELIANT_DWH_BRONZE.STG_STORES
    WHERE is_processed <> TRUE
      AND loaded_at > v_watermark;

    IF v_new_watermark IS NULL THEN
        SET v_rows_merged = 0;
        SET v_result_message = 'No new records to process in STG_STORES';

        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'SUCCESS', 'No new records to process');
    ELSE
        START TRANSACTION;

        INSERT INTO RELIANT_DWH_SILVER.SILVER_STORES
            (store_id, store_name, city, state, store_type, open_year, store_area_sqft, created_at, updated_at)
        SELECT
            CAST(NULLIF(TRIM(store_id), '') AS UNSIGNED) AS store_id,
            TRIM(store_name) AS store_name,
            TRIM(city) AS city,
            TRIM(state) AS state,
            TRIM(store_type) AS store_type,
            CAST(NULLIF(TRIM(open_year), '') AS SIGNED) AS open_year,
            CAST(NULLIF(TRIM(store_area_sqft), '') AS SIGNED) AS store_area_sqft,
            NOW() AS created_at,
            NOW() AS updated_at
            FROM RELIANT_DWH_BRONZE.STG_STORES
            WHERE is_processed <> TRUE
                AND loaded_at > v_watermark
                AND loaded_at <= v_new_watermark
                AND TRIM(store_id) <> ''
        ON DUPLICATE KEY UPDATE
            store_name = VALUES(store_name),
            city = VALUES(city),
            state = VALUES(state),
            store_type = VALUES(store_type),
            open_year = VALUES(open_year),
            store_area_sqft = VALUES(store_area_sqft),
            updated_at = NOW();

        SET v_rows_merged = ROW_COUNT();

        UPDATE RELIANT_DWH_BRONZE.STG_STORES
        SET is_processed = TRUE
        WHERE is_processed <> TRUE
            AND loaded_at > v_watermark
            AND loaded_at <= v_new_watermark;

        DELETE FROM RELIANT_DWH_BRONZE.STG_STORES
        WHERE is_processed = TRUE;

        COMMIT;

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
