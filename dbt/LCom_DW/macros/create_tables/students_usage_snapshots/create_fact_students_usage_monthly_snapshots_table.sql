{% macro create_fact_usage_monthly_snapshots_table() %}
{% set create_table_operation %}

drop table if exists content_delivery_usage.fact_students_usage_monthly_snapshots;
CREATE TABLE IF NOT EXISTS content_delivery_usage.fact_students_usage_monthly_snapshots
(
	 schoolyear VARCHAR(20)   ENCODE lzo
	,schoolyear_mon INTEGER   ENCODE az64
	,mon_year INTEGER   ENCODE RAW
	,mon_lastday DATE   ENCODE az64
	,country VARCHAR(60)   ENCODE lzo
	,state_province_code VARCHAR(20)   ENCODE bytedict
	,organization_district_id VARCHAR(300)   ENCODE lzo
	,organization_school_id VARCHAR(300)   ENCODE lzo
	,product_category VARCHAR(100)   ENCODE bytedict
	,grade_level VARCHAR(20)   ENCODE bytedict
	,topic VARCHAR(100)   ENCODE bytedict
	,school_cnt_students BIGINT   ENCODE az64
	,school_students_launches BIGINT   ENCODE az64
	,district_cnt_students BIGINT   ENCODE az64
	,district_students_launches BIGINT   ENCODE az64
	,state_cnt_students BIGINT   ENCODE az64
	,state_students_launches BIGINT   ENCODE az64
	,country_cnt_students BIGINT   ENCODE az64
	,country_students_launches BIGINT   ENCODE az64
	,company_cnt_students BIGINT   ENCODE az64
	,company_students_launches BIGINT   ENCODE az64
	,loaddate TIMESTAMP WITHOUT TIME ZONE   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (organization_district_id)
 SORTKEY (
	mon_year
	)
;

ALTER TABLE content_delivery_usage.fact_students_usage_monthly_snapshots ADD FOREIGN KEY (organization_district_id) REFERENCES common.dim_account(account_id);   
ALTER TABLE content_delivery_usage.fact_students_usage_monthly_snapshots ADD FOREIGN KEY (organization_school_id) REFERENCES common.dim_account(account_id);   
   
COMMENT ON TABLE content_delivery_usage.fact_students_usage_monthly_snapshots IS 'Cumulative activity from the start of a  school year (YTD) till end of month aggregated at different levels: school,district,state,country,company,grade_level (elementary-middle-high),topic,some selected sku and sequences (product_category). Only student and not demo or trial districts. The lowest granularity of teh table is: school-product category-grade level-topic (school_cnt_students and school_students_launches). The other measures (starting district_, state_, country_ or company_) are repeated at the lowest level. This structure is choosen because the measures, generally speaking, are not additive (count distinct). ';

COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.schoolyear IS 'Calendar years in School Year like 2024/2025';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.schoolyear_mon IS 'School Year Month number starting from Augest - 1 , ending July - 12';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.mon_year IS 'Calendar Year and Month in a form YYYYMM';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.mon_lastday IS 'Calendar Month Last day';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.country IS 'Defines Country level for country_cnt_students and country_students_launches';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.state_province_code IS 'Defines State level for state_cnt_students and state_students_launches along with Country';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.organization_district_id IS 'Defines District level for district_cnt_students and district_students_launches along with Country and State';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.organization_school_id IS 'The lowelest level in this table School for school_cnt_students and school_students_launches';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.product_category IS 'Pre-selected sku and sequence groups and sub-groups';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.grade_level IS 'Elementary-Middle-High. Unknown is for Students only where grade is unknown. Non-Students are not included';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.topic IS 'All available topics';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.school_cnt_students IS 'Unique Count of Students launched an assignment at least once per school';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.school_students_launches IS 'Unique Count of assignments launches from students per school';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.district_cnt_students IS 'Unique Count of Students launched an assignment at least once per district. The same district level number is repeated for each School.';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.district_students_launches IS 'Unique Count of assignments launches from students per district. The same district level number is repeated for each School.';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.state_cnt_students IS 'Unique Count of Students launched an assignment at least once per state. The same state level number is repeated for each School and District.';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.state_students_launches IS 'Unique Count of assignments launches from students per state. The same state level number is repeated for each School and District.';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.country_cnt_students IS 'Unique Count of Students launched an assignment at least once per country. The same country level number is repeated for each State, School and District.';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.country_students_launches IS 'Unique Count of assignments launches from students per country. The same country level number is repeated for each State, School and District.';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.company_cnt_students IS 'Total Unique Count of Students launched an assignment at least once. The same Company(LCOM) level number is repeated for each Country, State, School and District.';
COMMENT ON COLUMN content_delivery_usage.fact_students_usage_monthly_snapshots.company_students_launches IS 'Total Unique Count of assignments launches from students. The same Company(LCOM) level number is repeated for each Country, State, School and District.';







{% endset %}

{% do run_query(create_table_operation) %}

{% endmacro %} 