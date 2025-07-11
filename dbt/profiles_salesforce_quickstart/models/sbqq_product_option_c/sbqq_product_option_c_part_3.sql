-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_product_option_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_product_option_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_product_code_c", "sbqq_product_family_c", "sbqq_product_configuration_type_c", "sbqq_product_description_c", "sbqq_product_name_c", "sbqq_product_subscription_pricing_c", "sbqq_component_description_c", "sbqq_quote_line_visibility_c", "sbqq_configured_sku_c", "sbqq_applied_immediately_context_c", "last_modified_by_id", "sbqq_discount_schedule_c", "owner_id", "created_by_id", "sbqq_subscription_scope_c", "name", "id", "sbqq_renewal_product_option_c", "sbqq_feature_c", "sbqq_default_pricing_table_c", "sbqq_component_code_c", "sbqq_type_c", "sbqq_optional_sku_c"] ) }}

{% endif %}
