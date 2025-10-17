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
    ,CASE 
        WHEN f.start_date > CURRENT_DATE THEN 'Upcoming'
        WHEN f.start_date = CURRENT_DATE THEN 'Current'
        WHEN f.start_date < CURRENT_DATE THEN 'Past'
    END AS start_date_timeframe
    --Assigned to in m.mon_year
    ,e.name  as   Assignee
    ,fh.pds_group  

    --Currently Assigned 
    ,ce.name  as   Assignee_current
    ,f.pds_group  as  pds_group_current

    --Account
    ,f.new_district
    ,ah.lcom_organization_id
    ,ah.lcom_organization_type
    ,ah.sfdc_account_id
    ,ah.SFDC_name account_name
    ,ah.lcom_organization_name
    ,pa.SFDC_name ultimate_parent_account_name
    ,pa.lcom_organization_name ultimate_parent_lcom_organization_name
    ,a.sfdc_category    
    ,ah.sfdc_customer_level account_customer_level
    ,ah.sfdc_billing_country country
    ,CASE 
        WHEN ah.lcom_state_province_code = 'Unknown' THEN a.sfdc_billing_state_code
        ELSE ah.lcom_state_province_code 
    END AS state
    ,ah.sfdc_county_name as county
    ,case when (ah.sfdc_state_initiative or ah.sfdc_state_initiative_school) then true else false end as account_state_initiative
    ,ah.SFDC_state_program_eligible as account_state_program_eligible
    ,ah.sfdc_urban_rural as account_urban_rural
    ,case
                when ah.sfdc_district_enrollment = 0 then ah.sfdc_school_enrollment
                else ah.sfdc_district_enrollment 
        end as account_district_enrollment    
    ,ah.sfdc_owner_name_text as account_owner_name	
    --
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
    ,t.topic
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
    join {{ ref('dim_account_history') }} ah
      on f.account_id = ah.account_id
and case when m.mon_lastday<trunc(GETDATE()) then m.mon_lastday else trunc(GETDATE()) end between ah.fromdate and ah.todate      
    join {{ ref('dim_account') }} a
      on f.account_id = a.account_id   
    join {{ ref('dim_account') }} pa
      on a.sfdc_ultimate_parent_id = pa.account_id                
    join {{ source("common","dim_calendar") }} dc
      on trunc(f.start_date) = dc.cal_date
    join {{ ref('dim_training_session_topic_session') }} tst
      on f.training_session_id = tst.training_session_id
    join {{ ref('dim_training_session_topic') }} t
      on tst.topic_id = t.topic_id

