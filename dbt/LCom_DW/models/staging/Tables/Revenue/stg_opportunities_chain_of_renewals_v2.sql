
{{ config(
   materialized='sql_runner'
) }}

-- depends_on: {{ ref('stg_valid_opportunities') }} 
-- depends_on: {{ ref("dim_calendar") }}

call {{ target.database }}.{{ schema }}.processing_opportunities_chain_of_renewals_v2(cast('{{ var("loaddate") }}' as timestamp));