DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_SILVER.SP_LOAD_SILVER_REVIEWS$$

CREATE PROCEDURE RELIANT_DWH_SILVER.SP_LOAD_SILVER_REVIEWS()
BEGIN
    DECLARE v_watermark DATETIME;
    DECLARE v_new_watermark DATETIME;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_started_at DATETIME;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SP_LOAD_SILVER_REVIEWS';
    DECLARE v_layer VARCHAR(20) DEFAULT 'SILVER';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SILVER_REVIEWS';
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
    FROM RELIANT_DWH_SILVER.SILVER_REVIEWS;

    SELECT MAX(loaded_at) INTO v_new_watermark
    FROM RELIANT_DWH_BRONZE.STG_REVIEWS
    WHERE is_processed <> TRUE AND loaded_at > v_watermark;

    IF v_new_watermark IS NULL THEN
        SET v_rows_merged = 0;
        SET v_result_message = 'No new records to process in STG_REVIEWS';

        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'SUCCESS', 'No new records to process');
    ELSE
        INSERT INTO RELIANT_DWH_SILVER.SILVER_REVIEWS (
            review_id,
            store_id,
            rating,
            text,
            review_date,
            created_at,
            updated_at
        )
        SELECT *
        FROM (
            SELECT
                CAST(NULLIF(TRIM(review_id), '') AS UNSIGNED) AS review_id,
                CAST(NULLIF(TRIM(store_id), '') AS UNSIGNED) AS store_id,
                CAST(NULLIF(TRIM(rating), '') AS SIGNED) AS rating,
                TRIM(text) AS text,
                STR_TO_DATE(NULLIF(TRIM(date), ''), '%Y-%m-%d') AS review_date,
                NOW() AS created_at,
                NOW() AS updated_at
            FROM RELIANT_DWH_BRONZE.STG_REVIEWS
            WHERE is_processed <> TRUE
              AND loaded_at > v_watermark
              AND loaded_at <= v_new_watermark
              AND TRIM(review_id) <> ''
              AND TRIM(review_id) REGEXP '^[0-9]+$'
        ) AS src
        ON DUPLICATE KEY UPDATE
            store_id    = src.store_id,
            rating      = src.rating,
            text        = src.text,
            review_date = src.review_date,
            updated_at  = NOW();


    SET v_rows_merged = ROW_COUNT();

        UPDATE RELIANT_DWH_BRONZE.STG_REVIEWS
        SET is_processed = TRUE
        WHERE is_processed <> TRUE
            AND loaded_at > v_watermark
            AND loaded_at <= v_new_watermark;

    DELETE FROM RELIANT_DWH_BRONZE.STG_REVIEWS WHERE is_processed = TRUE;

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