-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_organization_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_organization_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_out_of_sync_licenses_c", "codesters_members_count_c", "codesters_licenses_count_c", "codesters_over_capacity_licenses_c", "codesters_valid_licenses_c"] ) }}

{% endif %}
