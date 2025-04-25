-- depends_on: {{ source("fivetran_salesforce_quickstart","pricebook_entry") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","pricebook_entry"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["product_2_id", "learning_sbxid_c", "pricebook_2_id", "name", "vidcode_org_id_c", "id", "last_modified_by_id", "product_code", "codesters_id_c", "created_by_id"] ) }}

{% endif %}
