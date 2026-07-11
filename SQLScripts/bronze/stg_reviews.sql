USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_REVIEWS;

CREATE TABLE STG_REVIEWS (
    review_id       VARCHAR(50),
    store_id        VARCHAR(50),
    rating          VARCHAR(50),
    text            VARCHAR(1000),
    date            VARCHAR(50),
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed    BOOLEAN DEFAULT FALSE,
    source_file     VARCHAR(255)
);