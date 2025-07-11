-- depends_on: {{ source("fivetran_salesforce_quickstart","order") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","order"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["shipping_state_code", "billing_geocode_accuracy", "migration_tool_c", "original_order_id", "contract_id", "pd_contact_c", "bill_to_contact_id", "sbqq_contracting_method_c", "billing_state"] ) }}

{% endif %}
