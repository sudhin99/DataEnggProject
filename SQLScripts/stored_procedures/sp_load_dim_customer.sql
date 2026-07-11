DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_GOLD.SP_LOAD_DIM_CUSTOMER$$

CREATE PROCEDURE RELIANT_DWH_GOLD.SP_LOAD_DIM_CUSTOMER()
BEGIN
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.SP_LOAD_DIM_CUSTOMER';
    DECLARE v_layer VARCHAR(20) DEFAULT 'GOLD';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.DIM_CUSTOMER';
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

    SELECT COALESCE(MAX(updated_at), '1999-01-01 00:00:01') INTO v_watermark FROM RELIANT_DWH_GOLD.DIM_CUSTOMER;

    SELECT MAX(updated_at) INTO v_new_watermark FROM RELIANT_DWH_SILVER.SILVER_CUSTOMERS WHERE updated_at > v_watermark;
    IF v_new_watermark IS NULL THEN
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()), v_watermark, 0, 'NOOP', NULL);
        SELECT CONCAT(v_sp_name, ': no new customer updates since ', v_watermark) AS result;
    ELSE

    INSERT INTO RELIANT_DWH_GOLD.DIM_CUSTOMER
        (customer_id, customer_name, gender, city, phone, email, signup_date, created_at, updated_at)
    SELECT
        customer_id,
        concat(first_name, ' ', last_name) as customer_name,
        gender,
        city,
        phone,
        email,
        signup_date,
        NOW(), NOW()
    FROM RELIANT_DWH_SILVER.SILVER_CUSTOMERS
    WHERE updated_at > v_watermark AND updated_at <= v_new_watermark
    ON DUPLICATE KEY UPDATE
        customer_name = VALUES(customer_name),
        gender = VALUES(gender),
        city = VALUES(city),
        phone = VALUES(phone),
        email = VALUES(email),
        signup_date = VALUES(signup_date),
        updated_at = NOW();

    SET v_rows = ROW_COUNT();

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()), v_new_watermark, v_rows, 'SUCCESS', NULL);

    SELECT CONCAT(v_sp_name, ': ', v_rows, ' customer rows upserted. Watermark=', v_new_watermark) AS result;
 END IF;
END$$

DELIMITER ;
