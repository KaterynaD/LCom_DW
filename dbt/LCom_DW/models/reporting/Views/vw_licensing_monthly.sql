{{ config(materialized='view', bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]) }}


with dim_month as --Thread to calculate monthly metrics
(select distinct c.mon_year, c.mon_firstday, c.mon_lastday, c.FiscalYear, c.FiscalYear_startdate, c.FiscalYear_enddate , c.FiscalYear_mon
from {{ ref("dim_calendar") }}  c 
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
case when a.SFDC_record_type = 'L'  then a.sfdc_district_enrollment else a.sfdc_school_enrollment end as district_enrollment,
case when (a.sfdc_state_initiative or a.sfdc_state_initiative_school) then true else false end as state_initiative,
a.sfdc_urban_rural as urban_rural,
sku.sku_id,
sku.sku_name,
floh.schoolcount,
floh.studentcount
from (
    select 
     floh.order_id,
     floh.organization_district_id,
     case when trunc(floh.fromdate) = '{{ var("default_date") }}' then flo.auditcreatedate else floh.fromdate end as fromdate,
     floh.todate,
     floh.sku_id,
     floh.startdate,
     floh.expirationdate,
     floh.enforcedaterestrictions,
     floh.schoolcount,
     floh.studentcount,
     floh.valid,
     floh.netsuite_order_id
     from
    {{ ref("fact_license_order_history") }} floh
    join {{ ref("vw_fact_license_order") }} flo
    on floh.order_id = flo.order_id
    )  floh
join {{ ref("dim_lcom_sku") }} sku
on floh.sku_id = sku.sku_id
join dim_month m
on 
case when m.mon_lastday<trunc(GETDATE()) then m.mon_lastday else trunc(GETDATE()) end between floh.fromdate and floh.todate
AND
case when m.mon_lastday<trunc(GETDATE()) then m.mon_lastday else trunc(GETDATE()) end between floh.startdate and floh.expirationdate
join {{ ref("dim_account_history") }} a
on floh.organization_district_id = a.account_id
and m.mon_lastday between a.fromdate and a.todate
where a.lcom_trial=false 
and a.lcom_demo=false
and floh.valid='Y'
and floh.netsuite_order_id != 'COVID19' 
and floh.sku_id NOT IN ('63CC161C-A834-4017-8281-ED0C4C4C52B5' --Google Integration
                 ,'CA3A733E-0F33-4918-897B-506C6BD6907C' --Generic LTI Tool Consumer
                 ,'545DA6FB-B65D-4EA8-A374-30BEEAAA28D4' --Tech Apps TCEA Assessment MS 19/20+'
                           )
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
