-- depends_on: {{ source("fivetran_salesforce_quickstart","product_2") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","product_2"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["description", "sbqq_product_picture_id_c", "vidcode_org_id_c", "id", "sbqq_custom_configuration_page_c", "sbqq_billing_frequency_c", "sbqq_block_pricing_field_c", "sbqq_asset_conversion_c", "external_data_source_id", "sbqq_cost_schedule_c", "sbqq_subscription_pricing_c", "sbqq_configuration_type_c", "sbqq_dynamic_pricing_constraint_c"] ) }}

{% endif %}
