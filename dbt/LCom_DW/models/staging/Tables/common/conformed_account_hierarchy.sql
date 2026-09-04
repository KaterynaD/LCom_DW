
{{ config(
   materialized='sql_runner',
   pre_hook = [
                    '{{ create_conformed_account_hierarchy() }}', 
                    '{{ create_lc_load_conformed_account_hierarchy() }}'
                   ]
) }}


-- depends_on: {{ source('fivetran_salesforce_quickstart', 'account') }} 
-- depends_on: {{ source('dbo', 'organization') }}
-- depends_on: {{ source('fivetran_salesforce_quickstart', 'lcom_organization_c') }}

call {{ target.database }}.{{ schema }}.lc_load_conformed_account_hierarchy(cast('{{ var("loaddate") }}' as timestamp));