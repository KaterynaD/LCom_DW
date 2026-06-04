{% macro create_lc_load_launches_monthly_snapshots() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}

 {% if flags.WHICH in ('run','build') %}
  {% set custom_schema = model.config.schema | default(target.schema, true) %}
 {% else %}
  {% set custom_schema = target.schema %}
 {% endif %}

 {{ log('Creating lc_load_launches_monthly_snapshots in schema ' ~ custom_schema, info=True) }}
 


 {% set create_sp_operation %}

CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_launches_monthly_snapshots(pstart_date date, pend_date date, ploaddate timestamp without time zone)
 LANGUAGE plpgsql
AS $$
	
BEGIN
	
/**************************************************************************************************
* Name:         lc_load_launches_monthly_snapshots
* Description:  Cumulative school year monthly launch numbers per school
*               (similar to the data produced by [ReportObjects].[dbo].[lc_RptGainsight_BasicUsageForPriorWeek] for Gainsight)
*               SchoolId is used from content_delivery_usage.dbo.fact_assignment_launch, not UserAccount as in the original SQL Server Stored Procedure
*               It reflects historical nature of the user-school relationship
*               schoolid isn't always available (empty or 00000000-0000-0000-0000-00000000000); in these cases I associated it to the
*               district by representing the district as a building; these district as building
*               accounts, like _cloud school, are given no provisioned student count
* Author:       ksure
* Date Created: 2025APR07
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested months
*
*       
**************************************************************************************************/

delete from {{target.database}}.{{custom_schema}}.fact_launches_monthly_snapshots
where mon_lastday between pstart_date and pend_date;

insert into {{target.database}}.{{custom_schema}}.fact_launches_monthly_snapshots
with
dim_date as (
select distinct mon_lastday, SchoolYear_StartDate, SchoolYear_EndDate
from {{ ref("dim_calendar") }}
where mon_lastday between pstart_date and pend_date
)
,dsu as (
select
dt.mon_lastday as mon_lastday,
case 
 when fal.organization_school_id='00000000-0000-0000-0000-000000000000'  then
 fal.organization_district_id
 when len(fal.organization_school_id)<2  then
 fal.organization_district_id
else
 isnull(fal.organization_school_id,fal.organization_district_id)
end organization_school_id,
fal.user_account_id,
count(0) as Launches,
count(distinct fal.learning_object_id) as DistinctItemsStudent
from {{ source('dbo', 'fact_assignment_launch') }} fal
join dim_date dt
on TIMEZONE('UTC', launch_datetime) between dt.SchoolYear_StartDate and DATEADD(day,1,dt.mon_lastday) 
AND TIMEZONE('UTC', launch_datetime) < SchoolYear_EndDate
group by
dt.mon_lastday,
case 
 when fal.organization_school_id='00000000-0000-0000-0000-000000000000'  then
 fal.organization_district_id
 when len(fal.organization_school_id)<2  then
 fal.organization_district_id
else
 isnull(fal.organization_school_id,fal.organization_district_id)
end,
fal.user_account_id
)
,ds as (
select
mon_lastday,
organization_school_id,
count(distinct user_account_id) AS Active_Students,
sum(Launches) AS Launches,
sum(DistinctItemsStudent) DistinctItemsStudent
from dsu
group by
mon_lastday,
organization_school_id
)
select
mon_lastday,
case when len(o.parent_organization_id)<1 then o.organization_id else o.parent_organization_id end organization_district_id,
organization_school_id,
Active_Students Active_Students_YTD ,
Launches Launches_YTD,
DistinctItemsStudent DistinctItemsStudent_YTD,
--
CASE 
    WHEN LAG(Active_Students_YTD) OVER (PARTITION BY organization_school_id ORDER BY mon_lastday) IS NULL 
    THEN Active_Students_YTD 
    ELSE Active_Students_YTD - LAG(Active_Students_YTD) OVER (PARTITION BY organization_school_id ORDER BY mon_lastday) 
END AS Active_Students_Month,

CASE 
    WHEN LAG(Launches_YTD) OVER (PARTITION BY organization_school_id ORDER BY mon_lastday) IS NULL 
    THEN Launches_YTD 
    ELSE Launches_YTD - LAG(Launches_YTD) OVER (PARTITION BY organization_school_id ORDER BY mon_lastday) 
