{{ config(materialized='view', bind=False) }}

with data as (select
a.account_id,
max(schoolcount) max_schools,
max(studentcount) max_students
from {{ ref("fact_license_order") }} flo 
join {{ ref("dim_account") }} a
on flo.organization_district_id = a.account_id
where ( GETDATE() between startdate and expirationdate
or enforcedaterestrictions = 'n')
and a.lcom_trial=false 
and a.lcom_demo=false
group by a.account_id
)
select 
count(distinct account_id) cnt_districts,
sum(max_schools) cnt_school,
sum(max_students) cnt_students
from data