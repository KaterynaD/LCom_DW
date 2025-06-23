{{ config(materialized='view', bind=False) }}

select
count(distinct organization_district_id) cnt_districts,
sum(schoolcount) cnt_schools,
sum(studentcount) cnt_students
from {{ ref("fact_license_order") }} flo 
join {{ ref("dim_account") }} a
on flo.organization_district_id = a.account_id
where ( GETDATE() between startdate and expirationdate
or enforcedaterestrictions = 'n')
and a.lcom_trial=false 
and a.lcom_demo=false
