{% macro create_lc_load_students_completions_monthly_snapshots() %}

 {% set custom_schema = deployment_schema() %}

 {% set create_sp_operation %}

CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots_details
(
columns_level varchar, -- e.g. 'country, state_province_code, organization_district_id, organization_school_id, '
table_level varchar -- final temporary table name, e.g. 'school_level'
)
LANGUAGE plpgsql
AS $$
BEGIN

/**************************************************************************************************
* Name: lc_load_students_completions_monthly_snapshots_details
* Description: The procedure is used to calculate aggregates at different levels from temp_completions_data_for_snapshot temporary table created in lc_load_students_completions_monthly_snapshots
* 
* Author: kdrogaieva
* Date Created: 2025NOV03
*
*
* Notes: The procedure is called from lc_load_students_completions_monthly_snapshots with different columns_level parameter
*
* 
**************************************************************************************************/

EXECUTE
'CREATE TEMPORARY TABLE ' || table_level || ' AS ' ||
'WITH ' ||

/* 1. Topics and Grades */
'topics_grades AS ( ' ||
' SELECT ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' user_grade_level_code grade_level, ' ||
' topic, ' ||
' COUNT(event_aggregate_id) AS cnt_completions, ' ||
' COUNT(DISTINCT event_aggregate_id) AS cnt_events, ' ||
' COUNT(DISTINCT user_account_id) AS cnt_student_completions, ' ||
' COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship, ' ||
' COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying, ' ||
' COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa ' ||
' FROM temp_completions_data_for_snapshot ' ||
' GROUP BY ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' user_grade_level_code, ' ||
' topic ' ||
'), ' ||

/* 1.5 Topics and Grade Levels */
'topics_grade_levels AS ( ' ||
' SELECT ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' case ' ||
' when user_grade_level_code in (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'') then ''Elementary'' ' ||
' when user_grade_level_code in (''06'',''07'',''08'') then ''Middle'' ' ||
' when user_grade_level_code in (''09'',''10'',''11'',''12'') then ''High'' ' ||
' end as grade_level, ' ||
' topic, ' ||
' COUNT(event_aggregate_id) AS cnt_completions, ' ||
' COUNT(DISTINCT event_aggregate_id) AS cnt_events, ' ||
' COUNT(DISTINCT user_account_id) AS cnt_student_completions, ' ||
' COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship, ' ||
' COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying, ' ||
' COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa ' ||
' FROM temp_completions_data_for_snapshot ' ||
' WHERE user_grade_level_code!=''Unknown'' ' ||
' GROUP BY ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' grade_level, ' ||
' topic ' ||
'), ' ||

/* 2. <All> Topics and Grades */
'all_topics AS ( ' ||
' SELECT ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' user_grade_level_code grade_level, ' ||
' ''(All)'' AS topic, ' ||
' COUNT(event_aggregate_id) AS cnt_completions, ' ||
' COUNT(DISTINCT event_aggregate_id) AS cnt_events, ' ||
' COUNT(DISTINCT user_account_id) AS cnt_student_completions, ' ||
' COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship, ' ||
' COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying, ' ||
' COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa ' ||
' FROM temp_completions_data_for_snapshot data ' ||
' GROUP BY ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' user_grade_level_code ' ||
'), ' ||

/* 2. <All> Topics and Grades */
'all_topics_grade_levels AS ( ' ||
' SELECT ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' case ' ||
' when user_grade_level_code in (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'') then ''Elementary'' ' ||
' when user_grade_level_code in (''06'',''07'',''08'') then ''Middle'' ' ||
' when user_grade_level_code in (''09'',''10'',''11'',''12'') then ''High'' ' ||
' end as grade_level, ' ||
' ''(All)'' AS topic, ' ||
' COUNT(event_aggregate_id) AS cnt_completions, ' ||
' COUNT(DISTINCT event_aggregate_id) AS cnt_events, ' ||
' COUNT(DISTINCT user_account_id) AS cnt_student_completions, ' ||
' COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship, ' ||
' COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying, ' ||
' COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa ' ||
' FROM temp_completions_data_for_snapshot data ' ||
' WHERE user_grade_level_code!=''Unknown'' ' ||
' GROUP BY ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' grade_level ' ||
'), ' ||

