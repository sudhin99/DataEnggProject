DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_SILVER.SP_LOAD_SILVER_CUSTOMERS$$

CREATE PROCEDURE RELIANT_DWH_SILVER.SP_LOAD_SILVER_CUSTOMERS()
BEGIN
    DECLARE v_watermark DATETIME;
    DECLARE v_new_watermark DATETIME;
    DECLARE v_rows_merged INT DEFAULT 0;
    DECLARE v_started_at DATETIME;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SP_LOAD_SILVER_CUSTOMERS';
    DECLARE v_layer VARCHAR(20) DEFAULT 'SILVER';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_SILVER.SILVER_CUSTOMERS';
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
    FROM RELIANT_DWH_SILVER.SILVER_CUSTOMERS;

    SELECT MAX(loaded_at) INTO v_new_watermark
    FROM RELIANT_DWH_BRONZE.STG_CUSTOMERS
    WHERE is_processed <> TRUE AND loaded_at > v_watermark;

    IF v_new_watermark IS NULL THEN
        SET v_rows_merged = 0;
        SET v_result_message = 'No new records to process in STG_CUSTOMERS';

        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()),
            v_watermark, v_rows_merged, 'SUCCESS', 'No new records to process');
    ELSE
        INSERT INTO RELIANT_DWH_SILVER.SILVER_CUSTOMERS
        (customer_id, customer_name, gender, city, phone, email, signup_date, created_at, updated_at)
    SELECT
        CAST(NULLIF(TRIM(customer_id), '') AS UNSIGNED) AS customer_id,
        TRIM(customer_name) AS customer_name,
        TRIM(gender) AS gender,
        TRIM(city) AS city,
        TRIM(phone) AS phone,
        TRIM(email) AS email,
        STR_TO_DATE(NULLIF(TRIM(signup_date), ''), '%Y-%m-%d') AS signup_date,
        NOW() AS created_at,
        NOW() AS updated_at
        FROM RELIANT_DWH_BRONZE.STG_CUSTOMERS
        WHERE is_processed <> TRUE
            AND loaded_at > v_watermark
            AND loaded_at <= v_new_watermark
      AND TRIM(customer_id) <> ''
      AND TRIM(customer_id) REGEXP '^[0-9]+$'
    ON DUPLICATE KEY UPDATE
        customer_name = VALUES(customer_name),
        gender = VALUES(gender),
        city = VALUES(city),
        phone = VALUES(phone),
        email = VALUES(email),
        signup_date = VALUES(signup_date),
        updated_at = NOW();

    SET v_rows_merged = ROW_COUNT();

        UPDATE RELIANT_DWH_BRONZE.STG_CUSTOMERS
        SET is_processed = TRUE
        WHERE is_processed <> TRUE
            AND loaded_at > v_watermark
            AND loaded_at <= v_new_watermark;

    DELETE FROM RELIANT_DWH_BRONZE.STG_CUSTOMERS WHERE is_processed = TRUE;

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