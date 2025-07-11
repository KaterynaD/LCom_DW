-- depends_on: {{ source("fivetran_salesforce_quickstart","user_role") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","user_role"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["forecast_user_id", "portal_type", "portal_account_owner_id", "portal_account_id", "parent_role_id", "rollup_description", "name", "id", "contact_access_for_account_owner", "last_modified_by_id", "opportunity_access_for_account_owner", "developer_name", "case_access_for_account_owner"] ) }}

{% endif %}
