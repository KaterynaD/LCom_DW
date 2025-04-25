-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_organization_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_organization_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["learning_sbxid_c", "name", "id", "last_modified_by_id", "owner_id", "codester_sid_c", "created_by_id", "codesters_codesters_id_c", "codesters_codesters_slug_c"] ) }}

{% endif %}
