{% macro create_lc_load_launches_weekly_snapshots() %}
 {% set create_sp_operation %}

--Historical load
CREATE OR REPLACE PROCEDURE  {{target.database}}.content_delivery_usage.lc_load_launches_weekly_snapshots(pstart_date date, pend_date date, ploaddate timestamp)
LANGUAGE plpgsql
AS $$
begin

/**************************************************************************************************
* Name:         lc_load_launches_weekly_snapshots
* Description:  Cumulative school year weekly launch numbers per school
*               (similar to the data produced by [ReportObjects].[dbo].[lc_RptGainsight_BasicUsageForPriorWeek] for Gainsight)
*               SchoolId is used from content_delivery_usage.dbo.fact_assignment_launch, not UserAccount as in the original SQL Server Stored Procedure
*               It reflects historical nature of the user-school relationship
*               schoolid isn't always available (empty or 00000000-0000-0000-0000-00000000000); in these cases I associated it to the
*               district by representing the district as a building; these district as building
*               accounts, like _cloud school, are given no provisioned student count
* Author:       kdrogaieva
* Date Created: 2025MAR26
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested weeks
*
*       
**************************************************************************************************/
/**delete previously loaded data if any*/

delete from content_delivery_usage.fact_launches_weekly_snapshots
where WeekEnd between pstart_date and pend_date;

insert into content_delivery_usage.fact_launches_weekly_snapshots
with
dim_date as (
select distinct Sun_WeekEnd, SchoolYear_StartDate, SchoolYear_EndDate
from common.dim_calendar
where Sun_WeekEnd=Cal_date and Sun_WeekEnd between pstart_date and pend_date
)
,dsu as (
select
dt.Sun_WeekEnd WeekEnd,
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
from content_delivery_usage.dbo.fact_assignment_launch fal
join dim_date dt
on TIMEZONE('UTC', launch_datetime) between dt.SchoolYear_StartDate and DATEADD(day,1,dt.Sun_WeekEnd)  
AND TIMEZONE('UTC', launch_datetime) < SchoolYear_EndDate
group by
dt.Sun_WeekEnd,
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
WeekEnd,
organization_school_id,
count(distinct user_account_id) AS Active_Students,
sum(Launches) AS Launches,
sum(DistinctItemsStudent) DistinctItemsStudent
from dsu
group by
WeekEnd,
organization_school_id
)
select
WeekEnd,
case when len(o.parent_organization_id)<1 then o.organization_id else o.parent_organization_id end organization_district_id,
organization_school_id,
Active_Students Active_Students_YTD ,
Launches Launches_YTD,
DistinctItemsStudent DistinctItemsStudent_YTD,
--
isnull(Active_Students_YTD - lag(Active_Students_YTD) over(partition by organization_school_id order by WeekEnd),0) Active_Students_Week,
isnull(Launches_YTD - lag(Launches_YTD) over(partition by organization_school_id order by WeekEnd),0) Launches_Week,
isnull(DistinctItemsStudent_YTD - lag(DistinctItemsStudent_YTD) over(partition by organization_school_id order by WeekEnd),0) DistinctItemsStudent_Week,
--
ploaddate
from ds
join content_delivery_usage.dbo.organization o
on ds.organization_school_id = o.organization_id
order by o.parent_organization_id, WeekEnd, organization_school_id;


END;

$$
;

--Ongoing load with managed loaddate

CREATE OR REPLACE PROCEDURE  {{target.database}}.content_delivery_usage.lc_load_launches_weekly_snapshots(ploaddate timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
latest_date date;
begin

/**************************************************************************************************
* Name:         Overloading of lc_load_launches_weekly_snapshots
* Description:  Runs lc_load_launches_weekly_snapshots for the week based on the latest available date (launch_datetime) in the source table: content_delivery_usage.dbo.fact_assignment_launch
*               It can be used in an orchestrated daily run to update current week  when the same LoadDate is set for all tables
* Author:       kdrogaieva
* Date Created: 2025MAR26
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested week
*
*       
**************************************************************************************************/

select max(cast(launch_datetime as date)) into latest_date
from content_delivery_usage.dbo.fact_assignment_launch;

call content_delivery_usage.lc_load_launches_weekly_snapshots(latest_date, cast(DATEADD(day, 6, DATE_TRUNC('week', latest_date)) as date), ploaddate);

--update Week amounts for the latest week (previous week is not available for ongoing (only current week) updates
with 
latest as (select max(weekend) weekend from content_delivery_usage.fact_launches_weekly_snapshots)
,data as (
select 
WeekEnd,
organization_district_id,
organization_school_id,
Active_Students_YTD ,
Launches_YTD,
DistinctItemsStudent_YTD,
--
isnull(Active_Students_YTD - lag(Active_Students_YTD) over(partition by organization_school_id order by WeekEnd),0) Active_Students_Week,
isnull(Launches_YTD - lag(Launches_YTD) over(partition by organization_school_id order by WeekEnd),0) Launches_Week,
isnull(DistinctItemsStudent_YTD - lag(DistinctItemsStudent_YTD) over(partition by organization_school_id order by WeekEnd),0) DistinctItemsStudent_Week
from content_delivery_usage.fact_launches_weekly_snapshots 
where  weekend in (
--the latest week
select weekend from latest
union all
--the week before the latest
select max(weekend) from content_delivery_usage.fact_launches_weekly_snapshots
where weekend<(select weekend from latest)
)
)
update content_delivery_usage.fact_launches_weekly_snapshots
set 
Active_Students_Week=data.Active_Students_Week,
Launches_Week=data.Launches_Week,
DistinctItemsStudent_Week=data.DistinctItemsStudent_Week
from data
join latest
on data.weekend=latest.weekend
where data.weekend=content_delivery_usage.fact_launches_weekly_snapshots.weekend 
and   data.organization_school_id = content_delivery_usage.fact_launches_weekly_snapshots.organization_school_id;

END;

$$
;

--Ongoing load with current date and time loaddate

CREATE OR REPLACE PROCEDURE  {{target.database}}.content_delivery_usage.lc_load_launches_weekly_snapshots()
LANGUAGE plpgsql
AS $$
begin

/**************************************************************************************************
* Name:         Overloading of lc_load_launches_weekly_snapshots
* Description:  Runs lc_load_launches_weekly_snapshots for the week based on the latest available date (launch_datetime) in the source table: content_delivery_usage.dbo.fact_assignment_launch
*               It can be used in a daily run to update current week  when LoadDate is not important
* Author:       kdrogaieva
* Date Created: 2025MAR26
*
*
* Notes: The procedure can be run daily. It deletes previously stored data for the requested week
*
*       
**************************************************************************************************/


call content_delivery_usage.lc_load_launches_weekly_snapshots(GetDate());

END;

$$
;

 {% endset %}

{% do run_query(create_sp_operation) %}
{% endmacro %}