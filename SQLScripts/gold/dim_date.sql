USE RELIANT_DWH_GOLD;

DROP TABLE IF EXISTS DIM_DATE;

CREATE TABLE DIM_DATE (
    date_key    INT PRIMARY KEY AUTO_INCREMENT,
    the_date    DATE NOT NULL,
    year        INT,
    quarter     INT,
    month       INT,
    month_name  VARCHAR(20),
    day         INT,
    day_of_week INT,
    is_weekend  BOOLEAN,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_date (the_date),
    INDEX idx_year_month (year, month)
);
