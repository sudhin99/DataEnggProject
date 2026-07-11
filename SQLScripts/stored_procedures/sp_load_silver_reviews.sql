DELIMITER $$

DROP PROCEDURE IF EXISTS sp_load_silver_reviews$$

CREATE PROCEDURE sp_load_silver_reviews()
BEGIN
    DECLARE v_watermark TIMESTAMP;
    DECLARE v_new_watermark TIMESTAMP;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'sp_load_silver_reviews';
    DECLARE v_layer VARCHAR(20) DEFAULT 'SILVER';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SILVER_REVIEWS';
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

    SELECT COALESCE(MAX(updated_at), MAX(created_at), '1900-01-01 00:00:00')
    INTO v_watermark
    FROM RELIANT_DWH_SILVER.SILVER_REVIEWS;

    SELECT MAX(loaded_at) INTO v_new_watermark
    FROM RELIANT_DWH_BRONZE.STG_GOOGLE_REVIEWS
    WHERE is_processed = FALSE AND loaded_at > v_watermark;

    IF v_new_watermark IS NULL THEN
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, 0, 'SUCCESS', 'No new records to process');

        SELECT 'No new records to process in STG_GOOGLE_REVIEWS' AS result;
        LEAVE proc_label;
    END IF;

proc_label: BEGIN
    INSERT INTO RELIANT_DWH_SILVER.SILVER_REVIEWS
        (review_id, store_id, rating, text, review_date, created_at, updated_at)
    SELECT
        CAST(NULLIF(TRIM(review_id), '') AS UNSIGNED) AS review_id,
        CAST(NULLIF(TRIM(store_id), '') AS UNSIGNED) AS store_id,
        CAST(NULLIF(TRIM(rating), '') AS SIGNED) AS rating,
        TRIM(text) AS text,
        STR_TO_DATE(NULLIF(TRIM(date), ''), '%Y-%m-%d') AS review_date,
        NOW() AS created_at,
        NOW() AS updated_at
    FROM RELIANT_DWH_BRONZE.STG_GOOGLE_REVIEWS
    WHERE is_processed = FALSE
      AND loaded_at > v_watermark
      AND loaded_at <= v_new_watermark
      AND TRIM(review_id) <> ''
      AND TRIM(review_id) REGEXP '^[0-9]+$'
    ON DUPLICATE KEY UPDATE
        store_id = VALUES(store_id),
        rating = VALUES(rating),
        text = VALUES(text),
        review_date = VALUES(review_date),
        updated_at = NOW();

    SET v_rows_merged = ROW_COUNT();

    UPDATE RELIANT_DWH_BRONZE.STG_GOOGLE_REVIEWS
    SET is_processed = TRUE
    WHERE is_processed = FALSE
      AND loaded_at > v_watermark
      AND loaded_at <= v_new_watermark;

    DELETE FROM RELIANT_DWH_BRONZE.STG_GOOGLE_REVIEWS WHERE is_processed = TRUE;

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
        v_watermark, v_rows_merged, 'SUCCESS', NULL);

    SELECT CONCAT(v_sp_name, ': ', v_rows_merged, ' rows merged. Watermark was ', v_watermark) AS result;
END proc_label;

END$$

DELIMITER ;