{% macro create_lc_load_students_completions_monthly_snapshots() %}

 {% set custom_schema = deployment_schema() %}

 {% set create_sp_operation %}



CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_details(columns_level varchar, table_level varchar)
LANGUAGE plpgsql
AS $$
BEGIN

EXECUTE
'CREATE TEMPORARY TABLE ' || table_level ||
' AS
WITH
topics_grades AS (
SELECT
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category,
    user_grade_level_code AS grade_level,
    topic AS topic,
    COUNT(event_aggregate_id) AS cnt_completions,
COUNT(DISTINCT event_aggregate_id) AS cnt_events,
COUNT(DISTINCT user_account_id) AS cnt_student_completions,
COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship,
COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying,
COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa,
COUNT(CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_events_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN user_account_id END) AS cnt_student_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa_month
FROM temp_completions_data_for_snapshot

GROUP BY
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category, user_grade_level_code, topic
),
topics_grade_levels AS (
SELECT
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category,
    CASE
    WHEN user_grade_level_code IN (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'') THEN ''Elementary''
    WHEN user_grade_level_code IN (''06'',''07'',''08'') THEN ''Middle''
    WHEN user_grade_level_code IN (''09'',''10'',''11'',''12'') THEN ''High''
END AS grade_level,
    topic AS topic,
    COUNT(event_aggregate_id) AS cnt_completions,
COUNT(DISTINCT event_aggregate_id) AS cnt_events,
COUNT(DISTINCT user_account_id) AS cnt_student_completions,
COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship,
COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying,
COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa,
COUNT(CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_events_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN user_account_id END) AS cnt_student_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa_month
FROM temp_completions_data_for_snapshot
WHERE user_grade_level_code NOT IN (''Non Students'', ''Unknown'')
GROUP BY
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category, grade_level, topic
),
topics_all_students AS (
SELECT
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category,
    ''All Students'' AS grade_level,
    topic AS topic,
    COUNT(event_aggregate_id) AS cnt_completions,
COUNT(DISTINCT event_aggregate_id) AS cnt_events,
COUNT(DISTINCT user_account_id) AS cnt_student_completions,
COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship,
COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying,
COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa,
COUNT(CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_events_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN user_account_id END) AS cnt_student_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa_month
FROM temp_completions_data_for_snapshot
WHERE user_grade_level_code NOT IN (''Non Students'', ''Unknown'')
GROUP BY
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category, topic
),
all_topics AS (
SELECT
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category,
    user_grade_level_code AS grade_level,
    ''(All)'' AS topic,
    COUNT(event_aggregate_id) AS cnt_completions,
COUNT(DISTINCT event_aggregate_id) AS cnt_events,
COUNT(DISTINCT user_account_id) AS cnt_student_completions,
COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship,
COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying,
COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa,
COUNT(CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_events_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN user_account_id END) AS cnt_student_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa_month
FROM temp_completions_data_for_snapshot

GROUP BY
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category, user_grade_level_code
),
all_topics_grade_levels AS (
SELECT
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category,
    CASE
    WHEN user_grade_level_code IN (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'') THEN ''Elementary''
    WHEN user_grade_level_code IN (''06'',''07'',''08'') THEN ''Middle''
    WHEN user_grade_level_code IN (''09'',''10'',''11'',''12'') THEN ''High''
END AS grade_level,
    ''(All)'' AS topic,
    COUNT(event_aggregate_id) AS cnt_completions,
COUNT(DISTINCT event_aggregate_id) AS cnt_events,
COUNT(DISTINCT user_account_id) AS cnt_student_completions,
COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship,
COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying,
COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa,
COUNT(CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_events_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN user_account_id END) AS cnt_student_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa_month
FROM temp_completions_data_for_snapshot
WHERE user_grade_level_code NOT IN (''Non Students'', ''Unknown'')
GROUP BY
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category, grade_level
),
all_topics_all_students AS (
SELECT
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category,
    ''All Students'' AS grade_level,
    ''(All)'' AS topic,
    COUNT(event_aggregate_id) AS cnt_completions,
COUNT(DISTINCT event_aggregate_id) AS cnt_events,
COUNT(DISTINCT user_account_id) AS cnt_student_completions,
COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship,
COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying,
COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa,
COUNT(CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_events_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN user_account_id END) AS cnt_student_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa_month
FROM temp_completions_data_for_snapshot
WHERE user_grade_level_code NOT IN (''Non Students'', ''Unknown'')
GROUP BY
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category
),
all_grades AS (
SELECT
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category,
    ''(All)'' AS grade_level,
    topic AS topic,
    COUNT(event_aggregate_id) AS cnt_completions,
COUNT(DISTINCT event_aggregate_id) AS cnt_events,
COUNT(DISTINCT user_account_id) AS cnt_student_completions,
COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship,
COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying,
COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa,
COUNT(CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_events_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN user_account_id END) AS cnt_student_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa_month
FROM temp_completions_data_for_snapshot

GROUP BY
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category, topic
),
all_topics_grades AS (
SELECT
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category,
    ''(All)'' AS grade_level,
    ''(All)'' AS topic,
    COUNT(event_aggregate_id) AS cnt_completions,
COUNT(DISTINCT event_aggregate_id) AS cnt_events,
COUNT(DISTINCT user_account_id) AS cnt_student_completions,
COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship,
COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying,
COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa,
COUNT(CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN event_aggregate_id END) AS cnt_events_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) THEN user_account_id END) AS cnt_student_completions_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying_month,
COUNT(DISTINCT CASE WHEN score_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) AND meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa_month
FROM temp_completions_data_for_snapshot

