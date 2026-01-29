{{
    config(

        materialized='table',        
        sort='contact_id', 
        dist='contact_id'  
        
        )
}}

WITH historic_status_dates AS (
    select 
      h.contact_id,
      h.lead_status AS lead_stage_historic,
      case when h.fromdate='1900-01-01' then c.created_date else  h.fromdate end   AS lead_stage_date_historic,
      h.owner_id    AS lead_stage_changed_by_id,
      e.name        AS lead_stage_changed_by_name,
      e.user_role   AS lead_stage_changed_by_role,
      ROW_NUMBER() OVER (
        PARTITION BY h.contact_id, h.lead_status
        ORDER BY h.fromdate DESC
      ) AS rn
  FROM  dw.staging.stg_contact_history h --update to dw.common.vw_contact_history once it is ready to use
  join dw.common.dim_contact c
  on h.contact_id = c.contact_id
  LEFT JOIN dw.common.dim_employee e
    ON h.owner_id = e.employee_id
  WHERE case when h.fromdate='1900-01-01' then c.created_date else  h.fromdate end > DATE '2023-12-31'
    AND h.lead_status <> 'Unknown'
    and h.lead_status <> 'Unkownn'
),
--max change date per status and contact
historic_latest AS (
  SELECT
      contact_id,
      lead_stage_historic,
      lead_stage_date_historic,
      lead_stage_changed_by_id,
      lead_stage_changed_by_name,
      lead_stage_changed_by_role
  FROM historic_status_dates
  WHERE rn = 1
),
contact_status_dates AS (
  SELECT
      c.contact_id,
      'MQL' AS lead_stage_historic,
      NULL AS lead_stage_date_hubspot,
      c.mql_date AS lead_stage_date_manual
  FROM {{ ref("dim_contact")}} c
  WHERE c.mql_date > DATE '2022-12-31'
  UNION ALL
  SELECT
      c.contact_id,
      'Qualifying' AS lead_stage_historic,
      CASE WHEN c.qualifying_date_hubspot > DATE '1900-01-01' THEN c.qualifying_date_hubspot ELSE NULL END AS lead_stage_date_hubspot,
      CASE WHEN c.qualifying_date         > DATE '1900-01-01' THEN c.qualifying_date         ELSE NULL END AS lead_stage_date_manual
  FROM {{ ref("dim_contact")}} c
  WHERE c.qualifying_date_hubspot > DATE '2022-12-31'
     OR c.qualifying_date         > DATE '2022-12-31'
  UNION ALL
  SELECT
      c.contact_id,
      'Returned' AS lead_stage_historic,
      CASE WHEN c.returned_date_hubspot > DATE '1900-01-01' THEN c.returned_date_hubspot ELSE NULL END AS lead_stage_date_hubspot,
      CASE WHEN c.returned_date         > DATE '1900-01-01' THEN c.returned_date         ELSE NULL END AS lead_stage_date_manual
  FROM {{ ref("dim_contact")}} c
  WHERE c.returned_date_hubspot > DATE '2022-12-31'
     OR c.returned_date         > DATE '2022-12-31'
  UNION ALL
  SELECT
      c.contact_id,
      'Rejected' AS lead_stage_historic,
      CASE WHEN c.rejected_date_hubspot > DATE '1900-01-01' THEN c.rejected_date_hubspot ELSE NULL END AS lead_stage_date_hubspot,
      CASE WHEN c.rejected_date         > DATE '1900-01-01' THEN c.rejected_date         ELSE NULL END AS lead_stage_date_manual
  FROM {{ ref("dim_contact")}} c
  WHERE c.rejected_date_hubspot > DATE '2022-12-31'
     OR c.rejected_date         > DATE '2022-12-31'
  UNION ALL
  SELECT
      c.contact_id,
      'SQL' AS lead_stage_historic,
      CASE WHEN c.sql_date_hubspot > DATE '1900-01-01' THEN c.sql_date_hubspot ELSE NULL END AS lead_stage_date_hubspot,
      CASE WHEN c.sql_date         > DATE '1900-01-01' THEN c.sql_date         ELSE NULL END AS lead_stage_date_manual
  FROM {{ ref("dim_contact")}} c
  WHERE c.sql_date_hubspot > DATE '2022-12-31'
     OR c.sql_date > DATE '2022-12-31'
)
--combining historic and contact dates for each stage - only using most recent historic date for that stage
, unified_status_date as (
SELECT
    COALESCE(h.contact_id, c.contact_id)            AS contact_id,
    COALESCE(h.lead_stage_historic, c.lead_stage_historic) AS lead_stage_historic,
    --Historic date takes precident, fall back to HubSpot then manual if not available
    COALESCE(h.lead_stage_date_historic, c.lead_stage_date_hubspot, c.lead_stage_date_manual) AS lead_stage_date_unified,
    h.lead_stage_date_historic,
    c.lead_stage_date_hubspot,
    c.lead_stage_date_manual,
    h.lead_stage_changed_by_id,
    h.lead_stage_changed_by_name,
    h.lead_stage_changed_by_role
FROM contact_status_dates c
FULL OUTER JOIN historic_latest h
  ON c.contact_id = h.contact_id
 AND c.lead_stage_historic = h.lead_stage_historic
)
-- Get MQL and SQL dates per contact for opportunity filtering
 , contact_mql_sql_dates AS (
   SELECT 
     contact_id,
     MAX(CASE WHEN lead_stage_historic = 'MQL' THEN lead_stage_date_unified END) as mql_date,
     MAX(CASE WHEN lead_stage_historic = 'SQL' THEN lead_stage_date_unified END) as sql_date
   FROM unified_status_date
   GROUP BY contact_id)
  -- Join opportunities with contact MQL/SQL dates
