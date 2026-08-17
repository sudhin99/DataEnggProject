DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_GOLD.SP_LOAD_DIM_STORE$$

CREATE PROCEDURE RELIANT_DWH_GOLD.SP_LOAD_DIM_STORE()
BEGIN
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.SP_LOAD_DIM_STORE';
    DECLARE v_layer VARCHAR(20) DEFAULT 'GOLD';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.DIM_STORE';
    DECLARE v_error_msg TEXT;
    DECLARE v_watermark TIMESTAMP;
    DECLARE v_new_watermark TIMESTAMP;
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
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'FAILED', v_error_msg);

        SELECT CONCAT(v_sp_name, ': ERROR - ', v_error_msg) AS result;
    END;

    SET v_started_at = NOW();

    -- Watermark logic
    SELECT COALESCE(MAX(updated_at), MAX(created_at), CAST('1999-01-01 00:00:01' AS DATETIME))
    INTO v_watermark
    FROM RELIANT_DWH_GOLD.DIM_STORE;

    SELECT MAX(updated_at) INTO v_new_watermark
    FROM RELIANT_DWH_SILVER.SILVER_STORES
    WHERE updated_at > v_watermark;

    IF v_new_watermark IS NULL THEN
        SET v_rows_merged = 0;
        SET v_result_message = 'No new records to process in SILVER_STORES';

        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs,
             watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'SUCCESS', 'No new records to process');
    ELSE
        START TRANSACTION;

        INSERT INTO RELIANT_DWH_GOLD.DIM_STORE (
            store_id,
            store_name,
            city,
            state,
            store_type,
            open_year,
            store_area_sqft,
            created_at,
            updated_at
        )
        SELECT *
        FROM (
            SELECT
                store_id,
                store_name,
                city,
                state,
                store_type,
                open_year,
                store_area_sqft,
                NOW() AS created_at,
                NOW() AS updated_at
            FROM RELIANT_DWH_SILVER.SILVER_STORES
            WHERE updated_at > v_watermark
              AND updated_at <= v_new_watermark
              AND TRIM(store_id) <> ''
        ) AS src
        ON DUPLICATE KEY UPDATE
            store_name      = src.store_name,
            city            = src.city,
            state           = src.state,
            store_type      = src.store_type,
            open_year       = src.open_year,
            store_area_sqft = src.store_area_sqft,
            updated_at      = NOW();

        SET v_rows_merged = ROW_COUNT();

        COMMIT;

        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs,
             watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_new_watermark, v_rows_merged, 'SUCCESS', NULL);

        SET v_result_message = CONCAT(v_sp_name, ': ', v_rows_merged,
                                      ' store rows merged. Watermark was ',
                                      v_watermark);
    END IF;

    SELECT v_result_message AS result;
END$$

DELIMITER ;