GROUP BY
    mon_year,
    mon_lastday,
    SchoolYear,
    SchoolYear_mon,
    ' ||
columns_level ||
'
    product_category
)
SELECT * FROM topics_grades
UNION ALL SELECT * FROM topics_all_students
UNION ALL SELECT * FROM topics_grade_levels
UNION ALL SELECT * FROM all_topics
UNION ALL SELECT * FROM all_topics_grade_levels
UNION ALL SELECT * FROM all_topics_all_students
UNION ALL SELECT * FROM all_grades
UNION ALL SELECT * FROM all_topics_grades
';

END;
$$;



CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_levels(ploaddate timestamp)
LANGUAGE plpgsql
AS $$
BEGIN

drop table if exists temp_fact_completions_monthly_snapshots_company;
drop table if exists temp_fact_completions_monthly_snapshots_country;
drop table if exists temp_fact_completions_monthly_snapshots_state;
drop table if exists temp_fact_completions_monthly_snapshots_district;
drop table if exists temp_fact_completions_monthly_snapshots_school;

RAISE INFO '- schools level';
CALL {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_details('country, state_province_code, organization_district_id, organization_school_id,', 'temp_fact_completions_monthly_snapshots_school');

RAISE INFO '- districts level';
CALL {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_details('country, state_province_code, organization_district_id,', 'temp_fact_completions_monthly_snapshots_district');

RAISE INFO '- state level';
CALL {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_details('country, state_province_code,', 'temp_fact_completions_monthly_snapshots_state');

RAISE INFO '- country level';
CALL {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_details('country,', 'temp_fact_completions_monthly_snapshots_country');

RAISE INFO '- company level';
CALL {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_details('', 'temp_fact_completions_monthly_snapshots_company');

RAISE INFO 'Insert into fact_students_completions_monthly_snapshots';

insert into {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots
(
mon_year,
mon_lastday,
schoolyear,
schoolyear_mon,
country,
state_province_code,
organization_district_id,
organization_school_id,
product_category,
grade_level,
topic,
school_cnt_completions,
school_cnt_events,
school_cnt_student_completions,
school_cnt_student_completions_cipa_digital_citizenship,
school_cnt_student_completions_cipa_cyberbullying,
school_cnt_student_completionsmeets_both_cipa,
district_cnt_completions,
district_cnt_events,
district_cnt_student_completions,
district_cnt_student_completions_cipa_digital_citizenship,
district_cnt_student_completions_cipa_cyberbullying,
district_cnt_student_completionsmeets_both_cipa,
state_cnt_completions,
state_cnt_events,
state_cnt_student_completions,
state_cnt_student_completions_cipa_digital_citizenship,
state_cnt_student_completions_cipa_cyberbullying,
state_cnt_student_completionsmeets_both_cipa,
country_cnt_completions,
country_cnt_events,
country_cnt_student_completions,
country_cnt_student_completions_cipa_digital_citizenship,
country_cnt_student_completions_cipa_cyberbullying,
country_cnt_student_completionsmeets_both_cipa,
company_cnt_completions,
company_cnt_events,
company_cnt_student_completions,
company_cnt_student_completions_cipa_digital_citizenship,
company_cnt_student_completions_cipa_cyberbullying,
company_cnt_student_completionsmeets_both_cipa,
school_cnt_completions_month,
school_cnt_events_month,
school_cnt_student_completions_month,
school_cnt_student_completions_cipa_digital_citizenship_month,
school_cnt_student_completions_cipa_cyberbullying_month,
school_cnt_student_completionsmeets_both_cipa_month,
district_cnt_completions_month,
district_cnt_events_month,
district_cnt_student_completions_month,
district_cnt_student_completions_cipa_digital_citizenship_month,
district_cnt_student_completions_cipa_cyberbullying_month,
district_cnt_student_completionsmeets_both_cipa_month,
state_cnt_completions_month,
state_cnt_events_month,
state_cnt_student_completions_month,
state_cnt_student_completions_cipa_digital_citizenship_month,
state_cnt_student_completions_cipa_cyberbullying_month,
state_cnt_student_completionsmeets_both_cipa_month,
country_cnt_completions_month,
country_cnt_events_month,
country_cnt_student_completions_month,
country_cnt_student_completions_cipa_digital_citizenship_month,
country_cnt_student_completions_cipa_cyberbullying_month,
country_cnt_student_completionsmeets_both_cipa_month,
company_cnt_completions_month,
company_cnt_events_month,
company_cnt_student_completions_month,
company_cnt_student_completions_cipa_digital_citizenship_month,
company_cnt_student_completions_cipa_cyberbullying_month,
company_cnt_student_completionsmeets_both_cipa_month,
loaddate
)
select
sl.mon_year,
sl.mon_lastday,
sl.SchoolYear,
sl.SchoolYear_mon,
sl.country,
sl.state_province_code,
sl.organization_district_id,
sl.organization_school_id,
sl.product_category,
sl.grade_level,
sl.topic,
sl.cnt_completions as school_cnt_completions,
sl.cnt_events as school_cnt_events,
sl.cnt_student_completions as school_cnt_student_completions,
sl.cnt_student_completions_cipa_digital_citizenship as school_cnt_student_completions_cipa_digital_citizenship,
sl.cnt_student_completions_cipa_cyberbullying as school_cnt_student_completions_cipa_cyberbullying,
sl.cnt_student_completionsmeets_both_cipa as school_cnt_student_completionsmeets_both_cipa,
isnull(dl.cnt_completions,0) as district_cnt_completions,
isnull(dl.cnt_events,0) as district_cnt_events,
isnull(dl.cnt_student_completions,0) as district_cnt_student_completions,
isnull(dl.cnt_student_completions_cipa_digital_citizenship,0) as district_cnt_student_completions_cipa_digital_citizenship,
isnull(dl.cnt_student_completions_cipa_cyberbullying,0) as district_cnt_student_completions_cipa_cyberbullying,
isnull(dl.cnt_student_completionsmeets_both_cipa,0) as district_cnt_student_completionsmeets_both_cipa,
isnull(stl.cnt_completions,0) as state_cnt_completions,
isnull(stl.cnt_events,0) as state_cnt_events,
isnull(stl.cnt_student_completions,0) as state_cnt_student_completions,
isnull(stl.cnt_student_completions_cipa_digital_citizenship,0) as state_cnt_student_completions_cipa_digital_citizenship,
isnull(stl.cnt_student_completions_cipa_cyberbullying,0) as state_cnt_student_completions_cipa_cyberbullying,
isnull(stl.cnt_student_completionsmeets_both_cipa,0) as state_cnt_student_completionsmeets_both_cipa,
isnull(ctl.cnt_completions,0) as country_cnt_completions,
isnull(ctl.cnt_events,0) as country_cnt_events,
isnull(ctl.cnt_student_completions,0) as country_cnt_student_completions,
isnull(ctl.cnt_student_completions_cipa_digital_citizenship,0) as country_cnt_student_completions_cipa_digital_citizenship,
isnull(ctl.cnt_student_completions_cipa_cyberbullying,0) as country_cnt_student_completions_cipa_cyberbullying,
isnull(ctl.cnt_student_completionsmeets_both_cipa,0) as country_cnt_student_completionsmeets_both_cipa,
isnull(cl.cnt_completions,0) as company_cnt_completions,
isnull(cl.cnt_events,0) as company_cnt_events,
isnull(cl.cnt_student_completions,0) as company_cnt_student_completions,
isnull(cl.cnt_student_completions_cipa_digital_citizenship,0) as company_cnt_student_completions_cipa_digital_citizenship,
isnull(cl.cnt_student_completions_cipa_cyberbullying,0) as company_cnt_student_completions_cipa_cyberbullying,
isnull(cl.cnt_student_completionsmeets_both_cipa,0) as company_cnt_student_completionsmeets_both_cipa,
sl.cnt_completions_month as school_cnt_completions_month,
sl.cnt_events_month as school_cnt_events_month,
sl.cnt_student_completions_month as school_cnt_student_completions_month,
sl.cnt_student_completions_cipa_digital_citizenship_month as school_cnt_student_completions_cipa_digital_citizenship_month,
sl.cnt_student_completions_cipa_cyberbullying_month as school_cnt_student_completions_cipa_cyberbullying_month,
sl.cnt_student_completionsmeets_both_cipa_month as school_cnt_student_completionsmeets_both_cipa_month,
isnull(dl.cnt_completions_month,0) as district_cnt_completions_month,
isnull(dl.cnt_events_month,0) as district_cnt_events_month,
isnull(dl.cnt_student_completions_month,0) as district_cnt_student_completions_month,
isnull(dl.cnt_student_completions_cipa_digital_citizenship_month,0) as district_cnt_student_completions_cipa_digital_citizenship_month,
isnull(dl.cnt_student_completions_cipa_cyberbullying_month,0) as district_cnt_student_completions_cipa_cyberbullying_month,
isnull(dl.cnt_student_completionsmeets_both_cipa_month,0) as district_cnt_student_completionsmeets_both_cipa_month,
isnull(stl.cnt_completions_month,0) as state_cnt_completions_month,
isnull(stl.cnt_events_month,0) as state_cnt_events_month,
isnull(stl.cnt_student_completions_month,0) as state_cnt_student_completions_month,
isnull(stl.cnt_student_completions_cipa_digital_citizenship_month,0) as state_cnt_student_completions_cipa_digital_citizenship_month,
isnull(stl.cnt_student_completions_cipa_cyberbullying_month,0) as state_cnt_student_completions_cipa_cyberbullying_month,
isnull(stl.cnt_student_completionsmeets_both_cipa_month,0) as state_cnt_student_completionsmeets_both_cipa_month,
isnull(ctl.cnt_completions_month,0) as country_cnt_completions_month,
isnull(ctl.cnt_events_month,0) as country_cnt_events_month,
isnull(ctl.cnt_student_completions_month,0) as country_cnt_student_completions_month,
isnull(ctl.cnt_student_completions_cipa_digital_citizenship_month,0) as country_cnt_student_completions_cipa_digital_citizenship_month,
isnull(ctl.cnt_student_completions_cipa_cyberbullying_month,0) as country_cnt_student_completions_cipa_cyberbullying_month,
isnull(ctl.cnt_student_completionsmeets_both_cipa_month,0) as country_cnt_student_completionsmeets_both_cipa_month,
isnull(cl.cnt_completions_month,0) as company_cnt_completions_month,
isnull(cl.cnt_events_month,0) as company_cnt_events_month,
isnull(cl.cnt_student_completions_month,0) as company_cnt_student_completions_month,
isnull(cl.cnt_student_completions_cipa_digital_citizenship_month,0) as company_cnt_student_completions_cipa_digital_citizenship_month,
isnull(cl.cnt_student_completions_cipa_cyberbullying_month,0) as company_cnt_student_completions_cipa_cyberbullying_month,
isnull(cl.cnt_student_completionsmeets_both_cipa_month,0) as company_cnt_student_completionsmeets_both_cipa_month,
ploaddate as loaddate
from temp_fact_completions_monthly_snapshots_school sl
left join temp_fact_completions_monthly_snapshots_district dl
on sl.organization_district_id = dl.organization_district_id
and sl.mon_year = dl.mon_year
and sl.product_category = dl.product_category
and sl.grade_level = dl.grade_level
and sl.topic = dl.topic
left join temp_fact_completions_monthly_snapshots_state stl
on sl.country = stl.country
and sl.state_province_code = stl.state_province_code
and sl.mon_year = stl.mon_year
and sl.product_category = stl.product_category
and sl.grade_level = stl.grade_level
and sl.topic = stl.topic
left join temp_fact_completions_monthly_snapshots_country ctl
on sl.country = ctl.country
and sl.mon_year = ctl.mon_year
and sl.product_category = ctl.product_category
and sl.grade_level = ctl.grade_level
and sl.topic = ctl.topic
left join temp_fact_completions_monthly_snapshots_company cl
on sl.mon_year = cl.mon_year
and sl.product_category = cl.product_category
and sl.grade_level = cl.grade_level
and sl.topic = cl.topic;

drop table if exists temp_fact_completions_monthly_snapshots_company;
drop table if exists temp_fact_completions_monthly_snapshots_country;
drop table if exists temp_fact_completions_monthly_snapshots_state;
drop table if exists temp_fact_completions_monthly_snapshots_district;
drop table if exists temp_fact_completions_monthly_snapshots_school;

END;
$$;




CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots()
LANGUAGE plpgsql
AS $$
BEGIN
    call {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots(GetDate());
END;
$$;




CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots(ploaddate timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
    latest_month_year int;
BEGIN
    select to_char(max(cast(score_datetime as date)),'yyyymm') into latest_month_year
    from {{ source("dbo","fact_assignment_completion") }};

    call {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots(latest_month_year, ploaddate);
END;
$$;




CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots(pmonth_year int4, ploaddate timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
    product_categories record;
BEGIN

RAISE INFO 'Processing %...', pmonth_year;

delete from {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots
where mon_year = pmonth_year;

drop table if exists temp_base_completions_data_for_snapshot;

create temporary table temp_base_completions_data_for_snapshot as
with dim_month as (
    select
        mon_year,
        mon_firstday,
        mon_lastday,
        SchoolYear,
        SchoolYear_StartDate,
        SchoolYear_EndDate,
        SchoolYear_mon
    from {{ ref("dim_month") }}
    where mon_year = pmonth_year
)
select
    dt.mon_year,
    dt.mon_firstday,
    dt.mon_lastday,
    dt.SchoolYear,
    dt.SchoolYear_mon,
    fac.event_aggregate_id,
    fac.learning_object_id,
    isnull(fac.organization_district_id,'00000000-0000-0000-0000-000000000000') as organization_district_id,
    dist.lcom_country_name as country,
    dist.lcom_state_province_code as state_province_code,
    case
        when fac.organization_school_id='00000000-0000-0000-0000-000000000000' then fac.organization_district_id
        when len(fac.organization_school_id)<2 then fac.organization_district_id
        else isnull(split_part(fac.organization_school_id, ',', 1), fac.organization_district_id)
    end as organization_school_id,
    case when st.user_account_id is null then 'Non Students' else isnull(fac.user_grade_level_code,'Unknown') end as user_grade_level_code,
    fac.user_account_id,
    dlo.topic,
    dlo.meets_digital_citizenship_cipa,
    dlo.meets_cyberbullying_cipa,
    dlo.meets_both_cipa,
    timezone('UTC', fac.score_datetime) as score_datetime
from {{ source("dbo","fact_assignment_completion") }} fac
join {{ ref("dim_learning_object") }} dlo
  on fac.learning_object_id = dlo.learning_object_id
left join {{ source("dbo","mv_student_account") }} st
  on fac.user_account_id = st.user_account_id
 and fac.organization_district_id = st.organization_district_id
join {{ ref("dim_district") }} dist
  on fac.organization_district_id = dist.district_id
join dim_month dt
  on timezone('UTC', fac.score_datetime) between dt.SchoolYear_StartDate and dateadd(day, 1, dt.mon_lastday)
 and timezone('UTC', fac.score_datetime) < dt.SchoolYear_EndDate;


----------------------------------------------------------
-- Large Categories
----------------------------------------------------------
RAISE INFO 'Processing Large Categories one by one...';

FOR product_categories IN (
select 'EasyTech & TechApps for Texas' product_category union all
select 'TechApps for Texas' union all
select 'EasyTech' union all
select 'EasyTech without Common Sense Education' union all
select 'EasyTech Student-Driven Learning Path' union all
select 'EasyTech Blended Learning Path' union all
select 'Tech Quest' union all
select 'Texas Blended Learning Path'
)
LOOP
    RAISE INFO 'Processing %', product_categories.product_category;

    drop table if exists temp_product_categories_learning_objects;
    create temporary table temp_product_categories_learning_objects as
    select distinct product_category, learning_object_id, fromdate, todate
    from {{ ref("dim_product_category_learning_object_monthly") }}
    where mon_year = pmonth_year
      and product_category = product_categories.product_category;

    create temporary table temp_completions_data_for_snapshot as
    select
        b.mon_year,
        b.mon_firstday,
        b.mon_lastday,
        b.SchoolYear,
        b.SchoolYear_mon,
        b.event_aggregate_id,
        b.organization_district_id,
        b.country,
        b.state_province_code,
        b.organization_school_id,
        pc.product_category,
        b.user_grade_level_code,
        b.user_account_id,
        b.topic,
        b.meets_digital_citizenship_cipa,
        b.meets_cyberbullying_cipa,
        b.meets_both_cipa,
        b.score_datetime
    from temp_base_completions_data_for_snapshot b
    join temp_product_categories_learning_objects pc
      on b.learning_object_id = pc.learning_object_id;

    CALL content_delivery_usage.lc_load_students_completions_monthly_snapshots_levels(ploaddate);

    drop table if exists temp_completions_data_for_snapshot;
    drop table if exists temp_product_categories_learning_objects;
END LOOP;

----------------------------------------------------------
-- Medium Categories
----------------------------------------------------------
RAISE INFO 'Processing Medium Categories together...';

drop table if exists temp_product_categories_learning_objects;
create temporary table temp_product_categories_learning_objects as
select distinct product_category, learning_object_id, fromdate, todate
from content_delivery_usage.dim_product_category_learning_object_monthly
where mon_year = pmonth_year
  and product_category in ('Digital Readiness','Texas Essentials Blended Learning Path');

create temporary table temp_completions_data_for_snapshot as
select
    b.mon_year, b.mon_firstday, b.mon_lastday, b.SchoolYear, b.SchoolYear_mon,
    b.event_aggregate_id, b.organization_district_id, b.country, b.state_province_code,
    b.organization_school_id, pc.product_category, b.user_grade_level_code, b.user_account_id,
    b.topic, b.meets_digital_citizenship_cipa, b.meets_cyberbullying_cipa, b.meets_both_cipa,
    b.score_datetime
from temp_base_completions_data_for_snapshot b
join temp_product_categories_learning_objects pc
  on b.learning_object_id = pc.learning_object_id;

CALL {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_levels(ploaddate);

drop table if exists temp_completions_data_for_snapshot;
drop table if exists temp_product_categories_learning_objects;

----------------------------------------------------------
-- Small Categories
----------------------------------------------------------
RAISE INFO 'Processing Small Categories together...';

drop table if exists temp_product_categories_learning_objects;
create temporary table temp_product_categories_learning_objects as
select distinct product_category, learning_object_id, fromdate, todate
from content_delivery_usage.dim_product_category_learning_object_monthly
where mon_year = pmonth_year
  and product_category in (
      'Online Safety & Digital Citizenship',
      'Digital Safety Foundation',
      'Keyboarding & Word Processing',
      'EasyCode',
      'EasyCode Pillars',
      'Common Sense Education',
      'EasyCode Foundations',
      'Assessments'
  );

create temporary table temp_completions_data_for_snapshot as
select
    b.mon_year, b.mon_firstday, b.mon_lastday, b.SchoolYear, b.SchoolYear_mon,
    b.event_aggregate_id, b.organization_district_id, b.country, b.state_province_code,
    b.organization_school_id, pc.product_category, b.user_grade_level_code, b.user_account_id,
    b.topic, b.meets_digital_citizenship_cipa, b.meets_cyberbullying_cipa, b.meets_both_cipa,
    b.score_datetime
from temp_base_completions_data_for_snapshot b
join temp_product_categories_learning_objects pc
  on b.learning_object_id = pc.learning_object_id;

CALL {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_levels(ploaddate);

drop table if exists temp_completions_data_for_snapshot;
drop table if exists temp_product_categories_learning_objects;

----------------------------------------------------------
-- New 2026 Categories
----------------------------------------------------------
RAISE INFO 'Processing New 2026 Categories together...';

drop table if exists temp_product_categories_learning_objects;
create temporary table temp_product_categories_learning_objects as
select distinct product_category, learning_object_id, fromdate, todate
from content_delivery_usage.dim_product_category_learning_object_monthly
where mon_year = pmonth_year
  and product_category in (
      'AI Literacy','AI Literacy (Limited)','AI Literacy Student-Driven Learning Path',
      'EasyTech Florida Blended Learning Path',
      'EasyTech Florida Student-Driven Learning Path','EasyTech+','Fontana Tech Quest',
      'Safe into Summer'
  );

create temporary table temp_completions_data_for_snapshot as
select
    b.mon_year, b.mon_firstday, b.mon_lastday, b.SchoolYear, b.SchoolYear_mon,
    b.event_aggregate_id, b.organization_district_id, b.country, b.state_province_code,
    b.organization_school_id, pc.product_category, b.user_grade_level_code, b.user_account_id,
    b.topic, b.meets_digital_citizenship_cipa, b.meets_cyberbullying_cipa, b.meets_both_cipa,
    b.score_datetime
from temp_base_completions_data_for_snapshot b
join temp_product_categories_learning_objects pc
  on b.learning_object_id = pc.learning_object_id;

CALL {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_levels(ploaddate);

drop table if exists temp_completions_data_for_snapshot;
drop table if exists temp_product_categories_learning_objects;

----------------------------------------------------------
-- All
----------------------------------------------------------
RAISE INFO 'Processing (All)...';

create temporary table temp_completions_data_for_snapshot as
select
    b.mon_year,
    b.mon_firstday,
    b.mon_lastday,
    b.SchoolYear,
    b.SchoolYear_mon,
    b.event_aggregate_id,
    b.organization_district_id,
    b.country,
    b.state_province_code,
    b.organization_school_id,
    '(All)'::varchar(100) as product_category,
    b.user_grade_level_code,
    b.user_account_id,
    b.topic,
    b.meets_digital_citizenship_cipa,
    b.meets_cyberbullying_cipa,
    b.meets_both_cipa,
    b.score_datetime
from temp_base_completions_data_for_snapshot b;

CALL {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_levels(ploaddate);

drop table if exists temp_completions_data_for_snapshot;


drop table if exists temp_base_completions_data_for_snapshot;

END;
$$;





/*-------------------------------------------------------------------------------------*/

  {% endset %}


 {{ run_DDL('lc_load_students_completions_monthly_snapshots', create_sp_operation) }}


 
 {% endmacro %}