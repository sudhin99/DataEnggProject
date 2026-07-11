USE RELIANT_DWH_SILVER;

DROP TABLE IF EXISTS SILVER_GOOGLE_REVIEWS;

CREATE TABLE SILVER_REVIEWS (
    review_id       INT PRIMARY KEY,
    store_id        INT,
    rating          INT,
    text            TEXT,
    review_date     DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_silver_google_reviews_store_id (store_id),
    INDEX idx_silver_google_reviews_review_date (review_date)
);
