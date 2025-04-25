-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_order_line_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_order_line_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["product_name_c", "po_number_c", "opportunity_number_c", "opportunity_c", "name", "id", "lcom_license_c", "last_modified_by_id", "lcom_term_c", "lcom_suite_c", "product_c", "lcom_order_c", "created_by_id", "quote_line_c", "lcom_organization_c"] ) }}

{% endif %}
