
{{ config(
   materialized='sql_runner',
   pre_hook = [
                    '{{ create_sfdc_ultimate_parent_accounts_data() }}', 
                    '{{ create_processing_ultimate_parent_accounts() }}'
                   ]
) }}

-- depends_on: {{ source('fivetran_salesforce_quickstart', 'account') }} 
-- depends_on: {{ source('fivetran_salesforce_quickstart', 'opportunity') }}

call {{ target.database }}.{{ schema }}.processing_ultimate_parent_accounts(cast('{{ var("loaddate") }}' as timestamp));