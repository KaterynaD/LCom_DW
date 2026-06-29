{% macro create_fact_usage_monthly_snapshots_table() %}

{% set custom_schema = deployment_schema() %}

{% set create_table_operation %}


CREATE TABLE IF NOT EXISTS {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots
(
schoolyear VARCHAR(20) not null ENCODE lzo
,schoolyear_mon INTEGER not null ENCODE az64
,mon_year INTEGER not null ENCODE RAW
,mon_lastday DATE not null ENCODE az64
,country VARCHAR(60) not null ENCODE lzo
,state_province_code VARCHAR(20) not null ENCODE bytedict
,organization_district_id VARCHAR(300) not null ENCODE lzo
,organization_school_id VARCHAR(300) not null ENCODE lzo
,product_category VARCHAR(100) not null ENCODE bytedict
,grade_level VARCHAR(20) not null ENCODE bytedict
,topic VARCHAR(100) not null ENCODE bytedict
,school_cnt_students BIGINT not null ENCODE az64
,school_students_launches BIGINT not null ENCODE az64
,district_cnt_students BIGINT not null ENCODE az64
,district_students_launches BIGINT not null ENCODE az64
,state_cnt_students BIGINT not null ENCODE az64
,state_students_launches BIGINT not null ENCODE az64
,country_cnt_students BIGINT not null ENCODE az64
,country_students_launches BIGINT not null ENCODE az64
,company_cnt_students BIGINT not null ENCODE az64
,company_students_launches BIGINT not null ENCODE az64
,school_cnt_students_month BIGINT not null ENCODE az64
,school_students_launches_month BIGINT not null ENCODE az64
,district_cnt_students_month BIGINT not null ENCODE az64
,district_students_launches_month BIGINT not null ENCODE az64
,state_cnt_students_month BIGINT not null ENCODE az64
,state_students_launches_month BIGINT not null ENCODE az64
,country_cnt_students_month BIGINT not null ENCODE az64
,country_students_launches_month BIGINT not null ENCODE az64
,company_cnt_students_month BIGINT not null ENCODE az64
,company_students_launches_month BIGINT not null ENCODE az64
,loaddate TIMESTAMP WITHOUT TIME ZONE not null ENCODE az64
)
DISTSTYLE KEY
DISTKEY (organization_district_id)
SORTKEY (
mon_year
)
;

COMMENT ON TABLE {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots IS 'Cumulative activity from the start of a school year (YTD) till end of a month aggregated at different levels: school, district, state, country, company, grade_level (elementary-middle-high), topic, some selected SKU and sequences (product_category). Not demo or trial districts. The lowest granularity of the table is: school-product category-grade level-topic (school_cnt_students and school_students_launches). The other measures (starting district_, state_, country_ or company_) are repeated at the lowest level. This structure is chosen because the measures, generally speaking, are not additive (count distinct).
';

-- Column comments

COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.schoolyear IS 'Calendar years in School Year like 2024/2025.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.schoolyear_mon IS 'School Year Month number starting from August - 1, ending July - 12.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.mon_year IS 'Calendar Year and Month in a form YYYYMM.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.mon_lastday IS 'Calendar Month Last day.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.country IS 'Defines Country level for country_cnt_students and country_students_launches.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.state_province_code IS 'Defines State level for state_cnt_students and state_students_launches along with Country.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.organization_district_id IS 'Defines District level for district_cnt_students and district_students_launches along with Country and State.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.organization_school_id IS 'The lowest level in this table: School, for school_cnt_students and school_students_launches.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.product_category IS 'Pre-selected SKU and sequence groups and sub-groups.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.grade_level IS 'Elementary-Middle-High. Unknown is for Students only where grade is unknown. Non-Students are not included.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.topic IS 'All available topics.';
--
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.school_cnt_students IS 'Unique Count of Students launched an assignment at least once per school from the first day of a School Year to the last day of a month including.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.school_students_launches IS 'Unique Count of assignments launches from students per school from the first day of a School Year to the last day of a month including..';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.district_cnt_students IS 'Unique Count of Students launched an assignment at least once per district from the first day of a School Year to the last day of a month including.. The same district-level number is repeated for each School.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.district_students_launches IS 'Unique Count of assignments launches from students per district from the first day of a School Year to the last day of a month including.. The same district-level number is repeated for each School.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.state_cnt_students IS 'Unique Count of Students launched an assignment at least once per state from the first day of a School Year to the last day of a month including.. The same state-level number is repeated for each School and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.state_students_launches IS 'Unique Count of assignments launches from students per state from the first day of a School Year to the last day of a month including.. The same state-level number is repeated for each School and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.country_cnt_students IS 'Unique Count of Students launched an assignment at least once per country from the first day of a School Year to the last day of a month including.. The same country-level number is repeated for each State, School, and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.country_students_launches IS 'Unique Count of assignments launches from students per country from the first day of a School Year to the last day of a month including.. The same country-level number is repeated for each State, School, and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.company_cnt_students IS 'Total Unique Count of Students launched an assignment at least once from the first day of a School Year to the last day of a month including.. The same Company (LCOM)-level number is repeated for each Country, State, School, and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.company_students_launches IS 'Total Unique Count of assignments launches from students from the first day of a School Year to the last day of a month including.. The same Company (LCOM)-level number is repeated for each Country, State, School, and District.';
--
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.school_cnt_students_month IS 'Unique Count of Students launched an assignment at least once per school from the first to the last day of a month including.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.school_students_launches_month IS 'Unique Count of assignments launches from students per school.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.district_cnt_students_month IS 'Unique Count of Students launched an assignment at least once per district from the first to the last day of a month including. The same district-level number is repeated for each School.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.district_students_launches_month IS 'Unique Count of assignments launches from students per district from the first to the last day of a month including. The same district-level number is repeated for each School.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.state_cnt_students_month IS 'Unique Count of Students launched an assignment at least once per state from the first to the last day of a month including. The same state-level number is repeated for each School and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.state_students_launches_month IS 'Unique Count of assignments launches from students per state from the first to the last day of a month including. The same state-level number is repeated for each School and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.country_cnt_students_month IS 'Unique Count of Students launched an assignment at least once per country from the first to the last day of a month including. The same country-level number is repeated for each State, School, and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.country_students_launches_month IS 'Unique Count of assignments launches from students per country from the first to the last day of a month including. The same country-level number is repeated for each State, School, and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.company_cnt_students_month IS 'Total Unique Count of Students launched an assignment at least once from the first to the last day of a month including. The same Company (LCOM)-level number is repeated for each Country, State, School, and District.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.company_students_launches_month IS 'Total Unique Count of assignments launches from students from the first to the last day of a month including. The same Company (LCOM)-level number is repeated for each Country, State, School, and District.';
--
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_usage_monthly_snapshots.loaddate IS 'Timestamp when the record was created.';






{% endset %}

{{ run_DDL('fact_students_usage_monthly_snapshots', create_table_operation) }}

{% endmacro %} 