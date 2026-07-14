{{ config(materialized='ephemeral') }}

select 
training_session_id,
account_id,
status,
owner_id,
pds_group,
created_date,
last_modified_date 
from {{ ref("fact_training_session") }}