END AS Launches_Month,

CASE 
    WHEN LAG(DistinctItemsStudent_YTD) OVER (PARTITION BY organization_school_id ORDER BY mon_lastday) IS NULL 
    THEN DistinctItemsStudent_YTD 
    ELSE DistinctItemsStudent_YTD - LAG(DistinctItemsStudent_YTD) OVER (PARTITION BY organization_school_id ORDER BY mon_lastday) 
END AS DistinctItemsStudent_Month,

--
ploaddate
from ds
join {{ source("dbo","organization") }} o
on ds.organization_school_id = o.organization_id
order by o.parent_organization_id, mon_lastday, organization_school_id;


END;


$$
;

--Ongoing load with managed loaddate

CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_launches_monthly_snapshots(ploaddate timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
latest_date date;
begin

/**************************************************************************************************
* Name:         Overloading of lc_load_launches_monthly_snapshots
* Description:  Runs lc_load_launches_monthly_snapshots for the month based on the latest available date (launch_datetime) in the source table: content_delivery_usage.dbo.fact_assignment_launch
*               It can be used in an orchestrated daily run to update current month  when the same LoadDate is set for all tables
* Author:       kdrogaieva
* Date Created: 2025APR07
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested month
*
*       
**************************************************************************************************/

select max(cast(launch_datetime as date)) into latest_date
from {{ source("dbo","fact_assignment_launch") }};

call {{ custom_schema }}.lc_load_launches_monthly_snapshots(latest_date, LAST_DAY( latest_date ), ploaddate);

--update Month amounts for the latest month (previous month is not available for ongoing (only current month) updates
with 
latest as (select max(mon_lastday) mon_lastday from {{target.database}}.{{custom_schema}}.fact_launches_monthly_snapshots)
,data as (
select 
mon_lastday,
organization_district_id,
organization_school_id,
Active_Students_YTD ,
Launches_YTD,
DistinctItemsStudent_YTD,
--
isnull(Active_Students_YTD - lag(Active_Students_YTD) over(partition by organization_school_id order by mon_lastday),0) Active_Students_month,
isnull(Launches_YTD - lag(Launches_YTD) over(partition by organization_school_id order by mon_lastday),0) Launches_month,
isnull(DistinctItemsStudent_YTD - lag(DistinctItemsStudent_YTD) over(partition by organization_school_id order by mon_lastday),0) DistinctItemsStudent_month
from {{target.database}}.{{custom_schema}}.fact_launches_monthly_snapshots
where  mon_lastday in (
--the latest month
select mon_lastday from latest
union all
--the month before the latest
select max(mon_lastday) from {{target.database}}.{{custom_schema}}.fact_launches_monthly_snapshots
where mon_lastday<(select mon_lastday from latest)
)
)
update {{target.database}}.{{custom_schema}}.fact_launches_monthly_snapshots
set 
Active_Students_month=data.Active_Students_month,
Launches_month=data.Launches_month,
DistinctItemsStudent_month=data.DistinctItemsStudent_month
from data
join latest
on data.mon_lastday=latest.mon_lastday
where data.mon_lastday={{target.database}}.{{custom_schema}}.fact_launches_monthly_snapshots.mon_lastday 
and   data.organization_school_id = {{target.database}}.{{custom_schema}}.fact_launches_monthly_snapshots.organization_school_id;

END;

$$
;

--Ongoing load with current date and time loaddate

CREATE OR REPLACE PROCEDURE {{target.database}}.{{custom_schema}}.lc_load_launches_monthly_snapshots()
LANGUAGE plpgsql
AS $$
begin

/**************************************************************************************************
* Name:         Overloading of lc_load_launches_monthly_snapshots
* Description:  Runs lc_load_launches_monthly_snapshots for the month based on the latest available date (launch_datetime) in the source table: content_delivery_usage.dbo.fact_assignment_launch
*               It can be used in a daily run to update current month  when LoadDate is not important
* Author:       kdrogaieva
* Date Created: 2025MAR26
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested month
*
*       
**************************************************************************************************/


call {{custom_schema}}.lc_load_launches_monthly_snapshots(GetDate());

END;

$$
;

 {% endset %}


{% do run_query(create_sp_operation) %}

{% endif %}


{% endmacro %}