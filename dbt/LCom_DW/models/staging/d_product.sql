{{ config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='delete+insert',
    on_schema_change='append_new_columns'
) }}

--test model
select
    id,
    name
from {{ source('fivetran_salesforce_quickstart', 'product_2') }}
where created_date <= '2017-12-05 18:20:49.000 -0800'