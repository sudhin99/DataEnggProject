USE RELIANT_DWH_GOLD;

DROP TABLE IF EXISTS FACT_FEEDBACK_REVIEWS;

CREATE TABLE FACT_FEEDBACK_REVIEWS (
    sentiment_key INT AUTO_INCREMENT PRIMARY KEY,
    source_type   VARCHAR(20),
    source_id     INT,
    date_key      INT,
    store_key     INT,
    customer_key  INT,
    rating        INT,
    channel       VARCHAR(50),
    comment       TEXT,
    sentiment     VARCHAR(20),
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_source (source_type, source_id),
    INDEX idx_date_key (date_key),
    INDEX idx_store_key (store_key),
    INDEX idx_customer_key (customer_key),
    INDEX idx_rating (rating),
    INDEX idx_channel (channel),
    INDEX idx_source_type (source_type),
    INDEX idx_sentiment (sentiment),
    INDEX idx_date_store (date_key, store_key),
    FOREIGN KEY (date_key) REFERENCES DIM_DATE(date_key),
    FOREIGN KEY (store_key) REFERENCES DIM_STORE(store_key),
    FOREIGN KEY (customer_key) REFERENCES DIM_CUSTOMER(customer_key)
);
