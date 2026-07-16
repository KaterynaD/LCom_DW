
{{ config(
   materialized='sql_runner',
   pre_hook = [
                    '{{ create_stg_opportunities_chain_of_renewals() }}', 
                    '{{ create_processing_opportunities_chain_of_renewals() }}'
                   ]
) }}

-- depends_on: {{ ref('stg_valid_opportunities') }} 
-- depends_on: {{ ref('fact_opportunity') }}

call {{ target.database }}.{{ schema }}.processing_opportunities_chain_of_renewals_v2(cast('{{ var("loaddate") }}' as timestamp));