{{ config(materialized='view', bind=False) }}

 -- V10 Optimized: Historic Lead Stages with Full Contact Details
 --added campaign ID and campaign name from opportunity table
-- MQL dates go back to 23/24 SY
WITH all_opportunity_contacts AS (
  -- Union all possible contact-opportunity relationships
  SELECT 
    o.id as opportunity_id,
    o.contact_id,
    'Primary' as contact_position,
    o.created_date as opp_created_date,
    o.close_date as opp_close_date,
    o.is_closed,
    o.is_won,
    o.amount_won_c as opp_amount,
    o.type as opp_type,
    o.campaign_id,
    cp.name as campaign_name
  FROM {{ source('fivetran_salesforce_quickstart', 'opportunity') }} o
  	left join {{ source('fivetran_salesforce_quickstart', 'campaign') }} cp
  		on o.campaign_id = cp.id
  WHERE o.created_date > '2024-06-30'
    AND o.contact_id IS NOT NULL
  UNION ALL
  SELECT 
    o.id, o.x_1_st_contact_c, '1st Contact',
    o.created_date, o.close_date, o.is_closed, o.is_won, o.amount_won_c as opp_amount,
    o.type as opp_type, o.campaign_id, cp.name as campaign_name
  FROM {{ source('fivetran_salesforce_quickstart', 'opportunity') }} o
  left join {{ source('fivetran_salesforce_quickstart', 'campaign') }} cp
  		on o.campaign_id = cp.id
  WHERE o.created_date > '2024-06-30' AND o.x_1_st_contact_c IS NOT NULL
  UNION ALL
  SELECT 
    o.id, o.x_2_nd_contact_c, '2nd Contact',
    o.created_date, o.close_date, o.is_closed, o.is_won,  o.amount_won_c as opp_amount,
    o.type as opp_type, o.campaign_id, cp.name as campaign_name
  FROM {{ source('fivetran_salesforce_quickstart', 'opportunity') }} o
  left join {{ source('fivetran_salesforce_quickstart', 'campaign') }} cp
  		on o.campaign_id = cp.id
  WHERE o.created_date > '2024-06-30' AND o.x_2_nd_contact_c IS NOT NULL
  UNION ALL
  SELECT 
    o.id, o.x_3_rd_contact_c, '3rd Contact',
    o.created_date, o.close_date, o.is_closed, o.is_won,  o.amount_won_c as opp_amount,
    o.type as opp_type, o.campaign_id, cp.name as campaign_name
  FROM {{ source('fivetran_salesforce_quickstart', 'opportunity') }} o
  left join {{ source('fivetran_salesforce_quickstart', 'campaign') }} cp
  		on o.campaign_id = cp.id
  WHERE o.created_date > '2024-06-30' AND o.x_3_rd_contact_c IS NOT NULL
),
opp_with_contact_dates AS (
  SELECT 
    aoc.*,
    c.mql_date_c,
    COALESCE(c.sql_date_c, c.sql_date_hubspot_c) as sql_date
  FROM all_opportunity_contacts aoc
  LEFT JOIN {{ source('fivetran_salesforce_quickstart', 'contact') }} c ON aoc.contact_id = c.id
),
latest_opp_per_contact AS (
  SELECT 
    contact_id,
    opportunity_id,
    opp_created_date,
    ROW_NUMBER() OVER (PARTITION BY contact_id ORDER BY opp_created_date DESC) as rn
  FROM all_opportunity_contacts
),
first_won_after_mql AS (
  SELECT 
    contact_id,
    opportunity_id,
    opp_close_date,
    opp_amount,
    opp_type,
    campaign_id,
    campaign_name,
    ROW_NUMBER() OVER (PARTITION BY contact_id ORDER BY opp_close_date ASC) as rn
  FROM opp_with_contact_dates
  WHERE is_won = TRUE 
    AND is_closed = TRUE
    AND opp_close_date >= mql_date_c
),
first_won_after_sql AS (
  SELECT 
    contact_id,
    opportunity_id,
    opp_close_date,
    opp_amount,
    opp_type,
    campaign_id,
    campaign_name,
    ROW_NUMBER() OVER (PARTITION BY contact_id ORDER BY opp_close_date ASC) as rn
  FROM opp_with_contact_dates
  WHERE is_won = TRUE 
    AND is_closed = TRUE
    AND sql_date IS NOT NULL
    AND opp_close_date >= sql_date
),
contact_opportunity_summary AS (
  SELECT
    aoc.contact_id,
    COUNT(DISTINCT aoc.opportunity_id) as opportunity_count,
    COUNT(DISTINCT CASE WHEN aoc.is_closed AND aoc.is_won THEN aoc.opportunity_id END) as won_count,
    COUNT(DISTINCT CASE WHEN aoc.is_closed AND NOT aoc.is_won THEN aoc.opportunity_id END) as lost_count,
    MAX(lo.opp_created_date) as latest_opp_created,
    MAX(CASE WHEN lo.rn = 1 THEN lo.opportunity_id END) as latest_opp_id,
    MAX(CASE WHEN aoc.is_won THEN aoc.opp_close_date END) as latest_won_date,
    MIN(CASE WHEN fwm.rn = 1 THEN fwm.opp_close_date END) as first_won_date_after_mql,
    MIN(CASE WHEN fwm.rn = 1 THEN fwm.opportunity_id END) as first_won_opp_id_after_mql,
    MIN(CASE WHEN fwm.rn = 1 THEN fwm.opp_amount END) as first_won_amount_after_mql,
    MIN(CASE WHEN fwm.rn = 1 THEN fwm.opp_type END) as first_won_opp_type_after_mql,
    MIN(CASE WHEN fwm.rn = 1 THEN fwm.campaign_id END) as first_won_campaign_id_after_mql,
    MIN(CASE WHEN fwm.rn = 1 THEN fwm.campaign_name END) as first_won_campaign_name_after_mql,
    MIN(CASE WHEN fws.rn = 1 THEN fws.opp_close_date END) as first_won_date_after_sql,
    MIN(CASE WHEN fws.rn = 1 THEN fws.opportunity_id END) as first_won_opp_id_after_sql,
    MIN(CASE WHEN fws.rn = 1 THEN fws.opp_amount END) as first_won_amount_after_sql,
    MIN(CASE WHEN fws.rn = 1 THEN fws.opp_type END) as first_won_opp_type_after_sql,
    MIN(CASE WHEN fws.rn = 1 THEN fws.campaign_id END) as first_won_campaign_id_after_sql,
    MIN(CASE WHEN fws.rn = 1 THEN fws.campaign_name END) as first_won_campaign_name_after_sql,
    SUM(DISTINCT aoc.opp_amount) as opp_amount_total,
    SUM(DISTINCT CASE WHEN aoc.is_won THEN aoc.opp_amount END) as won_amount_total
  FROM all_opportunity_contacts aoc
  LEFT JOIN latest_opp_per_contact lo ON aoc.contact_id = lo.contact_id
  LEFT JOIN first_won_after_mql fwm ON aoc.contact_id = fwm.contact_id
  LEFT JOIN first_won_after_sql fws ON aoc.contact_id = fws.contact_id
  GROUP BY aoc.contact_id
),
-- OPTIMIZATION: Define stages as inline data instead of 6 separate UNIONs
stage_definitions AS (
  SELECT 'MQL' as stage_name, 1 as stage_order
  UNION ALL SELECT 'Qualifying', 2
  UNION ALL SELECT 'Rejected', 3
  UNION ALL SELECT 'Returned', 4
  UNION ALL SELECT 'SQL', 5
  UNION ALL SELECT 'Closed Won', 6
),
-- OPTIMIZATION: Single scan of contacts with all stage information
contacts_with_all_stages AS (
  SELECT
    c.id as contact_id,
    c.name as contact_name,
    c.first_name,
    c.last_name,
    c.title,
    -- Owner info
    e.name as owner_name,
   	e.user_role as owner_role,
    -- Current status
    c.lead_status_c as raw_current_lead_stage,
    CASE 
      WHEN cos.first_won_opp_id_after_mql IS NOT NULL OR cos.first_won_opp_id_after_sql IS NOT NULL 
      THEN 'Closed Won'
      when c.lead_status_c is null then 'Unknown'
      ELSE c.lead_status_c 
    END as current_lead_stage,
    CASE 
      WHEN cos.first_won_date_after_sql IS NOT NULL THEN cos.first_won_date_after_sql
      WHEN cos.first_won_date_after_mql IS NOT NULL THEN cos.first_won_date_after_mql
      WHEN c.lead_status_c = 'MQL' THEN c.mql_date_c
      WHEN c.lead_status_c = 'Qualifying' THEN COALESCE(c.qualifying_date_c, c.qualifying_date_hubspot_c)
      WHEN c.lead_status_c = 'Returned' THEN COALESCE(c.returned_date_c, c.returned_date_hubspot_c)
      WHEN c.lead_status_c = 'Rejected' THEN COALESCE(c.rejected_date_c, c.rejected_date_hubspot_c)
      WHEN c.lead_status_c = 'SQL' THEN COALESCE(c.sql_date_c, c.sql_date_hubspot_c)
    END as current_lead_stage_date,
    -- All historic stage dates (collected once)
    c.mql_date_c as mql_date,
    COALESCE(c.qualifying_date_c, c.qualifying_date_hubspot_c) as qualifying_date,
    COALESCE(c.rejected_date_c, c.rejected_date_hubspot_c) as rejected_date,
    COALESCE(c.returned_date_c, c.returned_date_hubspot_c) as returned_date,
    COALESCE(c.sql_date_c, c.sql_date_hubspot_c) as sql_date,
    COALESCE(cos.first_won_date_after_sql, cos.first_won_date_after_mql) as closed_won_date,
    -- Origin and schoolyear info
    CASE 
      WHEN c.mql_type_c IS NULL THEN 'Unknown'
      WHEN c.mql_type_c = 'Webform' THEN 'State Landing Page' 
      ELSE c.mql_type_c 
    END as mql_origin,
    c.mql_year_c as mql_year,
    c.mql_month_c as mql_month,
    dcm.schoolyear as mql_schoolyear,
    dcm.schoolyear_mon as mql_schoolyear_month,
    dcq.schoolyear as qualifying_schoolyear,
    dcs.schoolyear as sql_schoolyear,
    -- Opportunity info
    COALESCE(cos.first_won_date_after_mql, cos.first_won_date_after_sql) as closed_won_opp_date,
    COALESCE(cos.first_won_opp_id_after_mql, cos.first_won_opp_id_after_sql) as closed_won_opp_id,
    COALESCE(cos.first_won_amount_after_mql, cos.first_won_amount_after_sql) as closed_won_opp_amount,
    COALESCE(cos.first_won_campaign_id_after_mql, cos.first_won_campaign_id_after_sql) as closed_won_opp_campaign_id,
    COALESCE(cos.first_won_campaign_name_after_mql, cos.first_won_campaign_name_after_sql) as closed_won_opp_campaign_name,
         -- Opportunity metrics
    COALESCE(cos.opportunity_count, 0) as opportunity_count,
    COALESCE(cos.won_count, 0) as won_opportunity_count,
    COALESCE(cos.lost_count, 0) as lost_opportunity_count,
    cos.latest_opp_id,
    cos.latest_opp_created,
    cos.latest_won_date,
    cos.first_won_date_after_mql,
    cos.first_won_opp_id_after_mql,
    cos.first_won_amount_after_mql,
    cos.first_won_opp_type_after_mql,
    cos.first_won_date_after_sql,
    cos.first_won_opp_id_after_sql,
    cos.first_won_amount_after_sql,
    cos.first_won_opp_type_after_sql,
    cos.opp_amount_total,
    cos.won_amount_total,
    -- Activity tracking
    c.created_date::date as created_date,
    c.last_activity_date,
    c.last_modified_date,
    CASE WHEN c.last_activity_date >= (CURRENT_DATE - INTERVAL '30 days') THEN TRUE ELSE FALSE END as active_last_30_days,
    CASE WHEN c.last_activity_date >= (CURRENT_DATE - INTERVAL '90 days') THEN TRUE ELSE FALSE END as active_last_90_days,
    -- Account info
    c.account_id,
    ra.name as account_name,
    ra.state_initiative_c as is_state_initiative_district,
    c.contact_state_c as contact_state,
    c.mailing_state as contact_mailing_state,
    c.mailing_state_code,
    COALESCE(ra.billing_state, a.sfdc_billing_state, a.lcom_state_province_name) as account_state_name,
    COALESCE(ra.billing_state_code, a.sfdc_billing_state_code, a.lcom_state_province_code) as account_state_code,
    ra.lcom_organization_c as lcom_organization_id,
    ra.lcom_organization_district_c as lcom_organization_district,
    ra.category_c as account_category,
    ra.customer_type_c as account_customer_type,
    ra.customer_level_c as account_customer_level,
    -- Salesforce links
    'https://learning.lightning.force.com/lightning/r/Contact/' || c.id::text || '/view' as sf_contact_url,
    'https://learning.lightning.force.com/lightning/r/Account/' || c.account_id || '/view' as sf_account_url,
    'https://learning.lightning.force.com/lightning/r/Opportunity/' || cos.latest_opp_id || '/view' as sf_latest_opportunity_url,
    'https://learning.lightning.force.com/lightning/r/Opportunity/' || cos.first_won_opp_id_after_mql || '/view' as sf_first_won_opp_after_mql_url,
    'https://learning.lightning.force.com/lightning/r/Opportunity/' || cos.first_won_opp_id_after_sql || '/view' as sf_first_won_opp_after_sql_url,
    -- Conversion flags
    CASE WHEN c.mql_date_c IS NOT NULL AND COALESCE(c.sql_date_c, c.sql_date_hubspot_c) IS NOT NULL 
         THEN TRUE ELSE FALSE END as converted_mql_to_sql,
    CASE WHEN cos.first_won_date_after_mql IS NOT NULL 
         THEN TRUE ELSE FALSE END as converted_mql_to_closed_won,
    CASE WHEN cos.first_won_date_after_sql IS NOT NULL 
         THEN TRUE ELSE FALSE END as converted_sql_to_closed_won,
    -- Opportunity timing checks
    CASE WHEN cos.latest_opp_created >= c.mql_date_c 
         THEN TRUE ELSE FALSE END as opp_created_after_mql,
    CASE WHEN cos.latest_opp_created >= COALESCE(c.sql_date_c, c.sql_date_hubspot_c) 
         THEN TRUE ELSE FALSE END as opp_created_after_sql,
    CASE WHEN cos.first_won_date_after_mql IS NOT NULL 
         THEN TRUE ELSE FALSE END as opp_won_after_mql,
    CASE WHEN cos.first_won_date_after_sql IS NOT NULL 
         THEN TRUE ELSE FALSE END as opp_won_after_sql,
    -- Velocity metrics
    (cos.first_won_date_after_mql::date - c.mql_date_c::date) as days_mql_to_first_won,
    (cos.first_won_date_after_sql::date - COALESCE(c.sql_date_c, c.sql_date_hubspot_c)::date) as days_sql_to_first_won,
    -- Data quality flags
    CASE WHEN (
      (c.account_id IS NULL) OR
      (c.lead_status_c IS NULL AND c.mql_date_c IS NOT NULL) OR
      (c.mql_type_c IS NULL) OR
      (c.contact_state_c <> c.mailing_state) OR
      (c.contact_state_c IS NULL AND c.mailing_state IS NULL AND c.other_state IS NULL) OR
      (COALESCE(c.sql_date_c, c.sql_date_hubspot_c) < c.mql_date_c) OR
      (COALESCE(c.qualifying_date_c, c.qualifying_date_hubspot_c) < c.mql_date_c) OR
      (COALESCE(c.qualifying_date_c, c.qualifying_date_hubspot_c) < c.created_date::date) OR
      (COALESCE(c.sql_date_c, c.sql_date_hubspot_c) < COALESCE(c.qualifying_date_c, c.qualifying_date_hubspot_c)) OR
      (COALESCE(c.rejected_date_c, c.rejected_date_hubspot_c) < c.mql_date_c) OR
      (COALESCE(c.returned_date_c, c.returned_date_hubspot_c) < c.mql_date_c) OR
      (c.lead_status_c = 'SQL' AND COALESCE(c.sql_date_c, c.sql_date_hubspot_c) IS NULL) OR
      (c.mql_date_c > CURRENT_DATE) OR
      (COALESCE(c.sql_date_c, c.sql_date_hubspot_c) > CURRENT_DATE)
    ) THEN TRUE ELSE FALSE END as has_any_data_quality_issue,
    CASE WHEN c.account_id IS NULL THEN TRUE ELSE FALSE END as dq_contact_missing_account_id,
    CASE WHEN c.lead_status_c IS NULL AND c.mql_date_c IS NOT NULL THEN TRUE ELSE FALSE END as dq_missing_lead_status,
    CASE WHEN c.mql_type_c IS NULL THEN TRUE ELSE FALSE END as dq_missing_mql_type,
    CASE WHEN c.contact_state_c <> c.mailing_state THEN TRUE ELSE FALSE END as dq_contact_state_mailing_state_mismatch,
    CASE WHEN c.contact_state_c IS NULL AND c.mailing_state IS NULL AND c.other_state IS NULL THEN TRUE ELSE FALSE END as dq_contact_missing_state,
    CASE WHEN COALESCE(c.sql_date_c, c.sql_date_hubspot_c) < c.mql_date_c THEN TRUE ELSE FALSE END as dq_sql_date_before_mql_date,
    CASE WHEN COALESCE(c.qualifying_date_c, c.qualifying_date_hubspot_c) < c.mql_date_c THEN TRUE ELSE FALSE END as dq_qualifying_date_before_mql_date,
    CASE WHEN COALESCE(c.qualifying_date_c, c.qualifying_date_hubspot_c) < c.created_date::date THEN TRUE ELSE FALSE END as dq_qualifying_before_created_date,
    CASE WHEN COALESCE(c.sql_date_c, c.sql_date_hubspot_c) < COALESCE(c.qualifying_date_c, c.qualifying_date_hubspot_c) THEN TRUE ELSE FALSE END as dq_sql_before_qualifying_date,
    CASE WHEN COALESCE(c.rejected_date_c, c.rejected_date_hubspot_c) < c.mql_date_c THEN TRUE ELSE FALSE END as dq_rejected_date_before_mql_date,
    CASE WHEN COALESCE(c.returned_date_c, c.returned_date_hubspot_c) < c.mql_date_c THEN TRUE ELSE FALSE END as dq_returned_date_before_mql_date,
    CASE WHEN c.lead_status_c = 'SQL' AND COALESCE(c.sql_date_c, c.sql_date_hubspot_c) IS NULL THEN TRUE ELSE FALSE END as dq_sql_status_without_sql_date,
    CASE WHEN c.mql_date_c > CURRENT_DATE THEN TRUE ELSE FALSE END as dq_mql_date_in_future,
    CASE WHEN COALESCE(c.sql_date_c, c.sql_date_hubspot_c) > CURRENT_DATE THEN TRUE ELSE FALSE END as dq_sql_date_in_future
  FROM {{ source('fivetran_salesforce_quickstart', 'contact') }} c
  LEFT JOIN {{ ref("dim_employee") }}  e ON c.owner_id = e.employee_id
  LEFT JOIN {{ ref("dim_account") }} a ON c.account_id = a.account_id
  LEFT JOIN {{ source('fivetran_salesforce_quickstart', 'account') }} ra ON c.account_id = ra.account_id_c
  LEFT JOIN contact_opportunity_summary cos ON c.id = cos.contact_id
  LEFT JOIN {{ source("common","dim_calendar") }} dcm ON c.mql_date_c = dcm.cal_date
  LEFT JOIN {{ source("common","dim_calendar") }} dcs ON COALESCE(c.sql_date_c, c.sql_date_hubspot_c) = dcs.cal_date
  LEFT JOIN {{ source("common","dim_calendar") }} dcq ON COALESCE(c.qualifying_date_c, c.qualifying_date_hubspot_c) = dcq.cal_date
  WHERE c.mql_date_c > '2023-06-30' --MCL from beginning of 24/25 SY
)
-- OPTIMIZATION: Use CROSS JOIN with filter instead of 6 UNIONs
-- This unpivots the stages while only scanning contacts_with_all_stages once
SELECT
  cwas.*,
  sd.stage_name as historic_lead_stage,
  sd.stage_order as historic_stage_order,
  -- Get the appropriate date for this historic stage
  CASE sd.stage_name
    WHEN 'MQL' THEN cwas.mql_date
    WHEN 'Qualifying' THEN cwas.qualifying_date
    WHEN 'Rejected' THEN cwas.rejected_date
    WHEN 'Returned' THEN cwas.returned_date
    WHEN 'SQL' THEN cwas.sql_date
    WHEN 'Closed Won' THEN cwas.closed_won_date
  END as historic_lead_date
FROM contacts_with_all_stages cwas
CROSS JOIN stage_definitions sd
-- Filter to only include stages the contact actually reached
WHERE CASE sd.stage_name
  WHEN 'MQL' THEN cwas.mql_date IS NOT NULL
  WHEN 'Qualifying' THEN cwas.qualifying_date IS NOT NULL
  WHEN 'Rejected' THEN cwas.rejected_date IS NOT NULL
  WHEN 'Returned' THEN cwas.returned_date IS NOT NULL
  WHEN 'SQL' THEN cwas.sql_date IS NOT NULL
  WHEN 'Closed Won' THEN cwas.closed_won_date IS NOT NULL
end
