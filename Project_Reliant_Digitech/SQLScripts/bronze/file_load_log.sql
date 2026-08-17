USE RELIANT_DWH_BRONZE;

-- ==============================================================================
-- FILE_LOAD_LOG
-- Tracks every file loaded into bronze staging.
-- Before loading, Python checks this table.
-- If the file was already loaded successfully, it is skipped.
-- ==============================================================================

CREATE TABLE IF NOT EXISTS FILE_LOAD_LOG (
    log_id          INT AUTO_INCREMENT,
    file_name       VARCHAR(255),
    table_name      VARCHAR(100),
    file_hash       VARCHAR(64),
    rows_loaded     INT,
    load_status     VARCHAR(20),
    error_message   TEXT,
    loaded_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
);
