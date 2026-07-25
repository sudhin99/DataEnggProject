USE RELIANT_DWH_GOLD;

DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_GOLD.SP_LOAD_GOLD_FACT_FEEDBACK_REVIEWS$$

CREATE PROCEDURE RELIANT_DWH_GOLD.SP_LOAD_GOLD_FACT_FEEDBACK_REVIEWS()
BEGIN
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.SP_LOAD_GOLD_FACT_FEEDBACK_REVIEWS';
    DECLARE v_layer VARCHAR(20) DEFAULT 'GOLD';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.FACT_FEEDBACK_REVIEWS';
    DECLARE v_error_msg TEXT;
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
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()), NULL, v_rows_merged, 'FAILED', v_error_msg);

        SELECT CONCAT(v_sp_name, ': ERROR - ', v_error_msg) AS result;
    END;

    SET v_started_at = NOW();

    START TRANSACTION;
	    INSERT INTO RELIANT_DWH_GOLD.FACT_FEEDBACK_REVIEWS (
        source_type, source_id, date_key, store_key, customer_key,
        rating, channel, comment, created_at, updated_at
    )
    WITH cte_feedback AS (
        SELECT
            'FEEDBACK'        AS source_type,
            f.feedback_id     AS source_id,
            d.date_key,
            s.store_key,
            c.customer_key,
            f.rating,
            f.channel,
            f.comment,
            NOW()             AS created_at,
            NOW()             AS updated_at
        FROM RELIANT_DWH_SILVER.SILVER_FEEDBACK f
        JOIN RELIANT_DWH_GOLD.DIM_DATE d     ON f.feedback_date = d.the_date
        JOIN RELIANT_DWH_GOLD.DIM_STORE s    ON f.store_id = s.store_id
        JOIN RELIANT_DWH_GOLD.DIM_CUSTOMER c ON f.customer_id = c.customer_id
    ),
    cte_reviews AS (
        SELECT
            'GOOGLE_REVIEW'   AS source_type,
            r.review_id       AS source_id,
            d.date_key,
            s.store_key,
            NULL              AS customer_key,
            r.rating,
            'GOOGLE'          AS channel,
            r.text     AS comment,
            NOW()             AS created_at,
            NOW()             AS updated_at
        FROM RELIANT_DWH_SILVER.SILVER_REVIEWS r
        JOIN RELIANT_DWH_GOLD.DIM_DATE d     ON r.review_date = d.the_date
        JOIN RELIANT_DWH_GOLD.DIM_STORE s    ON r.store_id = s.store_id
    ),
    cte_combined AS (
        SELECT * FROM cte_feedback
        UNION ALL
        SELECT * FROM cte_reviews
    )
    SELECT *
    FROM cte_combined AS src
    ON DUPLICATE KEY UPDATE
        rating     = src.rating,
        comment    = src.comment,
        updated_at = NOW();

    SET v_rows_merged = ROW_COUNT();

    COMMIT;

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs,
         watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()), NULL, v_rows_merged, 'SUCCESS', NULL);

    SET v_result_message = CONCAT(v_sp_name, ': ', v_rows_merged, ' rows merged into FACT_FEEDBACK_REVIEWS');

    SELECT v_result_message AS result;
END$$

DELIMITER ;
