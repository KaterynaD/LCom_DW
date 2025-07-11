-- depends_on: {{ source("fivetran_salesforce_quickstart","campaign") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","campaign"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "available_for_sales_selection_c", "is_active", "codesters_linked_c", "codesters_use_license_flow_c", "codesters_codesters_is_active_c", "is_deleted", "codesters_synced_c", "codesters_limited_access_c"] ) }}

{% endif %}