, opp_with_contact_dates AS (
  SELECT 
    aoc.*,
    cmsd.mql_date,
    cmsd.sql_date,
    -- Determine the reference date: use SQL if it exists and is after MQL, otherwise use MQL
    CASE 
      WHEN cmsd.sql_date IS NOT NULL AND cmsd.mql_date IS NOT NULL AND cmsd.sql_date >= cmsd.mql_date THEN cmsd.sql_date
      WHEN cmsd.mql_date IS NOT NULL THEN cmsd.mql_date
      ELSE NULL
    END as reference_date
  FROM {{ ref("stg_all_opportunities_contacts") }} aoc
  LEFT JOIN contact_mql_sql_dates cmsd ON aoc.contact_id = cmsd.contact_id
)
-- Get first won opportunity per contact (after reference date) by opp_type
,first_won_by_type AS (
  SELECT 
    contact_id,
    opp_type,
    opportunity_id,
    opp_close_date,
    opp_amount,
    campaign_id,
    mql_date,
    sql_date,
    reference_date,
    ROW_NUMBER() OVER (
      PARTITION BY contact_id, opp_type 
      ORDER BY opp_close_date ASC
    ) as rn
  FROM opp_with_contact_dates
  WHERE is_won = TRUE 
    AND is_closed = TRUE
    AND reference_date IS NOT NULL
    AND opp_close_date >= reference_date
)
-- Create rows for each Closed Won type
-- Original lead stages
, final_unified AS (
  -- from opportunities in different types
  select
    fw.contact_id,
    'Closed Won '+fw.opp_type as lead_stage_historic,
    isnull(fw.opp_close_date, '{{ var("default_date") }}'::DATE) as lead_stage_date_unified,
    '{{ var("default_date") }}'::DATE as lead_stage_date_historic,
    '{{ var("default_date") }}'::DATE as lead_stage_date_hubspot,
    '{{ var("default_date") }}'::DATE as lead_stage_date_manual,
    '{{ var("default_ID") }}'::VARCHAR as lead_stage_changed_by_id,
    '{{ var("default_varchar") }}'::VARCHAR as lead_stage_changed_by_name,
    '{{ var("default_varchar") }}'::VARCHAR as lead_stage_changed_by_role,
    isnull(fw.opportunity_id, '{{ var("default_ID") }}'::VARCHAR) as won_opp_id,
    isnull(fw.opp_close_date, '{{ var("default_date") }}'::DATE) as won_opp_date,
    isnull(fw.opp_amount, {{ var("default_numeric") }}::DECIMAL) as won_opp_amount,
    isnull(fw.opp_type, '{{ var("default_varchar") }}'::VARCHAR) as won_opp_type,
    isnull(fw.campaign_id, '{{ var("default_ID") }}'::VARCHAR) as won_opp_campaign_id,
    isnull(fw.mql_date, '{{ var("default_date") }}'::DATE) as won_opp_mql_date,
    isnull(fw.sql_date, '{{ var("default_date") }}'::DATE) as won_opp_sql_date,
    (fw.mql_date IS NOT NULL AND fw.opp_close_date >= fw.mql_date) as won_opp_is_after_mql,
    (fw.sql_date IS NOT NULL AND fw.opp_close_date >= fw.sql_date) as won_opp_is_after_sql
  from first_won_by_type fw
  where fw.rn = 1 
  UNION ALL
    select
    u.contact_id,
    isnull(u.lead_stage_historic, '{{ var("default_varchar") }}'::VARCHAR),
    isnull(u.lead_stage_date_unified, '{{ var("default_date") }}'::DATE),
    isnull(u.lead_stage_date_historic, '{{ var("default_date") }}'::DATE),
    isnull(u.lead_stage_date_hubspot, '{{ var("default_date") }}'::DATE),
    isnull(u.lead_stage_date_manual, '{{ var("default_date") }}'::DATE),
    isnull(u.lead_stage_changed_by_id, '{{ var("default_ID") }}'::VARCHAR),
    isnull(u.lead_stage_changed_by_name, '{{ var("default_varchar") }}'::VARCHAR),
    isnull(u.lead_stage_changed_by_role, '{{ var("default_varchar") }}'::VARCHAR),
    '{{ var("default_varchar") }}'::VARCHAR as won_opp_id,
    '{{ var("default_date") }}'::DATE as won_opp_date,
    {{ var("default_numeric") }}::DECIMAL as won_opp_amount,
    '{{ var("default_varchar") }}'::VARCHAR as won_opp_type,
    '{{ var("default_varchar") }}'::VARCHAR as won_opp_campaign_id,
    '{{ var("default_date") }}'::DATE as won_opp_mql_date,
    '{{ var("default_date") }}'::DATE as won_opp_sql_date,
    {{ var("default_boolean") }}::BOOLEAN as won_opp_is_after_mql,
    {{ var("default_boolean") }}::BOOLEAN as won_opp_is_after_sql
  from unified_status_date u
)
select
   contact_id::VARCHAR(300)
	,lead_stage_historic::VARCHAR(31)
	,lead_stage_date_unified::DATE
	,lead_stage_date_historic::DATE
	,lead_stage_date_hubspot::DATE
	,lead_stage_date_manual::DATE
	,lead_stage_changed_by_id::VARCHAR(300)
	,lead_stage_changed_by_name::VARCHAR(400)
	,lead_stage_changed_by_role::VARCHAR(240)
	,won_opp_id::VARCHAR(300)
	,won_opp_date::DATE
	,won_opp_amount::NUMERIC(35,10)
	,won_opp_type::VARCHAR(20)
	,won_opp_campaign_id::VARCHAR(300)
	,won_opp_mql_date::DATE
	,won_opp_sql_date::DATE
	,won_opp_is_after_mql::BOOLEAN
	,won_opp_is_after_sql::BOOLEAN
  ,'{{ var("loaddate") }}'::TIMESTAMP WITHOUT TIME ZONE as loaddate
from final_unified s