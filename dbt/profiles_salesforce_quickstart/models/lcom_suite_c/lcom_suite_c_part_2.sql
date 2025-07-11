-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_suite_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_suite_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["name", "id", "lcom_license_c", "lcom_django_id_c", "last_modified_by_id", "product_c", "owner_id", "created_by_id"] ) }}

{% endif %}
