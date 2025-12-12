{% macro create_lc_load_students_usage_monthly_snapshots() %}
 {% set create_sp_operation %}
CREATE OR REPLACE PROCEDURE content_delivery_usage.lc_load_students_usage_monthly_snapshots(pmonth_year int4, ploaddate timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
product_categories record;
BEGIN

/**************************************************************************************************
* Name: lc_load_students_usage_monthly_snapshots
* Description: Cumulative school year monthly launches and users numbers at different levels of granularity: school,district,state,country,company,grade_level,topic,some selected sku and sequences
* 
* Author: kdrogaieva
* Date Created: 2025JUN10
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested months
*
* 
**************************************************************************************************/
RAISE INFO 'processing %...',pmonth_year;

delete from content_delivery_usage.fact_students_usage_monthly_snapshots
where mon_year=pmonth_year;


drop table if exists temp_base_data_for_snapshot;

create temporary table temp_base_data_for_snapshot as
with
dim_date as (select distinct SchoolYear, SchoolYear_StartDate, SchoolYear_EndDate, SchoolYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year
from common.dim_calendar
where Mon_Year= pmonth_year
)
select
distinct
dt.SchoolYear,
dt.SchoolYear_Mon,
dt.Mon_Year,
dt.Mon_FirstDay,
dt.Mon_LastDay,
dist.lcom_country_name as country,
dist.lcom_state_province_code as state_province_code,
fal.organization_district_id,
case
when fal.organization_school_id='00000000-0000-0000-0000-000000000000' then
fal.organization_district_id
when len(fal.organization_school_id)<2 then
fal.organization_district_id
else
isnull(fal.organization_school_id,fal.organization_district_id)
end organization_school_id,
case when st.user_account_id is null then 'Non Students' else isnull(fal.user_grade_level_code,'Unknown') end as grade_level,
fal.learning_object_id,
dlo.Topic as Topic,
TIMEZONE('UTC', fal.launch_datetime) launch_datetime,
fal.user_account_id,
fal.assignment_launch_id
from content_delivery_usage.dbo.fact_assignment_launch fal
join common.dim_district dist
on fal.organization_district_id = dist.district_id
join content_delivery_usage.dim_learning_object dlo
on fal.learning_object_id=dlo.learning_object_id
left outer join content_delivery_usage.dbo.mv_student_account st
on fal.user_account_id=st.user_account_id and fal.organization_district_id=st.organization_district_id
join dim_date dt
on TIMEZONE('UTC', fal.launch_datetime) between dt.SchoolYear_StartDate and DATEADD(day,1,dt.Mon_LastDay)
where dist.lcom_trial = false
and dist.lcom_demo = false ;




----------------------------------------------------------
--Large Categories
----------------------------------------------------------


RAISE INFO 'Processing Large Categories one by one...';


FOR product_categories IN (


select 'EasyTech & TechApps for Texas' Product_Category union all
select 'TechApps for Texas' Product_Category union all
select 'EasyTech' Product_Category union all
select 'EasyTech without Common Sense Education' Product_Category union all
select 'EasyTech Student-Driven Learning Path' Product_Category union all
select 'EasyTech Blended Learning Path' Product_Category union all
select 'Tech Quest' Product_Category union all
select 'Texas Blended Learning Path')

LOOP

RAISE INFO 'Processing %', product_categories.product_category;
drop table if exists temp_product_categories_learning_objects;
create temporary table temp_product_categories_learning_objects as
select distinct product_category, learning_object_id, fromdate,todate
from dw.content_delivery_usage.dim_product_category_learning_object_monthly dpclom
where dpclom.mon_year=pmonth_year
and product_category=product_categories.product_category;

--drop table if exists temp_usage_data_for_snapshot;
create temporary table temp_usage_data_for_snapshot as
select
distinct
fal.SchoolYear,
fal.SchoolYear_Mon,
fal.Mon_Year,
fal.Mon_FirstDay,
fal.Mon_LastDay,
fal.country,
fal.state_province_code,
fal.organization_district_id,
fal.organization_school_id,
dlslo.product_category,
fal.grade_level,
fal.Topic as Topic,
--
fal.user_account_id,
--
fal.assignment_launch_id,
--
fal.launch_datetime
from temp_base_data_for_snapshot fal
join temp_product_categories_learning_objects dlslo
on fal.learning_object_id=dlslo.learning_object_id;


CALL content_delivery_usage.lc_load_students_usage_monthly_snapshots_levels(ploaddate);

drop table if exists temp_usage_data_for_snapshot;
drop table if exists temp_product_categories_learning_objects;

END LOOP;

----------------------------------------------------------
--Medium Categories
----------------------------------------------------------


RAISE INFO 'Processing Medium Categories together...';
drop table if exists temp_product_categories_learning_objects;
create temporary table temp_product_categories_learning_objects as
select distinct product_category, learning_object_id, fromdate,todate
from dw.content_delivery_usage.dim_product_category_learning_object_monthly dpclom
where dpclom.mon_year=pmonth_year
and product_category in ('Digital Readiness','Texas Essentials Blended Learning Path');

--drop table if exists temp_usage_data_for_snapshot;
create temporary table temp_usage_data_for_snapshot as
select
distinct
fal.SchoolYear,
fal.SchoolYear_Mon,
fal.Mon_Year,
fal.Mon_FirstDay,
fal.Mon_LastDay,
fal.country,
fal.state_province_code,
fal.organization_district_id,
fal.organization_school_id,
dlslo.product_category,
fal.grade_level,
fal.Topic as Topic,
--
fal.user_account_id,
--
fal.assignment_launch_id,
--
fal.launch_datetime
from temp_base_data_for_snapshot fal
join temp_product_categories_learning_objects dlslo
on fal.learning_object_id=dlslo.learning_object_id;


CALL content_delivery_usage.lc_load_students_usage_monthly_snapshots_levels(ploaddate);

drop table if exists temp_usage_data_for_snapshot;
drop table if exists temp_product_categories_learning_objects;

----------------------------------------------------------
--Small Categories
----------------------------------------------------------


RAISE INFO 'Processing Small Categories together...';
drop table if exists temp_product_categories_learning_objects;
create temporary table temp_product_categories_learning_objects as
select distinct product_category, learning_object_id, fromdate,todate
from dw.content_delivery_usage.dim_product_category_learning_object_monthly dpclom
where dpclom.mon_year=pmonth_year
and product_category in (
'Online Safety & Digital Citizenship',
'Digital Safety Foundation',
'Keyboarding & Word Processing',
'EasyCode',
'EasyCode Pillars',
'Common Sense Education',
'EasyCode Foundations',
'Assessments');

--drop table if exists temp_usage_data_for_snapshot;
create temporary table temp_usage_data_for_snapshot as
select
distinct
fal.SchoolYear,
fal.SchoolYear_Mon,
fal.Mon_Year,
fal.Mon_FirstDay,
fal.Mon_LastDay,
fal.country,
fal.state_province_code,
fal.organization_district_id,
fal.organization_school_id,
dlslo.product_category,
fal.grade_level,
fal.Topic as Topic,
--
fal.user_account_id,
--
fal.assignment_launch_id ,
--
fal.launch_datetime
from temp_base_data_for_snapshot fal
join temp_product_categories_learning_objects dlslo
on fal.learning_object_id=dlslo.learning_object_id;


CALL content_delivery_usage.lc_load_students_usage_monthly_snapshots_levels(ploaddate);

drop table if exists temp_usage_data_for_snapshot;
drop table if exists temp_product_categories_learning_objects;


----------------------------------------------------------
--All together
----------------------------------------------------------
RAISE INFO 'processing All together...';


create temporary table temp_usage_data_for_snapshot as
select
distinct
fal.SchoolYear,
fal.SchoolYear_Mon,
fal.Mon_Year,
fal.Mon_FirstDay,
fal.Mon_LastDay,
fal.country,
fal.state_province_code,
fal.organization_district_id,
fal.organization_school_id,
'(All)' as product_category,
fal.grade_level,
fal.Topic,
--
fal.user_account_id,
--
fal.assignment_launch_id,
--
fal.launch_datetime
from temp_base_data_for_snapshot fal
;

CALL content_delivery_usage.lc_load_students_usage_monthly_snapshots_levels(ploaddate);

drop table temp_usage_data_for_snapshot;
drop table temp_base_data_for_snapshot;


RETURN;
END;





$$
;



CREATE OR REPLACE PROCEDURE content_delivery_usage.lc_load_students_usage_monthly_snapshots(ploaddate timestamp)
	LANGUAGE plpgsql
AS $$
	
DECLARE
latest_month_year int;
begin

/**************************************************************************************************
* Name:         Overloading of lc_load_students_usage_monthly_snapshots
* Description:  Runs lc_load_students_usage_monthly_snapshots for the month based on the latest available date (launch_datetime) in the source table: content_delivery_usage.dbo.fact_assignment_launch
*               It can be used in an orchestrated daily run to update current month  when the same LoadDate is set for all tables
* Author:       kdrogaieva
* Date Created: 2025MAY28
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested month
*
*       
**************************************************************************************************/

select to_char(max(cast(launch_datetime as date)),'yyyymm') into latest_month_year
from content_delivery_usage.dbo.fact_assignment_launch;

call content_delivery_usage.lc_load_students_usage_monthly_snapshots(latest_month_year, ploaddate);



END;


$$
;

CREATE OR REPLACE PROCEDURE content_delivery_usage.lc_load_students_usage_monthly_snapshots()
	LANGUAGE plpgsql
AS $$
	
begin

/**************************************************************************************************
* Name:         Overloading of lc_load_students_usage_monthly_snapshots
* Description:  Runs lc_load_students_usage_monthly_snapshots for the month based on the latest available date (launch_datetime) in the source table: content_delivery_usage.dbo.fact_assignment_launch
*               It can be used in a daily run to update current month  when LoadDate is not important
* Author:       kdrogaieva
* Date Created: 2025MAY28
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested month
*
*       
**************************************************************************************************/


call content_delivery_usage.lc_load_students_usage_monthly_snapshots(GetDate());

END;


$$
;
/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CREATE OR REPLACE PROCEDURE content_delivery_usage.lc_load_students_usage_monthly_snapshots_details(columns_level varchar, table_level varchar)
LANGUAGE plpgsql
AS $$
BEGIN


/**************************************************************************************************
* Name: lc_load_students_usage_monthly_snapshots_details
* Description: The procedure is used to calculate aggregates at different levels from temp_usage_data_for_snapshot temporary table created in lc_load_students_usage_monthly_snapshots
* 
* Author: kdrogaieva
* Date Created: 2025MAY28
*
*
* Notes: The procedure is called from lc_load_students_usage_monthly_snapshots_levels with different columns_level parameter
*
* 
**************************************************************************************************/


EXECUTE
'create temporary table ' || table_level ||
' as with data as ( ' ||
--
--
' select ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' ''(All)'' as grade_level, ' ||
' ''(All)'' as Topic, ' ||
' count(distinct user_account_id) cnt_Students, ' ||
' count(distinct assignment_launch_id) cnt_Students_Launches, ' ||
--monthly
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN user_account_id ' ||
' END) AS cnt_Students_Month, ' ||
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN assignment_launch_id ' ||
' END) AS cnt_Students_Launches_Month ' ||
' from temp_usage_data_for_snapshot ' ||
' group by ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category ' ||
--
--
' union all ' ||
--
--
' select ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' ''All Students'' as grade_level, ' ||
' ''(All)'' as Topic, ' ||
' count(distinct user_account_id) cnt_Students, ' ||
' count(distinct assignment_launch_id) cnt_Students_Launches, ' ||
--monthly
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN user_account_id ' ||
' END) AS cnt_Students_Month, ' ||
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN assignment_launch_id ' ||
' END) AS cnt_Students_Launches_Month ' ||
' from temp_usage_data_for_snapshot ' ||
' where grade_level != ''Non Students'' ' ||
' group by ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category ' ||
--
--
' union all ' ||
--
--
' select ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' case ' ||
' when grade_level in (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'') then ''Elementary'' ' ||
' when grade_level in (''06'',''07'',''08'') then ''Middle'' ' ||
' when grade_level in (''09'',''10'',''11'',''12'') then ''High'' ' ||
' else ''Unknown'' ' ||
' end as grade_level, ' ||
' ''(All)'' as Topic, ' ||
' count(distinct user_account_id) cnt_Students, ' ||
' count(distinct assignment_launch_id) cnt_Students_Launches, ' ||
--monthly
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN user_account_id ' ||
' END) AS cnt_Students_Month, ' ||
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN assignment_launch_id ' ||
' END) AS cnt_Students_Launches_Month ' ||
' from temp_usage_data_for_snapshot ' ||
' where grade_level != ''Non Students'' ' ||
' group by ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' case ' ||
' when grade_level in (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'') then ''Elementary'' ' ||
' when grade_level in (''06'',''07'',''08'') then ''Middle'' ' ||
' when grade_level in (''09'',''10'',''11'',''12'') then ''High'' ' ||
' else ''Unknown'' ' ||
' end ' ||
--
--
' union all ' ||
--
--
' select ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' ''(All)'' as grade_level, ' ||
' Topic, ' ||
' count(distinct user_account_id) cnt_Students, ' ||
' count(distinct assignment_launch_id) cnt_Students_Launches, ' ||
--monthly
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN user_account_id ' ||
' END) AS cnt_Students_Month, ' ||
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN assignment_launch_id ' ||
' END) AS cnt_Students_Launches_Month ' ||
' from temp_usage_data_for_snapshot ' ||
' group by ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' Topic ' ||
--
--
' union all ' ||
--
--
' select ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' ''All Students'' as grade_level, ' ||
' Topic, ' ||
' count(distinct user_account_id) cnt_Students, ' ||
' count(distinct assignment_launch_id) cnt_Students_Launches, ' ||
--monthly
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN user_account_id ' ||
' END) AS cnt_Students_Month, ' ||
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN assignment_launch_id ' ||
' END) AS cnt_Students_Launches_Month ' ||
' from temp_usage_data_for_snapshot ' ||
' where grade_level != ''Non Students'' ' ||
' group by ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' Topic ' ||
--
--
' union all ' ||
--
--
' select ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' case ' ||
' when grade_level in (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'') then ''Elementary'' ' ||
' when grade_level in (''06'',''07'',''08'') then ''Middle'' ' ||
' when grade_level in (''09'',''10'',''11'',''12'') then ''High'' ' ||
' else ''Unknown'' ' ||
' end as grade_level, ' ||
' Topic as Topic, ' ||
' count(distinct user_account_id) cnt_Students, ' ||
' count(distinct assignment_launch_id) cnt_Students_Launches, ' ||
--monthly
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN user_account_id ' ||
' END) AS cnt_Students_Month, ' ||
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN assignment_launch_id ' ||
' END) AS cnt_Students_Launches_Month ' ||
' from temp_usage_data_for_snapshot ' ||
' where grade_level != ''Non Students'' ' ||
' group by ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' case ' ||
' when grade_level in (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'') then ''Elementary'' ' ||
' when grade_level in (''06'',''07'',''08'') then ''Middle'' ' ||
' when grade_level in (''09'',''10'',''11'',''12'') then ''High'' ' ||
' else ''Unknown'' ' ||
' end, ' ||
' Topic ' ||
--
--
' union all ' ||
--
--
' select ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' grade_level, ' ||
' Topic as Topic, ' ||
' count(distinct user_account_id) cnt_Students, ' ||
' count(distinct assignment_launch_id) cnt_Students_Launches, ' ||
--monthly
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN user_account_id ' ||
' END) AS cnt_Students_Month, ' ||
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN assignment_launch_id ' ||
' END) AS cnt_Students_Launches_Month ' ||
' from temp_usage_data_for_snapshot ' ||
' where grade_level in (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'',''06'',''07'',''08'',''09'',''10'',''11'',''12'',''Non Students'') ' ||
' group by ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' grade_level, ' ||
' Topic ' ||
--
--
' union all ' ||
--
--
' select ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' grade_level, ' ||
' ''(All)'' as Topic, ' ||
' count(distinct user_account_id) cnt_Students, ' ||
' count(distinct assignment_launch_id) cnt_Students_Launches, ' ||
--monthly
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN user_account_id ' ||
' END) AS cnt_Students_Month, ' ||
' COUNT(distinct ' ||
' CASE ' ||
' WHEN launch_datetime BETWEEN mon_firstday AND DATEADD(day, 1, mon_lastday) ' ||
' THEN assignment_launch_id ' ||
' END) AS cnt_Students_Launches_Month ' ||
' from temp_usage_data_for_snapshot ' ||
' where grade_level in (''PK'',''KG'',''01'',''02'',''03'',''04'',''05'',''06'',''07'',''08'',''09'',''10'',''11'',''12'',''Non Students'') ' ||
' group by ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' grade_level ' ||
--
' ) ' ||
' select ' ||
' SchoolYear, ' ||
' SchoolYear_Mon, ' ||
' Mon_Year, ' ||
' Mon_LastDay, ' ||
columns_level ||
' product_category, ' ||
' grade_level, ' ||
' Topic, ' ||
' cnt_Students, ' ||
' cnt_Students_Launches, ' ||
' cnt_Students_month, ' ||
' cnt_Students_Launches_month ' ||
' from data '
;


END;







$$
;

CREATE OR REPLACE PROCEDURE content_delivery_usage.lc_load_students_usage_monthly_snapshots_levels(ploaddate timestamp)
LANGUAGE plpgsql
AS $$
BEGIN


/**************************************************************************************************
* Name: lc_load_students_usage_monthly_snapshots_levels
* Description: The procedure is used to populate with pre-calculated aggregates main table: content_delivery_usage.fact_students_usage_monthly_snapshots
* 
* Author: kdrogaieva
* Date Created: 2025MAY28
*
*
* Notes: The procedure is called from lc_load_students_usage_monthly_snapshots for pre-selected sku or sequences groups and subgroups
*
* 
**************************************************************************************************/


drop table if exists temp_fact_usage_monthly_snapshots_company;
drop table if exists temp_fact_usage_monthly_snapshots_country;
drop table if exists temp_fact_usage_monthly_snapshots_state;
drop table if exists temp_fact_usage_monthly_snapshots_district;
drop table if exists temp_fact_usage_monthly_snapshots_school;

RAISE INFO '- schools level';
CALL content_delivery_usage.lc_load_students_usage_monthly_snapshots_details('country, state_province_code, organization_district_id, organization_school_id,', 'temp_fact_usage_monthly_snapshots_school');

RAISE INFO '- districts level';
CALL content_delivery_usage.lc_load_students_usage_monthly_snapshots_details('country, state_province_code, organization_district_id,', 'temp_fact_usage_monthly_snapshots_district');

RAISE INFO '- state level';
CALL content_delivery_usage.lc_load_students_usage_monthly_snapshots_details('country, state_province_code,', 'temp_fact_usage_monthly_snapshots_state');

RAISE INFO '- country level';
CALL content_delivery_usage.lc_load_students_usage_monthly_snapshots_details('country,', 'temp_fact_usage_monthly_snapshots_country');

RAISE INFO '- company level';
CALL content_delivery_usage.lc_load_students_usage_monthly_snapshots_details('', 'temp_fact_usage_monthly_snapshots_company');

RAISE INFO 'Insert into fact_students_usage_monthly_snapshots';
insert into content_delivery_usage.fact_students_usage_monthly_snapshots
select
sch.SchoolYear,
sch.SchoolYear_Mon,
sch.Mon_Year,
sch.Mon_LastDay,
sch.country,
sch.state_province_code,
sch.organization_district_id,
--
sch.organization_school_id,
--
sch.product_category,
sch.grade_level,
sch.Topic,
--
sch.cnt_Students as school_cnt_Students,
sch.cnt_Students_Launches as school_Students_Launches,
--
dist.cnt_Students as district_cnt_Students,
dist.cnt_Students_Launches as district_Students_Launches,
--
st.cnt_Students as state_cnt_Students,
st.cnt_Students_Launches as state_Students_Launches,
--
cntr.cnt_Students as country_cnt_Students,
cntr.cnt_Students_Launches as country_Students_Launches,
--
cmp.cnt_Students as company_cnt_Students,
cmp.cnt_Students_Launches as company_Students_Launches,
--
-- Monthly
--
sch.cnt_Students_Month as school_cnt_Students_Month,
sch.cnt_Students_Launches_Month as school_Students_Launches_Month,
--
dist.cnt_Students_Month as district_cnt_Students_Month,
dist.cnt_Students_Launches_Month as district_Students_Launches_Month,
--
st.cnt_Students_Month as state_cnt_Students_Month,
st.cnt_Students_Launches_Month as state_Students_Launches_Month,
--
cntr.cnt_Students_Month as country_cnt_Students_Month,
cntr.cnt_Students_Launches_Month as country_Students_Launches_Month,
--
cmp.cnt_Students_Month as company_cnt_Students_Month,
cmp.cnt_Students_Launches_Month as company_Students_Launches_Month,
--
ploaddate as loaddate
from temp_fact_usage_monthly_snapshots_school sch
join temp_fact_usage_monthly_snapshots_district dist
on dist.organization_district_id = sch.organization_district_id
and dist.Mon_Year=sch.Mon_Year
and dist.product_category=sch.product_category
and dist.grade_level=sch.grade_level
and dist.topic=sch.topic
join temp_fact_usage_monthly_snapshots_state st
on st.country = sch.country
and st.state_province_code = sch.state_province_code
and st.Mon_Year=sch.Mon_Year
and st.product_category=sch.product_category
and st.grade_level=sch.grade_level
and st.topic=sch.topic
join temp_fact_usage_monthly_snapshots_country cntr
on cntr.country = sch.country
and cntr.Mon_Year=sch.Mon_Year
and cntr.product_category=sch.product_category
and cntr.grade_level=sch.grade_level
and cntr.topic=sch.topic
join temp_fact_usage_monthly_snapshots_company cmp
on cmp.Mon_Year=sch.Mon_Year
and cmp.product_category=sch.product_category
and cmp.grade_level=sch.grade_level
and cmp.topic=sch.topic;

drop table temp_fact_usage_monthly_snapshots_company;
drop table temp_fact_usage_monthly_snapshots_country;
drop table temp_fact_usage_monthly_snapshots_state;
drop table temp_fact_usage_monthly_snapshots_district;
drop table temp_fact_usage_monthly_snapshots_school;

END;





$$
;


 {% endset %}


 {% do run_query(create_sp_operation) %}
 
 {% endmacro %}