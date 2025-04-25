-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_organization_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_organization_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["has_parent_organization_c", "account_missing_platform_id_c", "_fivetran_deleted", "free_trial_c", "is_synced_c", "is_deleted", "is_linked_c", "demo_district_c"] ) }}

{% endif %}
