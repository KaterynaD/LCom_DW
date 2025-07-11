-- depends_on: {{ source("fivetran_salesforce_quickstart","order") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","order"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["order_billed_date_c", "effective_date", "company_authorized_date", "customer_authorized_date", "end_date", "po_date"] ) }}

{% endif %}
