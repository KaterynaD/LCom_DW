-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_license_site_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_license_site_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["lcom_organization_parent_c", "lcom_organization_name_c", "lcom_organization_django_id_c", "lcom_platform_license_site_id_c", "name", "id", "lcom_license_c", "lcom_django_id_c", "last_modified_by_id", "lcom_suite_c", "account_c", "lcom_order_c", "created_by_id", "quote_line_c", "lcom_organization_c"] ) }}

{% endif %}
