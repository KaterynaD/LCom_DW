-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_license_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_license_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["lcom_suite_name_c", "last_modified_by_id", "lcom_suite_c", "lcom_order_c", "created_by_id", "lcom_organization_c", "name", "quote_c", "id", "lcom_django_id_c", "lcom_platform_license_id_c"] ) }}

{% endif %}
