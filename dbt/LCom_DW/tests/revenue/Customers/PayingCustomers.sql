--Net Active reconciliation check: set operations vs +/- New and Churn
with churn as (					
select f1.mon_year, f1.fiscalyear, f1.sfdc_ultimate_parent_id					
from {{ ref("fact_paying_customers") }} f1					
where f1.record_type='Churn'														
)					
,Starting as (					
select					
f1.fiscalyear,					
f1.sfdc_ultimate_parent_id					
from {{ ref("fact_paying_customers") }} f1					
where f1.record_type='Starting'								
)					
,New_Returning as (					
select					
f1.mon_year,					
f1.sfdc_ultimate_parent_id					
from {{ ref("fact_paying_customers") }} f1					
where f1.record_type in ('New','Returning')					
)					
,NetActive_prev_month as (					
select					
to_char(dateadd(month, 1, to_date(f1.mon_year::varchar+'01','yyyymmdd')),'yyyymm') mon_year,					
f1.sfdc_ultimate_parent_id					
from {{ ref("fact_paying_customers") }} f1					
where f1.record_type='Net Active'									
)					
,Churn_not_in_NetActive_prev_month as (					
select					
Churn.mon_year,					
count(distinct Churn.sfdc_ultimate_parent_id) cnt_customers					
from Churn left outer join NetActive_prev_month					
on					
Churn.mon_year= NetActive_prev_month.mon_year					
and Churn.sfdc_ultimate_parent_id = NetActive_prev_month.sfdc_ultimate_parent_id					
where NetActive_prev_month.sfdc_ultimate_parent_id is null					
group by Churn.mon_year					
)					
,Churn_not_in_Starting as (					
select					
Churn.mon_year,					
count(distinct Churn.sfdc_ultimate_parent_id) cnt_customers					
from Churn left outer join Starting					
on					
Churn.fiscalyear= Starting.fiscalyear					
and Churn.sfdc_ultimate_parent_id = Starting.sfdc_ultimate_parent_id					
where Starting.sfdc_ultimate_parent_id is null					
group by Churn.mon_year					
)					
,Churn_in_New_Returning_same_month as (					
select					
Churn.mon_year,					
count(distinct Churn.sfdc_ultimate_parent_id) cnt_customers					
from Churn left outer join New_Returning					
on					
Churn.mon_year= New_Returning.mon_year					
and Churn.sfdc_ultimate_parent_id = New_Returning.sfdc_ultimate_parent_id					
where New_Returning.sfdc_ultimate_parent_id is not null					
group by Churn.mon_year					
)					
,rawdata as (					
select f.fiscalyear, f.mon_year,					
count(distinct case when f.record_type='Starting' then f.sfdc_ultimate_parent_id end) Starting,					
count(distinct case when f.record_type='New' then f.sfdc_ultimate_parent_id end) New_,					
count(distinct case when f.record_type='Returning' then f.sfdc_ultimate_parent_id end) Returning,					
count(distinct case when f.record_type='Churn'  then f.sfdc_ultimate_parent_id end) Churn,					
cns.cnt_customers Churn_not_in_Starting,					
cnnapm.cnt_customers Churn_not_in_NetActive_prev_month,					
cnrsm.cnt_customers Churn_in_New_Returning_same_month,					
count(distinct case when f.record_type='Net Active' then f.sfdc_ultimate_parent_id end) Net_Active,					
count(distinct case when f.record_type='Total Active' then f.sfdc_ultimate_parent_id end) Total_Active					
from {{ ref("fact_paying_customers") }} f					
left outer join Churn_not_in_Starting cns					
on cns.mon_year=f.mon_year					
left outer join Churn_not_in_NetActive_prev_month cnnapm					
on cnnapm.mon_year=f.mon_year					
left outer join Churn_in_New_Returning_same_month cnrsm					
on cnrsm.mon_year=f.mon_year					
group by f.fiscalyear, f.mon_year,cns.cnt_customers,cnnapm.cnt_customers,cnrsm.cnt_customers					
)					
,data as (					
select					
fiscalyear, mon_year,					
Starting,					
New_,					
Returning,					
Churn,					
Churn_in_New_Returning_same_month,					
Churn_not_in_Starting,					
Churn_not_in_NetActive_prev_month,					
Net_Active,					
Total_Active,					
CASE WHEN mon_year like '%07' then					
Starting					
ELSE					
isnull(lag(Net_Active) over(partition by fiscalyear order by mon_year),Starting)					
end pre_Net_Active ,							
pre_Net_Active + New_ + returning - (Churn - isnull(case when mon_year::varchar like '%07' then Churn_not_in_Starting else Churn_not_in_NetActive_prev_month end,0) + isnull(Churn_in_New_Returning_same_month,0) ) Calc_Net_Active,					
Net_Active - Calc_Net_Active diff					
from rawdata					
)					
select *					
from data					
where diff!=0		
and mon_year!=0
order by fiscalyear, mon_year					
