-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["gold_service_c", "no_proration_c", "pyproration_c", "_fivetran_deleted", "sbqq_completely_contracted_c", "sbqq_has_consumption_schedule_c", "default_proration_c", "sbqq_hidden_c", "sbqq_configuration_required_c", "update_c", "sbqq_carryover_line_c", "is_not_provisioned_c", "sbqq_component_discounted_by_package_c", "sbqq_allow_asset_refund_c", "sbqq_existing_c", "sbqq_price_editable_c", "sbqq_renewal_c", "sbqq_non_discountable_c", "sbqq_bundled_c", "is_deleted", "sbqq_pricing_method_editable_c", "sbqq_optional_c", "sbqq_incomplete_c", "sbqq_component_uplifted_by_package_c", "sbqq_bundle_c", "sbqq_non_partner_discountable_c", "sbqq_has_split_orders_c", "sbqq_cost_editable_c", "sbqq_taxable_c", "updated_c"] ) }}

{% endif %}
