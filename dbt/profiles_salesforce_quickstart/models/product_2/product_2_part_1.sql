-- depends_on: {{ source("fivetran_salesforce_quickstart","product_2") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","product_2"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "sbqq_has_consumption_schedule_c", "sbqq_hidden_c", "sbqq_allocate_pot_on_orders_c", "is_active", "sbqq_has_configuration_attributes_c", "is_not_provisioned_c", "sbqq_description_locked_c", "sbqq_enable_large_configuration_c", "sbqq_price_editable_c", "sbqq_non_discountable_c", "active_in_platform_c", "sbqq_quantity_editable_c", "is_deleted", "sbqq_include_in_maintenance_c", "sbqq_pricing_method_editable_c", "sbqq_optional_c", "sbqq_exclude_from_maintenance_c", "sbqq_component_c", "sbqq_custom_configuration_required_c", "sbqq_exclude_from_opportunity_c", "sbqq_non_partner_discountable_c", "sbqq_hide_price_in_search_results_c", "does_not_prorate_c", "is_archived", "sbqq_reconfiguration_disabled_c", "sbqq_cost_editable_c", "sbqq_new_quote_group_c", "sbqq_taxable_c", "sbqq_externally_configurable_c"] ) }}

{% endif %}
