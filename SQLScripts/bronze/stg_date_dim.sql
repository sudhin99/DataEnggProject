USE RELIANT_DWH_BRONZE;

DROP TABLE IF EXISTS STG_DATE_DIM;

CREATE TABLE STG_DATE_DIM (
	date            VARCHAR(50),
	year            VARCHAR(50),
	month           VARCHAR(50),
	month_name      VARCHAR(100),
	quarter         VARCHAR(50),
	day             VARCHAR(50),
	weekday_name    VARCHAR(100),
	is_weekend      VARCHAR(20),
	is_public_holiday VARCHAR(20),
	holiday_name    VARCHAR(255),
	is_working_day  VARCHAR(20),
	day_type        VARCHAR(50),
	loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	is_processed    BOOLEAN DEFAULT FALSE,
	source_file     VARCHAR(255)
);
