DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_GOLD.SP_LOAD_DIM_DATE$$

CREATE PROCEDURE RELIANT_DWH_GOLD.SP_LOAD_DIM_DATE()
BEGIN
    DECLARE v_watermark TIMESTAMP DEFAULT NOW();
    DECLARE v_new_watermark TIMESTAMP;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.SP_LOAD_DIM_DATE';
    DECLARE v_layer VARCHAR(20) DEFAULT 'GOLD';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.DIM_DATE';
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

        SELECT CONCAT(v_sp_name, ': ERROR - ', v_error_msg) AS result;
    END;

    SET v_started_at = NOW();

    START TRANSACTION;

    INSERT INTO RELIANT_DWH_GOLD.DIM_DATE (
        the_date,
        year,
        quarter,
        month,
        month_name,
        day,
        day_of_week,
        is_weekend,
        created_at,
        updated_at
    )
    SELECT *
    FROM (
        SELECT
            STR_TO_DATE(TRIM(date), '%Y-%m-%d') AS the_date,
            CAST(NULLIF(TRIM(year), '') AS UNSIGNED) AS year,
            NULLIF(TRIM(quarter), '') AS quarter,
            CAST(NULLIF(TRIM(month), '') AS UNSIGNED) AS month,
            TRIM(month_name) AS month_name,
            CAST(NULLIF(TRIM(day), '') AS UNSIGNED) AS day,
            CASE TRIM(weekday_name)
                WHEN 'Monday' THEN 1
                WHEN 'Tuesday' THEN 2
                WHEN 'Wednesday' THEN 3
                WHEN 'Thursday' THEN 4
                WHEN 'Friday' THEN 5
                WHEN 'Saturday' THEN 6
                WHEN 'Sunday' THEN 7
            END AS day_of_week,
            (TRIM(is_weekend) = 'True') AS is_weekend,
            NOW() AS created_at,
            NOW() AS updated_at
        FROM RELIANT_DWH_BRONZE.STG_DATE_DIM
        WHERE TRIM(date) <> ''
    ) AS src
    ON DUPLICATE KEY UPDATE
        year        = src.year,
        quarter     = src.quarter,
        month       = src.month,
        month_name  = src.month_name,
        day         = src.day,
        day_of_week = src.day_of_week,
        is_weekend  = src.is_weekend,
        updated_at  = NOW();

        SET v_rows_merged = ROW_COUNT();
        COMMIT;

        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'SUCCESS', NULL);

        SET v_result_message = CONCAT(v_sp_name, ': ', v_rows_merged, ' date rows merged');


    SELECT v_result_message AS result;
END$$

DELIMITER ;
