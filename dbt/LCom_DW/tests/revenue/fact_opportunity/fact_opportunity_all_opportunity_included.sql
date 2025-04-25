select id from {{ source('fivetran_salesforce_quickstart', 'opportunity') }}
except
select opportunity_id from {{ ref("fact_opportunity") }}