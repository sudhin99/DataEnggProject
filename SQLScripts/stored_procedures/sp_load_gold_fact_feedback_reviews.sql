USE RELIANT_DWH_GOLD;

DELIMITER $$

DROP PROCEDURE IF EXISTS RELIANT_DWH_GOLD.SP_LOAD_GOLD_FACT_FEEDBACK_REVIEWS$$

CREATE PROCEDURE RELIANT_DWH_GOLD.SP_LOAD_GOLD_FACT_FEEDBACK_REVIEWS()
BEGIN
    DECLARE v_started_at TIMESTAMP;
    DECLARE v_rows_feedback INT DEFAULT 0;
    DECLARE v_rows_reviews INT DEFAULT 0;
    DECLARE v_sp_name VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.SP_LOAD_GOLD_FACT_FEEDBACK_REVIEWS';
    DECLARE v_layer VARCHAR(20) DEFAULT 'GOLD';
    DECLARE v_target_table VARCHAR(100) DEFAULT 'RELIANT_DWH_GOLD.FACT_FEEDBACK_REVIEWS';
    DECLARE v_error_msg TEXT;
    
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
            (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
        VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
            TIMESTAMPDIFF(SECOND, v_started_at, NOW()), NULL, 0, 'FAILED', v_error_msg);
    END;

    SET v_started_at = NOW();

    -- Single INSERT using CTE + UNION ALL across both Silver sources
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
            CASE 
                WHEN f.rating >= 4 THEN 'POSITIVE'
                WHEN f.rating = 3  THEN 'NEUTRAL'
                ELSE 'NEGATIVE'
            END               AS sentiment
        FROM RELIANT_DWH_SILVER.SILVER_FEEDBACK f
        JOIN RELIANT_DWH_GOLD.DIM_DATE d     ON f.feedback_date = d.full_date
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
            r.review_text     AS comment,
            r.sentiment
        FROM RELIANT_DWH_SILVER.SILVER_REVIEWS r
        JOIN RELIANT_DWH_GOLD.DIM_DATE d     ON r.review_date = d.full_date
        JOIN RELIANT_DWH_GOLD.DIM_STORE s    ON r.store_id = s.store_id
    ),
    cte_combined AS (
        SELECT * FROM cte_feedback
        UNION ALL
        SELECT * FROM cte_reviews
    )

    INSERT INTO RELIANT_DWH_GOLD.FACT_FEEDBACK_REVIEWS
        (source_type, source_id, date_key, store_key, customer_key, rating, channel, comment, sentiment)
    SELECT 
        source_type, 
        source_id, 
        date_key, 
        store_key, 
        customer_key, 
        rating, 
        channel, 
        comment, 
        sentiment
    FROM cte_combined
    ON DUPLICATE KEY UPDATE
        rating     = VALUES(rating),
        comment    = VALUES(comment),
        sentiment  = VALUES(sentiment),
        updated_at = NOW();

    SET v_rows_feedback = ROW_COUNT();

    INSERT INTO RELIANT_DWH_BRONZE.SP_EXECUTION_LOG
        (sp_name, layer, target_table, started_at, ended_at, duration_secs, watermark_used, rows_merged, status, error_message)
    VALUES (v_sp_name, v_layer, v_target_table, v_started_at, NOW(),
        TIMESTAMPDIFF(SECOND, v_started_at, NOW()), NULL, v_rows_feedback, 'SUCCESS', NULL);

    SELECT CONCAT(v_sp_name, ': ', v_rows_feedback, ' total rows merged') AS result;
END$$

DELIMITER ;
