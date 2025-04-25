-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_opportunity_license_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_opportunity_license_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_is_synced_match_c", "codesters_is_synced_c", "_fivetran_deleted", "codesters_is_synced_on_save_c", "is_deleted"] ) }}

{% endif %}
