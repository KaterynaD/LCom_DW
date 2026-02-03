{{ config(materialized='view', bind=False) }}

 select
--contact info
  	s.contact_id,
  	c.name as contact_name,
  	c.first_name,
  	c.last_name,
  	c.title,
  	c.email,
  	--ownership
  	c.owner_id,
  	c.owner_name,
  	c.owner_user_role,
  	--Origin
  	CASE 
    WHEN c.mql_type IS NULL THEN 'Unknown'
    WHEN c.mql_type = 'Webform' THEN 'State Landing Page' --new de facto name for this origin
    ELSE c.mql_type 
  		END as mql_origin,
  	--lead stage and associated dates
  	s.lead_stage_historic,
  	c.lead_status as lead_stage_current,
  	case when s.lead_stage_historic = c.lead_status then true else false end as is_historic_lead_stage_current,
  	s.lead_stage_date_unified,
  	s.lead_stage_date_historic,
  	s.lead_stage_date_hubspot,
  	s.lead_stage_date_manual,
 	s.lead_stage_changed_by_id, 
  	e.name lead_stage_changed_by_name,
  	e.user_role lead_stage_changed_by_role,
  	--school year
  	dc.schoolyear as lead_stage_schoolyear,
  	--opportunity and campaign details
  	c.opportunity_count,
  	c.won_count,
  	c.lost_count,
  	s.won_opp_id,
    s.won_opp_date,
    s.won_opp_amount,
    s.won_opp_type,
    s.won_opp_campaign_id,
    ca.name as won_opp_campaign_name,
    s.won_opp_mql_date,
    s.won_opp_sql_date,
    s.won_opp_is_after_mql,
    s.won_opp_is_after_sql,
    -- Creation and Activity tracking
  c.created_date::date as created_date,
  c.last_activity_date,
  c.last_modified_date,
  (c.last_activity_date >= CURRENT_DATE - INTERVAL '30 days') as active_last_30_days,
  (c.last_activity_date >= CURRENT_DATE - INTERVAL '90 days') as active_last_90_days,
  -- Account info
  c.account_id,
  c.sfdc_account_name as account_name,
  c.contact_state,
  c.mailing_state as contact_mailing_state,
  c.mailing_state_code,
  COALESCE(a.sfdc_billing_state, a.lcom_state_province_name) as account_state_name,
  COALESCE(a.sfdc_billing_state_code, a.lcom_state_province_code) as account_state_code,
  c.lcom_organization_id,
  c.lcom_organization_name
from {{ ref("fact_contact_lifecycle_events") }}  s
	left join {{ ref("dim_contact") }} c
		on s.contact_id = c.contact_id 
	left join {{ ref("dim_campaign") }} ca
		on s.won_opp_campaign_id = ca.campaign_id     
	left join {{ source("common","dim_calendar") }} dc
		on s.lead_stage_date_unified::date = dc.cal_date 
	left join {{ ref("dim_account") }} a
		on c.account_id = a.account_id
	left join {{ ref("dim_employee") }} e
		on s.lead_stage_changed_by_id = e.employee_id		
where s.lead_stage_date_unified::date > DATE '2023-06-30' --lead stage since beginning of 23/24 SY
