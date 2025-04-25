-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_license_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_license_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_show_record_type_id_c", "last_modified_by_id", "codesters_opportunity_c", "codesters_codesters_suite_c", "created_by_id", "learning_sbxid_c", "codesters_codesters_owner_id_c", "name", "id", "codesters_codesters_owner_c", "codesters_id_c", "record_type_id", "codesters_codesters_id_c", "codesters_codesters_organization_c", "codesters_suite_c"] ) }}

{% endif %}
