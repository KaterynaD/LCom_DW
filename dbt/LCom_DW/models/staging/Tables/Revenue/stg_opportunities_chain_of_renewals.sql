
{{ config(
   materialized='sql_runner',
   deployment_date='2026-06-03',
   pre_hook = [
                    '{{ create_stg_opportunities_chain_of_renewals() }}', 
                    '{{ create_processing_opportunities_chain_of_renewals() }}'
                   ]
) }}

-- depends_on: {{ ref('stg_revenue') }} 


call {{ target.database }}.{{ schema }}.processing_opportunities_chain_of_renewals(cast('{{ var("loaddate") }}' as timestamp));