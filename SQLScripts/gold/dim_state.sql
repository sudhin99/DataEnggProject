USE RELIANT_DWH_GOLD;

DROP TABLE IF EXISTS DIM_STATE;

CREATE TABLE DIM_STATE (
    state_key    VARCHAR(20) PRIMARY KEY,
    state_code   VARCHAR(10),
    state_name   VARCHAR(100),
    country_name VARCHAR(100) DEFAULT 'INDIA',
    capital      VARCHAR(100)
    UNIQUE KEY uk_state_code (state_code)
);
