DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_SILVER.SP_LOAD_SILVER_EMPLOYEES$$

CREATE PROCEDURE RELIANT_DWH_SILVER.SP_LOAD_SILVER_EMPLOYEES()
BEGIN
    DECLARE v_watermark DATETIME;
    DECLARE v_new_watermark DATETIME;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_started_at DATETIME;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SP_LOAD_SILVER_EMPLOYEES';
    DECLARE v_layer VARCHAR(20) DEFAULT 'SILVER';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SILVER_EMPLOYEES';
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
    END;

    SET v_started_at = NOW();

    SELECT COALESCE(MAX(updated_at), MAX(created_at), CAST('1999-01-01 00:00:01' AS DATETIME))
    INTO v_watermark
    FROM RELIANT_DWH_SILVER.SILVER_EMPLOYEES;

    SELECT MAX(loaded_at) INTO v_new_watermark
    FROM RELIANT_DWH_BRONZE.STG_EMPLOYEES
    WHERE is_processed <> TRUE AND loaded_at > v_watermark;

proc_label: BEGIN
    IF v_new_watermark IS NULL THEN
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, 0, 'SUCCESS', 'No new records to process');

        SELECT 'No new records to process in STG_EMPLOYEES' AS result;
        LEAVE proc_label;
    END IF;

    INSERT INTO RELIANT_DWH_SILVER.SILVER_EMPLOYEES
        (emp_id, emp_name, gender, designation, store_id, city, store_name, joining_date, salary, phone_number, created_at, updated_at)
    SELECT
        CAST(NULLIF(TRIM(emp_id), '') AS UNSIGNED) AS emp_id,
        TRIM(emp_name) AS emp_name,
        TRIM(gender) AS gender,
        TRIM(designation) AS designation,
        CAST(NULLIF(TRIM(store_id), '') AS UNSIGNED) AS store_id,
        TRIM(city) AS city,
        TRIM(store_name) AS store_name,
        STR_TO_DATE(NULLIF(TRIM(joining_date), ''), '%Y-%m-%d') AS joining_date,
        CAST(NULLIF(REPLACE(TRIM(salary), '$', ''), '') AS DECIMAL(12,2)) AS salary,
        TRIM(phone_number) AS phone_number,
        NOW() AS created_at,
        NOW() AS updated_at
        FROM RELIANT_DWH_BRONZE.STG_EMPLOYEES
        WHERE is_processed <> TRUE
            AND loaded_at > v_watermark
            AND loaded_at <= v_new_watermark
      AND TRIM(emp_id) <> ''
      AND TRIM(emp_id) REGEXP '^[0-9]+$'
    ON DUPLICATE KEY UPDATE
        emp_name = VALUES(emp_name),
        gender = VALUES(gender),
        designation = VALUES(designation),
        store_id = VALUES(store_id),
        city = VALUES(city),
        store_name = VALUES(store_name),
        joining_date = VALUES(joining_date),
        salary = VALUES(salary),
        phone_number = VALUES(phone_number),
        updated_at = NOW();

    SET v_rows_merged = ROW_COUNT();

        UPDATE RELIANT_DWH_BRONZE.STG_EMPLOYEES
        SET is_processed = TRUE
        WHERE is_processed <> TRUE
            AND loaded_at > v_watermark
            AND loaded_at <= v_new_watermark;

    DELETE FROM RELIANT_DWH_BRONZE.STG_EMPLOYEES WHERE is_processed = TRUE;

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
        v_watermark, v_rows_merged, 'SUCCESS', NULL);

    SELECT CONCAT(v_sp_name, ': ', v_rows_merged, ' rows merged. Watermark was ', v_watermark) AS result;
END proc_label;

END$$

DELIMITER ;