{{ config(materialized='view', bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]) }}

														
with															
cal as (															
select															
schoolyear,															
substring(mon_year,5,2)::int mon,															
mon_firstday,															
mon_lastday,															
schoolyear_mon															
from															
{{ ref("dim_month") }}														
where mon_year between 202207 and to_char(GetDate(),'yyyymm')															
)															
,raw_license_data as (															
select															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
case when (dist.sfdc_state_initiative or dist.sfdc_state_initiative_school) then true else false end state_initiative,															
dist.lcom_state_province_code district_state,															
flo.order_id,															
flo.organization_district_id,															
flo.startdate,															
flo.expirationdate,															
flo.enforcedaterestrictions,															
s.sku_name skuname,															
flo.studentcount,															
sch.ishighschool,															
dlos.organization_school_id															
from {{ ref("vw_fact_license_order") }} flo															
join {{ ref("dim_account") }} dist															
on dist.account_id = flo.organization_district_id															
-- 															
join {{ ref("dim_lcom_sku") }} s															
on flo.sku_id = s.sku_id															
-- 															
join {{ ref("dim_license_order_school") }} dlos															
on flo.order_id = dlos.order_id															
-- 															
join {{ ref("dim_account") }} sch															
on sch.account_id = dlos.organization_school_id															
-- 															
join cal on (															
(															
flo.StartDate <= cal.mon_lastday															
and flo.ExpirationDate >= cal.mon_firstday															
)															
or (															
flo.enforcedaterestrictions = 'n'															
and flo.StartDate <= cal.mon_lastday															
)															
)															
-- 															
where dist.lcom_trial = false															
and dist.lcom_demo= false																														
)																													
,rollup_schools_num as (															
select															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
state_initiative,															
district_state,															
organization_district_id,															
startdate,															
expirationdate,															
enforcedaterestrictions,															
skuname,															
count(distinct case when ishighschool then organization_school_id end) as num_highschools,															
count(distinct organization_school_id ) as num_schools															
from raw_license_data															
group by															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
state_initiative,															
district_state,															
organization_district_id,															
startdate,															
expirationdate,															
enforcedaterestrictions,															
skuname															
)															
,rollup_studentcount as (															
select															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
state_initiative,															
district_state,															
organization_district_id,															
startdate,															
expirationdate,															
enforcedaterestrictions,															
skuname,															
sum(studentcount) studentcount															
from															
(															
select distinct															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
state_initiative,															
district_state,															
organization_district_id,															
startdate,															
expirationdate,															
enforcedaterestrictions,															
skuname,															
order_id,															
studentcount															
from raw_license_data															
)															
group by															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
state_initiative,															
district_state,															
organization_district_id,															
startdate,															
expirationdate,															
enforcedaterestrictions,															
skuname															
)															
, t as (															
select															
sn.mon_lastday,															
sn.mon,															
sn.schoolyear,															
sn.schoolyear_mon,															
sn.state_initiative,															
sn.district_state,															
sn.organization_district_id,															
sn.startdate,															
sn.expirationdate,															
sn.enforcedaterestrictions,															
sn.skuname,															
lead(sn.startdate) over (partition by sn.organization_district_id, sn.skuname, sn.mon_lastday order by sn.startdate) next_order,															
case															
when next_order is not null															
and date_trunc('month', next_order) = date_trunc('month', sn.expirationdate)															
and next_order > sn.expirationdate															
and coalesce(sn.enforcedaterestrictions,'') <> 'n'															
then 1															
else 0															
end as next_order_start_in_same_month,															
sn.num_highschools,															
sn.num_schools,															
stc.studentcount															
from rollup_schools_num sn															
join rollup_studentcount stc															
on															
sn.mon_lastday = stc.mon_lastday															
and sn.organization_district_id = stc.organization_district_id															
and sn.startdate = stc.startdate															
and sn.expirationdate = stc.expirationdate															
and sn.enforcedaterestrictions = stc.enforcedaterestrictions															
and sn.skuname = stc.skuname															
)																													
,district_sku_license_data as (															
select															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
state_initiative,															
district_state,															
organization_district_id,															
skuname,															
sum(															
case															
when next_order_start_in_same_month = 0 then studentcount															
else 0															
end															
) as sum_studentcount,															
sum(															
case															
when next_order_start_in_same_month = 0 and (enforcedaterestrictions = 'y' or (enforcedaterestrictions = 'n' and expirationdate>=trunc(GetDate()))) then studentcount
else 0															
end															
) as sum_studentcount_restricted,															
sum(															
case															
when next_order_start_in_same_month = 0															
and district_state in ('NC','MI','SC','WV','GA')															
and skuname ilike '%easy%tech%'															
and num_highschools != num_schools then studentcount															
when next_order_start_in_same_month = 0															
and district_state in ('MS','FL')															
and skuname ilike '%easy%tech%' then studentcount															
else 0															
end															
) as state_initiative_studentcount,															
sum(															
case															
when next_order_start_in_same_month = 0															
and (enforcedaterestrictions = 'y' or (enforcedaterestrictions = 'n' and expirationdate>=trunc(GetDate())))															
and district_state in ('NC','MI','SC','WV','GA')															
and skuname ilike '%easy%tech%'															
and num_highschools != num_schools then studentcount															
when next_order_start_in_same_month = 0															
and district_state in ('MS','FL')															
and enforcedaterestrictions = 'y'															
and skuname ilike '%easy%tech%' then studentcount															
else 0															
end															
) as state_initiative_studentcount_restricted															
from t															
group by															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
state_initiative,															
district_state,															
organization_district_id,															
skuname															
)															
/*select * 															
from district_sku_license_data 															
where mon_lastday ='2025-09-30'*/															
,district_license_data as (															
select															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
district_state,															
state_initiative,															
organization_district_id,															
case															
when state_initiative then sum(state_initiative_studentcount)															
else 0															
end State_Initiative_Number_Of_Students,															
case															
when state_initiative then sum(state_initiative_studentcount_restricted)															
else 0															
end State_Initiative_Number_Of_Students_restricted,															
max(sum_studentcount) Number_Of_Students,															
max(sum_studentcount_restricted) Number_Of_Students_restricted															
from district_sku_license_data data															
group by															
mon_lastday,															
mon,															
schoolyear,															
schoolyear_mon,															
district_state,															
state_initiative,															
organization_district_id															
),															
district_data as (															
select															
ld.mon_lastday,															
ld.mon,															
ld.schoolyear,															
ld.schoolyear_mon,															
ld.district_state State,															
ld.state_initiative,															
ld.organization_district_id,															
ld.State_Initiative_Number_Of_Students,															
ld.State_Initiative_Number_Of_Students_restricted,															
ld.Number_Of_Students,															
Ld.Number_Of_Students_restricted															
from district_license_data ld															
),															
--schools from all active orders in the month, not for SKU with max students selected as Number_Of_Students 															
school_data as															
(															
select distinct															
rld.mon_lastday,															
rld.mon,															
rld.schoolyear,															
rld.schoolyear_mon,															
rld.district_state State,															
rld.state_initiative,															
rld.organization_district_id,															
rld.organization_school_id,															
dd.State_Initiative_Number_Of_Students,															
dd.State_Initiative_Number_Of_Students_restricted,															
dd.Number_Of_Students,															
dd.Number_Of_Students_restricted,															
a.ishighschool															
from raw_license_data rld															
join district_data dd															
on rld.mon_lastday = dd.mon_lastday															
and rld.organization_district_id = dd.organization_district_id															
join {{ ref("dim_account") }} a															
on a.account_id=rld.organization_school_id															
)															
,cnt_schools as															
(															
select															
mon_lastday,															
organization_district_id,															
count( distinct organization_school_id) cnt_schools ,															
count( case when ishighschool then organization_school_id end) cnt_high_schools															
from school_data															
group by															
mon_lastday,															
organization_district_id															
)															
,data as (															
select															
sd.mon_lastday,															
sd.mon,															
sd.schoolyear,															
sd.schoolyear_mon,															
sd.State,															
sd.state_initiative,															
sd.organization_district_id,															
sd.organization_school_id,															
cs.cnt_schools,															
cs.cnt_high_schools,															
0 State_Initiative_Number_Of_Students,															
0 State_Initiative_Number_Of_Students_restricted,															
0 Number_Of_Students,															
0 Number_Of_Students_Restricted,															
case															
when sd.State_Initiative_Number_Of_Students>0 then															
case															
when sd.State in ('NC','MI','SC','WV','GA') and not(sd.ishighschool) then															
sd.State_Initiative_Number_Of_Students/nullif((cs.cnt_schools - cs.cnt_high_schools),0)															
when sd.State in ('MS','FL') then															
sd.State_Initiative_Number_Of_Students/nullif(cs.cnt_schools,0)															
else 0															
end															
else 0															
end State_Initiative_Number_Of_Students_School,															
case															
when sd.State_Initiative_Number_Of_Students_restricted>0 then															
case															
when sd.State in ('NC','MI','SC','WV','GA') and not(sd.ishighschool) then															
sd.State_Initiative_Number_Of_Students_restricted/nullif((cs.cnt_schools - cs.cnt_high_schools),0)															
when sd.State in ('MS','FL') then															
sd.State_Initiative_Number_Of_Students_restricted/nullif(cs.cnt_schools,0)															
else 0															
end															
else 0															
end State_Initiative_Number_Of_Students_School_restricted,															
sd.Number_Of_Students/nullif(cs.cnt_schools,0) Number_Of_Students_School,															
sd.Number_Of_Students_restricted/nullif(cs.cnt_schools,0) Number_Of_Students_School_restricted															
from school_data sd															
join cnt_schools cs															
on sd.organization_district_id = cs.organization_district_id															
and sd.mon_lastday = cs.mon_lastday															
union all															
select															
dd.mon_lastday,															
dd.mon,															
dd.schoolyear,															
dd.schoolyear_mon,															
dd.State,															
dd.state_initiative,															
dd.organization_district_id,															
dd.organization_district_id organization_school_id,															
cs.cnt_schools,															
cs.cnt_high_schools,															
dd.State_Initiative_Number_Of_Students,															
dd.State_Initiative_Number_Of_Students_restricted,															
dd.Number_Of_Students,															
dd.Number_Of_Students_Restricted,															
0 State_Initiative_Number_Of_Students_School,															
0 State_Initiative_Number_Of_Students_School_restricted,															
0 as Number_Of_Students_School,															
0 as Number_Of_Students_restricted															
from district_data dd															
join cnt_schools cs															
on dd.organization_district_id = cs.organization_district_id															
and dd.mon_lastday = cs.mon_lastday															
)															
select *															
from data															
															
