DROP TABLE if exists audit.dbt_run_log;
CREATE TABLE audit.dbt_run_log (
    run_id  VARCHAR(255) not null,
    start_time TIMESTAMP  not null,
    end_time TIMESTAMP,
    operation VARCHAR(255) not null,
    comments VARCHAR(255)
)
DISTSTYLE KEY
 DISTKEY (run_id)
 SORTKEY (
	start_time
	)
;

COMMENT ON TABLE audit.dbt_run_log IS 'Logging dbt runs from pre-hook/post-hook';
COMMENT ON COLUMN audit.dbt_run_log.run_id IS 'dbt run id';
COMMENT ON COLUMN audit.dbt_run_log.start_time IS 'Operation Start PST timestamp';
COMMENT ON COLUMN audit.dbt_run_log.start_time IS 'Operation End PST timestamp';
COMMENT ON COLUMN audit.dbt_run_log.operation  IS 'Running operation - dbt model name, etc';
COMMENT ON COLUMN audit.dbt_run_log.comments  IS 'Any additional info';