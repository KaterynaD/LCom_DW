{{ config(materialized='view', bind=False) }}

with 
rawdata as (select
a.account_id,
flo.sku_id,
sum(schoolcount) sum_schools,
sum(studentcount) sum_students
from {{ ref("fact_license_order") }} flo 
join {{ ref("dim_account") }} a
on flo.organization_district_id = a.account_id
where ( GETDATE() between startdate and expirationdate
or enforcedaterestrictions = 'n')
and a.lcom_trial=false 
and a.lcom_demo=false
group by a.account_id,
flo.sku_id 
)
, data as (select
account_id,
max(sum_schools) max_schools,
max(sum_students) max_students
from rawdata
group by account_id
)
select 
count(distinct account_id) cnt_districts,
sum(max_schools) cnt_school,
sum(max_students) cnt_students
from data