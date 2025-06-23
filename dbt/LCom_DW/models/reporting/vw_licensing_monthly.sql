{{ config(materialized='view', bind=False) }}
with dim_month as --Thread to calculate monthly metrics
(select distinct c.mon_year, c.mon_firstday, c.mon_lastday, c.schoolyear, c.schoolyear_startdate, c.schoolyear_enddate , c.schoolyear_mon
from {{ source("common","dim_calendar") }} c 
where mon_year between 202207 and to_char(GetDate(),'yyyymm')
)
--
select
m.schoolyear,
m.mon_year,
m.mon_lastday,
m.schoolyear_mon,
organization_district_id,
a.lcom_organization_name ,
a.sfdc_name,
a.lcom_country_name,
a.lcom_state_province_code,
sku.sku_id,
sku.sku_group,
sku.sku_subgroup,
sku.sku_name,
schoolcount,
studentcount
from {{ ref("fact_license_order_history") }}  floh
join {{ ref("dim_lcom_sku") }} sku
on floh.sku_id = sku.sku_id
join dim_month m
on 
case when m.mon_lastday<GetDate() then m.mon_lastday else GetDate() end between fromdate and todate
AND
(case when m.mon_lastday<GetDate() then m.mon_lastday else GetDate() end between startdate and expirationdate
or enforcedaterestrictions = 'n')
join {{ ref("dim_account_history") }} a
on floh.organization_district_id = a.account_id
and m.mon_lastday between a.fromdate and a.todate
where a.lcom_trial=false 
and a.lcom_demo=false