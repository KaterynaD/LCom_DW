-- depends_on: {{ source("fivetran_salesforce_quickstart","pricebook_2") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","pricebook_2"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["learning_sbxid_c", "name", "vidcode_org_id_c", "id", "last_modified_by_id", "codesters_id_c", "description", "created_by_id"] ) }}

{% endif %}
