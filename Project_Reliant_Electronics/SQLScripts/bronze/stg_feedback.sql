USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_FEEDBACK;

CREATE TABLE STG_FEEDBACK (
    feedback_id     VARCHAR(50),
    customer_id     VARCHAR(50),
    store_id        VARCHAR(50),
    rating          VARCHAR(50),
    comment         VARCHAR(500),
    channel         VARCHAR(100),
    date            VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);