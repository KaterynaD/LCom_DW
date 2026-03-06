{{ config(
    materialized = 'view',
    bind = false
) }}

with dim_month as --Thread to calculate monthly metrics
(select c.mon_year,  c.mon_lastday
from {{ ref("dim_month") }}   c 
where mon_year between 202505 and to_char(GetDate(),'yyyymm')
)
select
--Calendar Month (history)
     m.mon_year
    ,m.mon_lastday
    --FiscalYear and month based on Case Created Date
    ,dc.FiscalYear
    ,dc.FiscalYear_mon
    --
    ,f.case_id 
    ,f.case_number
    ,f.subject
    ,f.created_date
    ,f.closed_date
    ,f.last_modified_date
    ,f.status current_status
    ,f.is_escalated current_is_escalated
    ,fh.is_escalated 
    ,f.case_type
    ,f.origin
    ,o.name curernt_case_owner
    ,oh.name case_owner
    ,ah.sfdc_account_id
    ,ah.SFDC_name account_name
    ,ah.sfdc_ultimate_parent_account
    ,ah.sfdc_billing_country country
    ,ah.sfdc_billing_state_code state
    ,case when (ah.sfdc_state_initiative or ah.sfdc_state_initiative_school) then true else false end as account_state_initiative
    ,ah.SFDC_state_program_eligible as account_state_program_eligible
    ,ah.sfdc_urban_rural as account_urban_rural
    ,case
      when ah.sfdc_district_enrollment = 0 then ah.sfdc_school_enrollment
      else ah.sfdc_district_enrollment 
     end as account_district_enrollment    
    ,ah.sfdc_owner_name_text as account_owner_name	          
from dim_month m
    join {{ ref("fact_case_history") }} fh
    on case when m.mon_lastday<trunc(GETDATE()) then m.mon_lastday else trunc(GETDATE()) end between fh.fromdate and fh.todate
    join {{ ref("fact_case") }} f
    on f.case_id = fh.case_id
    join {{ ref("dim_employee") }} oh
      on fh.owner_id = oh.employee_id    
    join {{ ref("dim_employee") }} o
      on f.owner_id = o.employee_id           
    join {{ ref("dim_account_history") }} ah
      on f.account_id = ah.account_id
      and case when m.mon_lastday<trunc(GETDATE()) then m.mon_lastday else trunc(GETDATE()) end between ah.fromdate and ah.todate  
    join {{ ref("dim_calendar") }} dc
      on trunc(f.created_date) = dc.cal_date