/* 3. Topics and <All> Grade */
'all_grades AS ( ' ||
' SELECT ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' ''(All)'' AS grade_level, ' ||
' topic, ' ||
' COUNT(event_aggregate_id) AS cnt_completions, ' ||
' COUNT(DISTINCT event_aggregate_id) AS cnt_events, ' ||
' COUNT(DISTINCT user_account_id) AS cnt_student_completions, ' ||
' COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship, ' ||
' COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying, ' ||
' COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa ' ||
' FROM temp_completions_data_for_snapshot data ' ||
' GROUP BY ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' topic ' ||
'), ' ||

/* 4. <All> Topics and <All> Grades */
'all_topics_grades AS ( ' ||
' SELECT ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' ''(All)'' AS grade_level, ' ||
' ''(All)'' AS topic, ' ||
' COUNT(event_aggregate_id) AS cnt_completions, ' ||
' COUNT(DISTINCT event_aggregate_id) AS cnt_events, ' ||
' COUNT(DISTINCT user_account_id) AS cnt_student_completions, ' ||
' COUNT(DISTINCT CASE WHEN meets_digital_citizenship_cipa THEN user_account_id END) AS cnt_student_completions_cipa_digital_citizenship, ' ||
' COUNT(DISTINCT CASE WHEN meets_cyberbullying_cipa THEN user_account_id END) AS cnt_student_completions_cipa_cyberbullying, ' ||
' COUNT(DISTINCT CASE WHEN meets_both_cipa THEN user_account_id END) AS cnt_student_completionsmeets_both_cipa ' ||
' FROM temp_completions_data_for_snapshot data ' ||
' GROUP BY ' ||
' mon_year, ' ||
' mon_lastday, ' ||
' SchoolYear, ' ||
' SchoolYear_mon, ' ||
columns_level ||
' 1 ' || -- keeps syntax valid even if columns_level is empty
') ' ||

'SELECT * FROM topics_grades ' ||
'UNION ALL ' ||
'SELECT * FROM topics_grade_levels ' ||
'UNION ALL ' ||
'SELECT * FROM all_topics ' ||
'UNION ALL ' ||
'SELECT * FROM all_topics_grade_levels ' ||
'UNION ALL ' ||
'SELECT * FROM all_grades ' ||
'UNION ALL ' ||
'SELECT * FROM all_topics_grades ' ;

END;
$$;


/*-------------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots(pmonth_year int4, ploaddate timestamp)
LANGUAGE plpgsql
AS $$
BEGIN


/**************************************************************************************************
* Name: lc_load_students_completions_monthly_snapshots
* Description: The procedure is used to populate with pre-calculated aggregates main table: content_delivery_usage.fact_students_completions_monthly_snapshots
* 
* Author: kdrogaieva
* Date Created: 2025NOV03
*
*
*
* 
**************************************************************************************************/


RAISE INFO 'Processing %...',pmonth_year;


RAISE INFO 'Creating base temp table';

drop table if exists temp_completions_data_for_snapshot;
create temporary table temp_completions_data_for_snapshot as (
with dim_month as (
select mon_year, mon_lastday, SchoolYear, SchoolYear_StartDate, SchoolYear_EndDate, SchoolYear_mon
from {{ ref("dim_month") }}
--where mon_lastday between pstart_date and pend_date
where mon_year = pmonth_year
)
select
dt.mon_year,
dt.mon_lastday,
dt.SchoolYear,
dt.SchoolYear_mon,
fac.event_aggregate_id,
isnull(fac.organization_district_id,'00000000-0000-0000-0000-000000000000') as organization_district_id,
dist.lcom_country_name as country,
dist.lcom_state_province_code as state_province_code,
case
when fac.organization_school_id='00000000-0000-0000-0000-000000000000' then
fac.organization_district_id
when len(fac.organization_school_id)<2 then
fac.organization_district_id
else
isnull(SPLIT_PART(fac.organization_school_id, ',', 1),fac.organization_district_id)
end as organization_school_id,
isnull(fac.user_grade_level_code,'Unknown') as user_grade_level_code,
fac.user_account_id,
dlo.topic,
dlo.meets_digital_citizenship_cipa,
dlo.meets_cyberbullying_cipa,
dlo.meets_both_cipa,
fac.score_datetime
from {{ source('dbo', 'fact_assignment_completion') }} fac
join {{ ref('dim_learning_object') }} dlo
on fac.learning_object_id = dlo.learning_object_id
join {{ source('dbo', 'mv_student_account') }} st
on fac.user_account_id=st.user_account_id and fac.organization_district_id=st.organization_district_id
join {{ ref('dim_district') }} dist
on fac.organization_district_id = dist.district_id
JOIN dim_month dt
ON TIMEZONE('UTC', fac.score_datetime) BETWEEN dt.SchoolYear_StartDate AND DATEADD(day, 1, dt.mon_lastday)
AND TIMEZONE('UTC', fac.score_datetime) < dt.SchoolYear_EndDate
);

