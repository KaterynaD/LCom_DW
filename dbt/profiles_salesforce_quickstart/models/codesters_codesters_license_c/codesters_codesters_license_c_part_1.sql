-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_license_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_license_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_is_over_c", "codesters_is_stale_c", "codesters_is_active_c", "codesters_is_valid_c", "codesters_is_synced_c", "_fivetran_deleted", "codesters_accept_changes_c", "codesters_codesters_is_disabled_c", "codesters_is_infinite_c", "codesters_codesters_is_active_c", "codesters_codesters_is_unlimited_c", "codesters_is_unlimited_c", "codesters_linked_c", "is_deleted", "codesters_synced_c", "codesters_codesters_is_infinite_c", "codesters_is_disabled_c", "codesters_codesters_is_stale_c"] ) }}

{% endif %}
