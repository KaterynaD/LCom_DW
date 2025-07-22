{{ config(materialized='view', bind=False) }}


with dim_month as --Thread to calculate monthly metrics
(select distinct c.mon_year, c.mon_firstday, c.mon_lastday, c.FiscalYear, c.FiscalYear_startdate, c.FiscalYear_enddate , c.FiscalYear_mon
from {{ source("common","dim_calendar") }}  c 
where mon_year between 202207 and to_char(GetDate(),'yyyymm')
)
--
,rawdata as (
select
m.FiscalYear,
m.mon_year,
m.mon_lastday,
m.FiscalYear_mon,
organization_district_id,
a.lcom_organization_name ,
a.sfdc_name,
a.lcom_country_name,
a.lcom_state_province_code,
case when a.sfdc_district_enrollment=0 then a.sfdc_school_enrollment else a.sfdc_district_enrollment end as district_enrollment,
case when (a.sfdc_state_initiative or a.sfdc_state_initiative_school) then true else false end as state_initiative,
a.sfdc_urban_rural as urban_rural,
sku.sku_id,
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
or (enforcedaterestrictions = 'n' and startdate<=case when m.mon_lastday<GetDate() then m.mon_lastday else GetDate() end))
join {{ ref("dim_account_history") }} a
on floh.organization_district_id = a.account_id
and m.mon_lastday between a.fromdate and a.todate
where a.lcom_trial=false 
and a.lcom_demo=false
)
,data as (
select
FiscalYear,
mon_year,
mon_lastday,
FiscalYear_mon,
organization_district_id,
lcom_organization_name ,
sfdc_name,
lcom_country_name,
lcom_state_province_code,
district_enrollment,
state_initiative,
urban_rural,
sku_id,
ltrim(rtrim(sku_name)) as sku_name,
sum(schoolcount) as schoolcount,
sum(studentcount) as studentcount
from rawdata r
group by 
FiscalYear,
mon_year,
mon_lastday,
FiscalYear_mon,
organization_district_id,
lcom_organization_name ,
sfdc_name,
lcom_country_name,
lcom_state_province_code,
district_enrollment,
state_initiative,
urban_rural,
sku_id,
sku_name
)
select 
FiscalYear,
mon_year,
mon_lastday,
FiscalYear_mon,
organization_district_id,
lcom_organization_name ,
sfdc_name,
lcom_country_name,
lcom_state_province_code,
district_enrollment,
state_initiative,
urban_rural,
sku_id,
sku_name,
schoolcount,
studentcount
from data
union all
select 
FiscalYear,
mon_year,
mon_lastday,
FiscalYear_mon,
organization_district_id,
lcom_organization_name ,
sfdc_name,
lcom_country_name,
lcom_state_province_code,
district_enrollment,
state_initiative,
urban_rural,
'(All)' as sku_id,
'(All)' as sku_name,
max(schoolcount) as schoolcount,
max(studentcount) as studentcount
from data
group by
FiscalYear,
mon_year,
mon_lastday,
FiscalYear_mon,
organization_district_id,
lcom_organization_name ,
sfdc_name,
lcom_country_name,
lcom_state_province_code,
district_enrollment,
state_initiative,
urban_rural