drop table if exists temp_fact_completions_monthly_snapshots_company;
drop table if exists temp_fact_completions_monthly_snapshots_country;
drop table if exists temp_fact_completions_monthly_snapshots_state;
drop table if exists temp_fact_completions_monthly_snapshots_district;
drop table if exists temp_fact_completions_monthly_snapshots_school;

RAISE INFO '- schools level';
CALL content_delivery_usage.lc_load_students_completions_monthly_snapshots_details('country, state_province_code, organization_district_id, organization_school_id,', 'temp_fact_completions_monthly_snapshots_school');

RAISE INFO '- districts level';
CALL content_delivery_usage.lc_load_students_completions_monthly_snapshots_details('country, state_province_code, organization_district_id,', 'temp_fact_completions_monthly_snapshots_district');

RAISE INFO '- state level';
CALL content_delivery_usage.lc_load_students_completions_monthly_snapshots_details('country, state_province_code,', 'temp_fact_completions_monthly_snapshots_state');

RAISE INFO '- country level';
CALL content_delivery_usage.lc_load_students_completions_monthly_snapshots_details('country,', 'temp_fact_completions_monthly_snapshots_country');

RAISE INFO '- company level';
CALL content_delivery_usage.lc_load_students_completions_monthly_snapshots_details('', 'temp_fact_completions_monthly_snapshots_company');

RAISE INFO 'Insert into fact_students_completions_monthly_snapshots';


--drop table if exists content_delivery_usage.fact_students_completions_monthly_snapshots;
--create table content_delivery_usage.fact_students_completions_monthly_snapshots as

