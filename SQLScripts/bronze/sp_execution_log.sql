USE RELIANT_DWH_BRONZE;

-- ==============================================================================
-- SP_EXECUTION_LOG
-- Logs every stored procedure execution with:
--   - Which SP ran
--   - When it started and ended
--   - How many rows were processed
--   - Status: SUCCESS or FAILED
--   - Error message if failed
-- ==============================================================================

CREATE TABLE IF NOT EXISTS SP_EXECUTION_LOG (
    log_id          INT AUTO_INCREMENT,
    sp_name         VARCHAR(100),
    layer           VARCHAR(20),
    target_table    VARCHAR(100),
    started_at      TIMESTAMP NULL,
    ended_at        TIMESTAMP NULL,
    duration_secs   INT,
    watermark_used  TIMESTAMP NULL,
    rows_merged     INT DEFAULT 0,
    status          VARCHAR(20),
    error_message   TEXT,
    logged_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id)
);
