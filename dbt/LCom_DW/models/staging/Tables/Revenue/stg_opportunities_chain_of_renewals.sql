
{{ config(
   materialized='sql_runner'
) }}

-- depends_on: {{ ref('stg_revenue') }} 


call {{ target.database }}.{{ schema }}.processing_opportunities_chain_of_renewals(cast('{{ var("loaddate") }}' as timestamp));