{{ config(
    materialized = 'view',
    bind = false
) }}

with dim_month as --Thread to calculate monthly metrics
(select distinct c.mon_year,  c.mon_lastday
from {{ source("common","dim_calendar") }}  c 
where mon_year between 202508 and to_char(GetDate(),'yyyymm')
)
select
    --Calendar Month (history)
     m.mon_year
    ,m.mon_lastday

    --FiscalYear and month based on Start Date
    ,dc.FiscalYear
    ,dc.FiscalYear_mon
    --
    ,f.training_session_id 
	  ,f.name as session_name 
    ,f.session_type   
	  ,f.session_subtype  
    ,r.name  as   Requestor
    ,f.start_date as session_start_date
    --
    ,fh.status as session_status
    ,f.status as  session_status_current

    --Assigned to in m.mon_year
    ,e.name  as   Assignee
    ,fh.pds_group  

    --Currently Assigned 
    ,ce.name  as   Assignee_current
    ,f.pds_group  as  pds_group_current

    --Account
    ,a.sfdc_account_id
    ,a.SFDC_name account_name
    ,a.sfdc_customer_level account_customer_level
    ,a.SFDC_billing_state as account_state
    ,case when (a.sfdc_state_initiative or a.sfdc_state_initiative_school) then true else false end as account_state_initiative
    ,a.SFDC_state_program_eligible as account_state_program_eligible
    ,a.sfdc_urban_rural as account_urban_rural
    ,case
                when a.sfdc_district_enrollment = 0 then a.sfdc_school_enrollment
                else a.sfdc_district_enrollment 
        end as account_district_enrollment    
    ,a.sfdc_owner_name_text as account_owner_name	

    --Session details
    ,f.session_location_address
    ,f.session_location_unknown
    ,f.session_attendee_count
    ,f.session_notes

    --Implementation details
    ,f.implementation_topics
    ,f.implementation_advanced_topics
    ,f.implementation_notes
    --
    ,f.notes
    --
    --Session Survey details
    ,f.survey_action_items    
    ,f.survey_administrator_attendance
    ,f.survey_attendee_challenges    
    ,f.survey_attendee_count
    ,f.survey_teacher_engagement
    ,f.survey_teacher_sentiment
    ,f.survey_notable_discussions  
    ,f.survey_notes  
    ,f.survey_outcome_issues
    ,f.survey_recommendations
    from dim_month m
    join {{ ref('fact_training_session_history') }} fh
    on case when m.mon_lastday<trunc(GETDATE()) then m.mon_lastday else trunc(GETDATE()) end between fh.fromdate and fh.todate
    join {{ ref('fact_training_session') }} f
    on f.training_session_id = fh.training_session_id
    join {{ ref('dim_employee') }} e
      on fh.owner_id = e.employee_id
     join {{ ref('dim_employee') }} ce
      on f.owner_id = ce.employee_id
     join {{ ref('dim_employee') }} r
      on f.requestor_id = r.employee_id      
    join {{ ref('dim_account_history') }} a
      on f.account_id = a.account_id
      and case when m.mon_lastday<trunc(GETDATE()) then m.mon_lastday else trunc(GETDATE()) end between a.fromdate and a.todate
    join {{ source("common","dim_calendar") }} dc
      on trunc(f.start_date) = dc.cal_date

