{{
    config(

        materialized='table',        
        sort='contact_id', 
        dist='contact_id'  ,
        post_hook=['{{ update_counts_of_opportunities() }}' ]
        
        )
}}


	--primary contact
    SELECT DISTINCT
    o.opportunity_id,
    o.contact_id,
    o.created_date as opp_created_date,
    o.close_date as opp_close_date,
    case when o.stage_name ilike '%closed%' then true else false end as is_closed,
    case when o.stage_name ilike '%Won%' and o.invoiced_date != '{{ var("default_date") }}' then true else false end as is_won,
    o.amount as opp_amount,
    o.opp_record_type as opp_type,
    o.campaign_id
  FROM {{ ref("fact_opportunity") }}  o
  WHERE o.created_date > '2023-06-30'
    AND o.contact_id <> '{{ var("default_ID") }}'
   union
   --1st contact
   SELECT DISTINCT
    o.opportunity_id,
    o.x_1_st_contact as contact_id,
    o.created_date as opp_created_date,
    o.close_date as opp_close_date,
    case when o.stage_name like '%closed%' then true else false end as is_closed,
    case when o.stage_name like '%Won%' and o.invoiced_date != '{{ var("default_date") }}' then true else false end as is_won,
    o.amount as opp_amount,
    o.opp_record_type as opp_type,
    o.campaign_id
  FROM {{ ref("fact_opportunity") }}  o
  WHERE o.created_date > '2023-06-30'
    AND o.x_1_st_contact != '{{ var("default_ID") }}'
    UNION
   --2nd contact
   SELECT DISTINCT
    o.opportunity_id,
    o.x_2_nd_contact as contact_id,
    o.created_date as opp_created_date,
    o.close_date as opp_close_date,
    case when o.stage_name like '%closed%' then true else false end as is_closed,
    case when o.stage_name like '%Won%' and o.invoiced_date != '{{ var("default_date") }}' then true else false end as is_won,
    o.amount as opp_amount,
    o.opp_record_type as opp_type,
    o.campaign_id
  FROM {{ ref("fact_opportunity") }}  o
  WHERE o.created_date > '2023-06-30'
    AND o.x_2_nd_contact != '{{ var("default_ID") }}'
    UNION
    --3rd contact
   SELECT DISTINCT
    o.opportunity_id,
    o.x_3_rd_contact as contact_id,
    o.created_date as opp_created_date,
    o.close_date as opp_close_date,
    case when o.stage_name like '%closed%' then true else false end as is_closed,
    case when o.stage_name like '%Won%' and o.invoiced_date != '{{ var("default_date") }}' then true else false end as is_won,
    o.amount as opp_amount,
    o.opp_record_type as opp_type,
    o.campaign_id
  FROM {{ ref("fact_opportunity") }}  o
  WHERE o.created_date > '2023-06-30'
    AND o.x_3_rd_contact != '{{ var("default_ID") }}'
  