
{{ config(
   materialized='sql_runner'
) }}

-- depends_on: {{ source('fivetran_salesforce_quickstart', 'account') }} 
-- depends_on: {{ source('fivetran_salesforce_quickstart', 'opportunity') }}

call {{ target.database }}.{{ schema }}.processing_ultimate_parent_accounts(cast('{{ var("loaddate") }}' as timestamp));