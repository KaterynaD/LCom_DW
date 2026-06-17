{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select
f.record_type,
f.mon_year,
f.mon_lastday,
f.fiscalyear,
f.fiscalyear_mon,
f.opportunity_id,
o.netsuite_id,
o.opportunity_number,
o.name as opportunity_name,
f.stage_name,
f.opp_record_type ,
f.sfdc_account_id,
f.sfdc_state_initiative account_state_initiative,
f.sfdc_ultimate_parent_id,
f.invoiced_date ,
f.close_date,
f.start_date,
f.end_date,
f.renewal_opportunity_id,
f.renewal_stage_name,
f.renewal_invoiced_date,
f.renewal_close_date,
f.disable_auto_renewal_opp,
f.license_unenforced,
f.Bucket_original,
f.Bucket,
f.amount,
f.include_flg,
f.audit_id,
f.new_opp_this_fy_flg,
ah.sfdc_name as account_name,
uah.sfdc_name as ultimate_parent_account_name,
uah.sfdc_billing_state state,
uah.sfdc_billing_country country,
case when uah.sfdc_district_enrollment=0 then uah.sfdc_school_enrollment else uah.sfdc_district_enrollment end as district_enrollment,
case when (uah.sfdc_state_initiative or uah.sfdc_state_initiative_school) then true else false end as state_initiative,
uah.sfdc_urban_rural as urban_rural ,
uah.sfdc_owner_name_text as account_owner_name,
ua.sfdc_owner_name_text as current_account_owner_name,
f.loaddate 
from {{ ref("vw_fact_revenue_monthly_snapshots") }} f
join {{ ref("dim_account") }} ua
on f.sfdc_ultimate_parent_id = ua.sfdc_account_id
join {{ ref("dim_account_history") }} uah
on f.sfdc_ultimate_parent_id = uah.sfdc_account_id
and f.mon_lastday between uah.fromdate and  uah.todate
join {{ ref("dim_account_history") }} ah
on f.sfdc_account_id = ah.sfdc_account_id
and f.mon_lastday between ah.fromdate and  ah.todate
left outer join {{ ref("fact_opportunity") }} o
on f.opportunity_id = o.opportunity_id
