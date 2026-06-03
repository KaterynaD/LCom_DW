
{{ config(
   materialized='sql_runner',
   pre_hook = [
                    '{{ create_stg_opportunities_chain_of_renewals_v2() }}', 
                    '{{ create_processing_opportunities_chain_of_renewals_v2() }}'
                   ]
) }}

-- depends_on: {{ ref('stg_valid_opportunities') }} 

call {{ target.database }}.{{ schema }}.processing_opportunities_chain_of_renewals_v2(cast('{{ var("loaddate") }}' as timestamp));