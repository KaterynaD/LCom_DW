{{ config(materialized='view',
   bind=False
)
 }}
with dim_month as
 (
select distinct FiscalYear, FiscalYear_StartDate, FiscalYear_EndDate, FiscalYear_Mon, Mon_FirstDay, Mon_LastDay,Mon_Year from {{ source("common","dim_calendar") }}
)
select
     f.mon_year
	,f.mon_lastday
	,c.FiscalYear
	,c.FiscalYear_Mon	
	,f.record_type 
	,f.include_flg
	,f.sfdc_ultimate_parent_id
	,ah.sfdc_billing_state state
	,a.sfdc_billing_country country
	,ah.sfdc_name	
    ,a.sfdc_district_enrollment
from {{ ref("vw_fact_customers_monthly_snapshots") }} f
join {{ ref("dim_account") }} a 
on f.sfdc_ultimate_parent_id = a.sfdc_account_id
join {{ ref("dim_account_history") }} ah
on a.account_id = ah.account_id
and f.mon_lastday between ah.fromdate and  ah.todate
--
join dim_month c
on f.mon_year=c.mon_year