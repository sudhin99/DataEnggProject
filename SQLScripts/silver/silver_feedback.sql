USE RELIANT_DWH_SILVER;

DROP TABLE IF EXISTS SILVER_FEEDBACK;

CREATE TABLE SILVER_FEEDBACK (
    feedback_id   INT PRIMARY KEY,
    customer_id   INT,
    customer_name VARCHAR(200),
    store_id      INT,
    store_name    VARCHAR(200),
    rating        INT,
    comment       TEXT,
    channel       VARCHAR(50),
    feedback_date DATE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_silver_feedback_customer_id (customer_id),
    INDEX idx_silver_feedback_store_id (store_id),
    INDEX idx_silver_feedback_feedback_date (feedback_date)
);
