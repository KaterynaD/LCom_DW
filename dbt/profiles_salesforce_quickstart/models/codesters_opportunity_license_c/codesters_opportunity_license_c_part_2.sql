-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_opportunity_license_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_opportunity_license_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_codesters_license_c", "codesters_id_c", "codesters_opportunity_c", "created_by_id", "name", "id", "last_modified_by_id"] ) }}

{% endif %}
