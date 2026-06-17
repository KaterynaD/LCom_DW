{{ config(materialized='view', bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]) }}

--V19 - query using DW tables
--adding rejected reason and other newly added fields
select
--contact basics
l.contact_id,
c.name as contact_name,
c.title,
c.mql_type as mql_origin,
c.owner_id as contact_owner_id,
c.owner_name as contact_owner_name,
c.owner_user_role as contact_owner_role,
--lead stage and dates
l.lead_stage_historic,
c.lead_status as lead_stage_current,
dc.schoolyear as lead_stage_schoolyear,
case when l.lead_stage_historic = c.lead_status then true else false end as is_historic_lead_stage_current,
l.lead_stage_date_unified,
case when l.lead_stage_date_unified <> l.lead_stage_date_hubspot or l.lead_stage_date_unified <> l.lead_stage_date_manual
	then l.lead_stage_date_unified else '1900-01-01' end as lead_stage_date_historic,
l.lead_stage_date_hubspot,
l.lead_stage_date_manual,
l.lead_stage_changed_by_id,
e.name as lead_stage_changed_by_name,
e.user_role as lead_stage_changed_by_role,
--contact details
c.first_name,
c.last_name,
c.phone,
c.email,
c.contact_state,
c.mailing_state,
c.mailing_state_code,
c.other_state,
c.source_campaign as contact_source_campaign,
c.key_contact as is_key_contact,
c.created_date as contact_created_date,
c.last_activity_date as contact_last_activity_date,
c.last_modified_date as contact_last_modified_date,
--new fields added feb 2026
c.reject_reason,
c.how_did_you_hear_about_us,
c.first_platform_login_date,
c.lead_source,
--account info
c.account_id,
c.sfdc_account_id,
c.sfdc_account_name,
a.lcom_organization_id,
a.lcom_organization_name,
a.lcom_organization_type,
--won opportunity
l.won_opp_id,
fo.name as won_opp_name,
l.won_opp_date,
fo.invoiced_date as won_opp_invoiced_date,
l.won_opp_amount,
l.won_opp_type,
l.won_opp_mql_date,
l.won_opp_sql_date,
l.won_opp_is_after_mql,
l.won_opp_is_after_sql,
--other opportunity info
c.opportunity_count,
c.won_count as won_opp_count,
c.lost_count as lost_opp_count,
--campaign
l.won_opp_campaign_id,
cp.name as campaign_name,
cp.campaign_type,
cp.campaign_status,
cp.pipe_bucket as campaign_pipe_bucket,
cp.start_date as campaign_start_date,
cp.end_date as campaign_end_date,
cp.owner_id as campaign_owner_id,
cp.owner_name as campaign_owner_name
 from {{ ref("fact_contact_lifecycle_events") }} l
 	left join {{ ref("dim_campaign") }} cp
 		on l.won_opp_campaign_id = cp.campaign_id
 	left join {{ ref("dim_contact") }} c
 		on l.contact_id = c.contact_id 
 	left join {{ ref("dim_account") }} a
 		on c.account_id = a.account_id
 	left join {{ ref("fact_opportunity") }} fo
 		on l.won_opp_id = fo.opportunity_id
 	left join {{ ref("dim_calendar") }} dc
 		on l.lead_stage_date_unified::date = dc.cal_date
 	left join {{ ref("dim_employee") }} e
 		on l.lead_stage_changed_by_id = e.employee_id	
 	