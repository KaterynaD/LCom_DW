-- depends_on: {{ source("fivetran_salesforce_quickstart","lcom_order_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lcom_order_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["po_number_c", "opportunity_number_c", "lcom_term_django_id_c", "lcom_account_c", "opportunity_c", "name", "quote_c", "id", "lcom_django_id_c", "last_modified_by_id", "lcom_term_c", "lcom_order_cancellation_reason_c", "lcom_order_type_c", "created_by_id", "salesforce_account_c", "lcom_order_status_c"] ) }}

{% endif %}