delete from {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots
where mon_year= pmonth_year;

insert into {{target.database}}.{{custom_schema}}.fact_students_completions_monthly_snapshots
select
sl.mon_year,
sl.mon_lastday,
sl.SchoolYear,
sl.SchoolYear_mon,
sl.country,
sl.state_province_code,
sl.organization_district_id,
sl.organization_school_id,
sl.grade_level,
sl.topic,
sl.cnt_completions as school_cnt_completions,
sl.cnt_events as school_cnt_events,
sl.cnt_student_completions as school_cnt_student_completions,
sl.cnt_student_completions_cipa_digital_citizenship as school_cnt_student_completions_cipa_digital_citizenship,
sl.cnt_student_completions_cipa_cyberbullying as school_cnt_student_completions_cipa_cyberbullying,
sl.cnt_student_completionsmeets_both_cipa as school_cnt_student_completionsmeets_both_cipa,
--
isnull(dl.cnt_completions,0) as district_cnt_completions,
isnull(dl.cnt_events,0) as district_cnt_events,
isnull(dl.cnt_student_completions,0) as district_cnt_student_completions,
isnull(dl.cnt_student_completions_cipa_digital_citizenship,0) as district_cnt_student_completions_cipa_digital_citizenship,
isnull(dl.cnt_student_completions_cipa_cyberbullying,0) as district_cnt_student_completions_cipa_cyberbullying,
isnull(dl.cnt_student_completionsmeets_both_cipa,0) as district_cnt_student_completionsmeets_both_cipa,
--
isnull(stl.cnt_completions,0) as state_cnt_completions,
isnull(stl.cnt_events,0) as state_cnt_events,
isnull(stl.cnt_student_completions,0) as state_cnt_student_completions,
isnull(stl.cnt_student_completions_cipa_digital_citizenship,0) as state_cnt_student_completions_cipa_digital_citizenship,
isnull(stl.cnt_student_completions_cipa_cyberbullying,0) as state_cnt_student_completions_cipa_cyberbullying,
isnull(stl.cnt_student_completionsmeets_both_cipa,0) as state_cnt_student_completionsmeets_both_cipa,
--
isnull(ctl.cnt_completions,0) as country_cnt_completions,
isnull(ctl.cnt_events,0) as country_cnt_events,
isnull(ctl.cnt_student_completions,0) as country_cnt_student_completions,
isnull(ctl.cnt_student_completions_cipa_digital_citizenship,0) as country_cnt_student_completions_cipa_digital_citizenship,
isnull(ctl.cnt_student_completions_cipa_cyberbullying,0) as country_cnt_student_completions_cipa_cyberbullying,
isnull(ctl.cnt_student_completionsmeets_both_cipa,0) as country_cnt_student_completionsmeets_both_cipa,
--
isnull(cl.cnt_completions,0) as company_cnt_completions,
isnull(cl.cnt_events,0) as company_cnt_events,
isnull(cl.cnt_student_completions,0) as company_cnt_student_completions,
isnull(cl.cnt_student_completions_cipa_digital_citizenship,0) as company_cnt_student_completions_cipa_digital_citizenship,
isnull(cl.cnt_student_completions_cipa_cyberbullying,0) as company_cnt_student_completions_cipa_cyberbullying,
isnull(cl.cnt_student_completionsmeets_both_cipa,0) as company_cnt_student_completionsmeets_both_cipa,
--
ploaddate as loaddate
from temp_fact_completions_monthly_snapshots_school sl
--
left outer join temp_fact_completions_monthly_snapshots_district dl
on sl.grade_level = dl.grade_level
and sl.topic = dl.topic
and sl.organization_district_id = dl.organization_district_id
and sl.mon_year = dl.mon_year
--
left outer join temp_fact_completions_monthly_snapshots_state stl
on sl.grade_level = stl.grade_level
and sl.topic = stl.topic
and sl.country = stl.country
and sl.state_province_code = stl.state_province_code
and sl.mon_year = stl.mon_year
--
left outer join temp_fact_completions_monthly_snapshots_country ctl
on sl.grade_level = ctl.grade_level
and sl.topic = ctl.topic
and sl.country = ctl.country
and sl.mon_year = ctl.mon_year
--
left outer join temp_fact_completions_monthly_snapshots_company cl
on sl.grade_level = cl.grade_level
and sl.topic = cl.topic
and sl.mon_year = cl.mon_year;

drop table if exists temp_fact_completions_monthly_snapshots_company;
drop table if exists temp_fact_completions_monthly_snapshots_country;
drop table if exists temp_fact_completions_monthly_snapshots_state;
drop table if exists temp_fact_completions_monthly_snapshots_district;
drop table if exists temp_fact_completions_monthly_snapshots_school;
drop table if exists temp_completions_data_for_snapshot;

END;




$$
;


/*-------------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots(ploaddate timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
latest_month_year int;
begin

/**************************************************************************************************
* Name: Overloading of lc_load_students_completions_monthly_snapshots
* Description: Runs lc_load_students_completions_monthly_snapshots for the month based on the latest available date (score_datetime) in the source table: content_delivery_usage.dbo.fact_assignment_completion
* It can be used in an orchestrated daily run to update current month when the same LoadDate is set for all tables
* Author: kdrogaieva
* Date Created: 202NOV03
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested month
*
* 
**************************************************************************************************/

select to_char(max(cast(score_datetime as date)),'yyyymm') into latest_month_year
from {{ source("dbo", "fact_assignment_completion") }};

call {{ custom_schema }}.lc_load_students_completions_monthly_snapshots(latest_month_year, ploaddate);



END;



$$
;

/*-------------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_students_completions_monthly_snapshots(pstart_date date, pend_date date, ploaddate timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
DECLARE
rec RECORD;
begin

/**************************************************************************************************
* Name: Overloading of lc_load_students_completions_monthly_snapshots
* Description: Runs lc_load_students_completions_monthly_snapshots for the months mon_firstday between pstart_date and pend_date
* 
* Author: kdrogaieva
* Date Created: 202NOV03
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested month
*
* 
**************************************************************************************************/

FOR rec IN (SELECT mon_year FROM common.dim_month WHERE mon_firstday between pstart_date and pend_date) LOOP


call {{ custom_schema }}.lc_load_students_completions_monthly_snapshots(rec.mon_year, ploaddate);


END LOOP;

END;



$$
;

/*-------------------------------------------------------------------------------------*/

  {% endset %}


 {{ run_DDL('lc_load_students_completions_monthly_snapshots', create_sp_operation) }}


 
 {% endmacro %}