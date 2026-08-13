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
,loaddate TIMESTAMP WITHOUT TIME ZONE NOT NULL ENCODE az64
)
DISTSTYLE KEY
DISTKEY (organization_district_id)
SORTKEY (
mon_year
)
;


COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.schoolyear IS 'Calendar years in School Year like 2024/2025';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.schoolyear_mon IS 'School Year Month number starting from July - 1 , ending June - 12';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.mon_year IS 'Calendar Year and Month in a form YYYYMM';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.mon_lastday IS 'Calendar Month Last day';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country IS 'Defines Country level for country_cnt_students and country_students_launches';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_province_code IS 'Defines State level for state_cnt_students and state_students_launches along with Country';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.organization_district_id IS 'Defines District level for district_cnt_students and district_students_launches along with Country and State';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.organization_school_id IS 'The lowelest level in this table School for school_cnt_students and school_students_launches';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.grade_level IS '(All), PK, K, 01 or Elementary-Middle-High all levels of aggregation for all use vases. Unknown is for Students only where grade is unknown. Non-Students are not included';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.topic IS 'All available topics';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_completions IS 'Number of completions (attempts, scored or not) records at school level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_events IS 'Number of completion events at school level. Event is a combination of the same student attempts for the same learning object. In most cases, it`s in the same school year, but there are some cases when the same event started in one year and continued in the next year with 10 months difference. In few other cases there are separate events for teh same student and learning object in teh same school year.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completions IS 'Number of students with a completion (attempt, scored or not) at school level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completions_cipa_digital_citizenship IS 'Number of students meeting the CIPA digital-citizenship requirement via completions at school level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completions_cipa_cyberbullying IS 'Number of students meeting the CIPA cyberbullying requirement at school level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.school_cnt_student_completionsmeets_both_cipa IS 'Number of students meeting both CIPA flags at school level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_completions IS 'Number of completions (attempts, scored or not) records at district level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_events IS 'Number of completion events at district level. Event is a combination of the same student attempts for the same learning object. In most cases, it`s in the same district year, but there are some cases when the same event started in one year and continued in the next year with 10 months difference. In few other cases there are separate events for teh same student and learning object in teh same district year.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completions IS 'Number of students with a completion (attempt, scored or not) at district level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completions_cipa_digital_citizenship IS 'Number of students meeting the CIPA digital-citizenship requirement via completions at district level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completions_cipa_cyberbullying IS 'Number of students meeting the CIPA cyberbullying requirement at district level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.district_cnt_student_completionsmeets_both_cipa IS 'Number of students meeting both CIPA flags at district level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_completions IS 'Number of completions (attempts, scored or not) records at state level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_events IS 'Number of completion events at state level. Event is a combination of the same student attempts for the same learning object. In most cases, it`s in the same state year, but there are some cases when the same event started in one year and continued in the next year with 10 months difference. In few other cases there are separate events for teh same student and learning object in teh same state year.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completions IS 'Number of students with a completion (attempt, scored or not) at state level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completions_cipa_digital_citizenship IS 'Number of students meeting the CIPA digital-citizenship requirement via completions at state level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completions_cipa_cyberbullying IS 'Number of students meeting the CIPA cyberbullying requirement at state level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.state_cnt_student_completionsmeets_both_cipa IS 'Number of students meeting both CIPA flags at state level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_completions IS 'Number of completions (attempts, scored or not) records at country level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_events IS 'Number of completion events at country level. Event is a combination of the same student attempts for the same learning object. In most cases, it`s in the same country year, but there are some cases when the same event started in one year and continued in the next year with 10 months difference. In few other cases there are separate events for teh same student and learning object in teh same country year.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completions IS 'Number of students with a completion (attempt, scored or not) at country level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completions_cipa_digital_citizenship IS 'Number of students meeting the CIPA digital-citizenship requirement via completions at country level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completions_cipa_cyberbullying IS 'Number of students meeting the CIPA cyberbullying requirement at country level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.country_cnt_student_completionsmeets_both_cipa IS 'Number of students meeting both CIPA flags at country level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_completions IS 'Number of completions (attempts, scored or not) records at company level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_events IS 'Number of completion events at company level. Event is a combination of the same student attempts for the same learning object. In most cases, it`s in the same company year, but there are some cases when the same event started in one year and continued in the next year with 10 months difference. In few other cases there are separate events for teh same student and learning object in teh same company year.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completions IS 'Number of students with a completion (attempt, scored or not) at company level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completions_cipa_digital_citizenship IS 'Number of students meeting the CIPA digital-citizenship requirement via completions at company level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completions_cipa_cyberbullying IS 'Number of students meeting the CIPA cyberbullying requirement at company level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.company_cnt_student_completionsmeets_both_cipa IS 'Number of students meeting both CIPA flags at company level.';
COMMENT ON COLUMN {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots.loaddate is 'The time in PST when the record was created';

{% endset %}

{{ run_DDL('fact_students_completions_monthly_snapshots', create_table_operation) }}

{% endmacro %} 