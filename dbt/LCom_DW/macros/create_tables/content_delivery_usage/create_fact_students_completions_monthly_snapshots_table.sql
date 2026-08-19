{% macro create_fact_students_completions_monthly_snapshots_table() %}

{% set custom_schema = deployment_schema() %}

{% set create_table_operation %}


CREATE TABLE IF NOT EXISTS {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots
(
 mon_year INTEGER NOT NULL ENCODE az64
,mon_lastday DATE NOT NULL ENCODE az64
,schoolyear VARCHAR(10) NOT NULL ENCODE lzo
,schoolyear_mon INTEGER NOT NULL ENCODE az64
,country VARCHAR(70) NOT NULL ENCODE lzo
,state_province_code VARCHAR(20) NOT NULL ENCODE lzo
,organization_district_id VARCHAR(300) NOT NULL ENCODE lzo
,organization_school_id VARCHAR(300) NOT NULL ENCODE lzo
,product_category VARCHAR(100) NOT NULL ENCODE bytedict
,grade_level VARCHAR(20) NOT NULL ENCODE lzo
,topic VARCHAR(100) NOT NULL ENCODE lzo
,school_cnt_completions BIGINT NOT NULL ENCODE az64
,school_cnt_events BIGINT NOT NULL ENCODE az64
,school_cnt_student_completions BIGINT NOT NULL ENCODE az64
,school_cnt_student_completions_cipa_digital_citizenship BIGINT NOT NULL ENCODE az64
,school_cnt_student_completions_cipa_cyberbullying BIGINT NOT NULL ENCODE az64
,school_cnt_student_completionsmeets_both_cipa BIGINT NOT NULL ENCODE az64
,district_cnt_completions BIGINT NOT NULL ENCODE az64
,district_cnt_events BIGINT NOT NULL ENCODE az64
,district_cnt_student_completions BIGINT NOT NULL ENCODE az64
,district_cnt_student_completions_cipa_digital_citizenship BIGINT NOT NULL ENCODE az64
,district_cnt_student_completions_cipa_cyberbullying BIGINT NOT NULL ENCODE az64
,district_cnt_student_completionsmeets_both_cipa BIGINT NOT NULL ENCODE az64
,state_cnt_completions BIGINT NOT NULL ENCODE az64
,state_cnt_events BIGINT NOT NULL ENCODE az64
,state_cnt_student_completions BIGINT NOT NULL ENCODE az64
,state_cnt_student_completions_cipa_digital_citizenship BIGINT NOT NULL ENCODE az64
,state_cnt_student_completions_cipa_cyberbullying BIGINT NOT NULL ENCODE az64
,state_cnt_student_completionsmeets_both_cipa BIGINT NOT NULL ENCODE az64
,country_cnt_completions BIGINT NOT NULL ENCODE az64
,country_cnt_events BIGINT NOT NULL ENCODE az64
,country_cnt_student_completions BIGINT NOT NULL ENCODE az64
,country_cnt_student_completions_cipa_digital_citizenship BIGINT NOT NULL ENCODE az64
,country_cnt_student_completions_cipa_cyberbullying BIGINT NOT NULL ENCODE az64
,country_cnt_student_completionsmeets_both_cipa BIGINT NOT NULL ENCODE az64
,company_cnt_completions BIGINT NOT NULL ENCODE az64
,company_cnt_events BIGINT NOT NULL ENCODE az64
,company_cnt_student_completions BIGINT NOT NULL ENCODE az64
,company_cnt_student_completions_cipa_digital_citizenship BIGINT NOT NULL ENCODE az64
,company_cnt_student_completions_cipa_cyberbullying BIGINT NOT NULL ENCODE az64
,company_cnt_student_completionsmeets_both_cipa BIGINT NOT NULL ENCODE az64
,school_cnt_completions_month BIGINT NOT NULL ENCODE az64
,school_cnt_events_month BIGINT NOT NULL ENCODE az64
,school_cnt_student_completions_month BIGINT NOT NULL ENCODE az64
,school_cnt_student_completions_cipa_digital_citizenship_month BIGINT NOT NULL ENCODE az64
,school_cnt_student_completions_cipa_cyberbullying_month BIGINT NOT NULL ENCODE az64
,school_cnt_student_completionsmeets_both_cipa_month BIGINT NOT NULL ENCODE az64
,district_cnt_completions_month BIGINT NOT NULL ENCODE az64
,district_cnt_events_month BIGINT NOT NULL ENCODE az64
,district_cnt_student_completions_month BIGINT NOT NULL ENCODE az64
,district_cnt_student_completions_cipa_digital_citizenship_month BIGINT NOT NULL ENCODE az64
,district_cnt_student_completions_cipa_cyberbullying_month BIGINT NOT NULL ENCODE az64
,district_cnt_student_completionsmeets_both_cipa_month BIGINT NOT NULL ENCODE az64
,state_cnt_completions_month BIGINT NOT NULL ENCODE az64
,state_cnt_events_month BIGINT NOT NULL ENCODE az64
,state_cnt_student_completions_month BIGINT NOT NULL ENCODE az64
,state_cnt_student_completions_cipa_digital_citizenship_month BIGINT NOT NULL ENCODE az64
,state_cnt_student_completions_cipa_cyberbullying_month BIGINT NOT NULL ENCODE az64
,state_cnt_student_completionsmeets_both_cipa_month BIGINT NOT NULL ENCODE az64
,country_cnt_completions_month BIGINT NOT NULL ENCODE az64
,country_cnt_events_month BIGINT NOT NULL ENCODE az64
,country_cnt_student_completions_month BIGINT NOT NULL ENCODE az64
,country_cnt_student_completions_cipa_digital_citizenship_month BIGINT NOT NULL ENCODE az64
,country_cnt_student_completions_cipa_cyberbullying_month BIGINT NOT NULL ENCODE az64
,country_cnt_student_completionsmeets_both_cipa_month BIGINT NOT NULL ENCODE az64
,company_cnt_completions_month BIGINT NOT NULL ENCODE az64
,company_cnt_events_month BIGINT NOT NULL ENCODE az64
,company_cnt_student_completions_month BIGINT NOT NULL ENCODE az64
,company_cnt_student_completions_cipa_digital_citizenship_month BIGINT NOT NULL ENCODE az64
,company_cnt_student_completions_cipa_cyberbullying_month BIGINT NOT NULL ENCODE az64
,company_cnt_student_completionsmeets_both_cipa_month BIGINT NOT NULL ENCODE az64
,loaddate TIMESTAMP WITHOUT TIME ZONE NOT NULL ENCODE az64
)
DISTSTYLE KEY
DISTKEY (organization_district_id)
SORTKEY (
mon_year
)
;

COMMENT ON TABLE {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots IS 'Cumulative completion activity from the start of a school year through the end of a snapshot month, plus calendar-month-only completion measures. Aggregated at school, district, state, country and company levels by product_category, grade_level and topic. Higher-level distinct-count measures are repeated at the school-level grain and are therefore non-additive.';

COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.schoolyear IS 'Calendar years in School Year like 2024/2025.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.schoolyear_mon IS 'School Year month number.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.mon_year IS 'Calendar year and month in YYYYMM form.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.mon_lastday IS 'Calendar month last day.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country IS 'Country aggregation level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_province_code IS 'State/province aggregation level within country.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.organization_district_id IS 'District aggregation level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.organization_school_id IS 'School aggregation level and lowest organization level stored in this table.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.product_category IS 'Pre-selected SKU and sequence groups and sub-groups, using the same category mapping as fact_students_usage_monthly_snapshots. (All) represents all learning objects.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.grade_level IS 'Detailed grade and rolled-up grade levels used by the completion snapshot.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.topic IS 'Learning object topic; (All) represents all topics.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_completions IS 'Number of completions (attempt rows) at school level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_events IS 'Number of distinct completion events at school level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completions IS 'Number of distinct students with a completion at school level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completions_cipa_digital_citizenship IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at school level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completions_cipa_cyberbullying IS 'Number of distinct students meeting the CIPA cyberbullying requirement at school level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completionsmeets_both_cipa IS 'Number of distinct students meeting both CIPA requirements at school level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_completions IS 'Number of completions (attempt rows) at district level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_events IS 'Number of distinct completion events at district level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completions IS 'Number of distinct students with a completion at district level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completions_cipa_digital_citizenship IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at district level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completions_cipa_cyberbullying IS 'Number of distinct students meeting the CIPA cyberbullying requirement at district level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completionsmeets_both_cipa IS 'Number of distinct students meeting both CIPA requirements at district level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_completions IS 'Number of completions (attempt rows) at state level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_events IS 'Number of distinct completion events at state level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completions IS 'Number of distinct students with a completion at state level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completions_cipa_digital_citizenship IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at state level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completions_cipa_cyberbullying IS 'Number of distinct students meeting the CIPA cyberbullying requirement at state level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completionsmeets_both_cipa IS 'Number of distinct students meeting both CIPA requirements at state level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_completions IS 'Number of completions (attempt rows) at country level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_events IS 'Number of distinct completion events at country level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completions IS 'Number of distinct students with a completion at country level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completions_cipa_digital_citizenship IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at country level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completions_cipa_cyberbullying IS 'Number of distinct students meeting the CIPA cyberbullying requirement at country level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completionsmeets_both_cipa IS 'Number of distinct students meeting both CIPA requirements at country level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_completions IS 'Number of completions (attempt rows) at company level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_events IS 'Number of distinct completion events at company level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completions IS 'Number of distinct students with a completion at company level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completions_cipa_digital_citizenship IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at company level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completions_cipa_cyberbullying IS 'Number of distinct students meeting the CIPA cyberbullying requirement at company level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completionsmeets_both_cipa IS 'Number of distinct students meeting both CIPA requirements at company level from the start of the school year through the snapshot month.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_completions_month IS 'Number of completions (attempt rows) at school level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_events_month IS 'Number of distinct completion events at school level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completions_month IS 'Number of distinct students with a completion at school level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completions_cipa_digital_citizenship_month IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at school level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completions_cipa_cyberbullying_month IS 'Number of distinct students meeting the CIPA cyberbullying requirement at school level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completionsmeets_both_cipa_month IS 'Number of distinct students meeting both CIPA requirements at school level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_completions_month IS 'Number of completions (attempt rows) at district level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_events_month IS 'Number of distinct completion events at district level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completions_month IS 'Number of distinct students with a completion at district level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completions_cipa_digital_citizenship_month IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at district level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completions_cipa_cyberbullying_month IS 'Number of distinct students meeting the CIPA cyberbullying requirement at district level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completionsmeets_both_cipa_month IS 'Number of distinct students meeting both CIPA requirements at district level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_completions_month IS 'Number of completions (attempt rows) at state level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_events_month IS 'Number of distinct completion events at state level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completions_month IS 'Number of distinct students with a completion at state level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completions_cipa_digital_citizenship_month IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at state level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completions_cipa_cyberbullying_month IS 'Number of distinct students meeting the CIPA cyberbullying requirement at state level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completionsmeets_both_cipa_month IS 'Number of distinct students meeting both CIPA requirements at state level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_completions_month IS 'Number of completions (attempt rows) at country level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_events_month IS 'Number of distinct completion events at country level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completions_month IS 'Number of distinct students with a completion at country level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completions_cipa_digital_citizenship_month IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at country level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completions_cipa_cyberbullying_month IS 'Number of distinct students meeting the CIPA cyberbullying requirement at country level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completionsmeets_both_cipa_month IS 'Number of distinct students meeting both CIPA requirements at country level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_completions_month IS 'Number of completions (attempt rows) at company level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_events_month IS 'Number of distinct completion events at company level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completions_month IS 'Number of distinct students with a completion at company level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completions_cipa_digital_citizenship_month IS 'Number of distinct students meeting the CIPA digital-citizenship requirement at company level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completions_cipa_cyberbullying_month IS 'Number of distinct students meeting the CIPA cyberbullying requirement at company level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completionsmeets_both_cipa_month IS 'Number of distinct students meeting both CIPA requirements at company level for the snapshot calendar month only.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.loaddate IS 'The time in PST when the record was created.';

{% endset %}

{{ run_DDL('fact_students_completions_monthly_snapshots', create_table_operation) }}

{% endmacro %} 