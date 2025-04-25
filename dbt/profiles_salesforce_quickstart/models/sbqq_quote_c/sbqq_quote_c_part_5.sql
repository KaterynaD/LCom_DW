-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_master_contract_c", "quote_type_c", "sales_rep_quote_notes_c", "sbqq_delivery_method_c", "sbqq_partner_c", "last_modified_by_id", "sbqq_shipping_postal_code_c", "owner_id", "sbqq_billing_name_c", "sbqq_billing_state_c", "quote_types_c", "payment_details_c", "id", "sbqq_billing_frequency_c", "sbqq_primary_contact_c", "sbqq_original_quote_c", "sbqq_order_by_c", "sbqq_contracting_method_c"] ) }}

{% endif %}
