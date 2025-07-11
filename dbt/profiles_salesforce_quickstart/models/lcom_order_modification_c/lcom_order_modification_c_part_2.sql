-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_order_modification_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_order_modification_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["modified_by_c", "name", "id", "lcom_order_modified_c", "last_modified_by_id", "modification_type_c", "created_by_id", "modification_sub_type_c"] ) }}

{% endif %}
