-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["multi_year_disc_c", "list_price_c", "sbqq_component_total_c", "sbqq_unit_cost_c", "sbqq_special_price_c", "sbqq_partner_price_c", "sbqq_unprorated_net_price_c", "sbqq_option_discount_amount_c", "sbqq_previous_segment_price_c", "sbqq_prorated_list_price_c", "sbqq_regular_price_c", "sbqq_minimum_price_c", "sbqq_maximum_price_c", "sbqq_subscription_target_price_c", "sbqq_original_price_c", "sbqq_markup_amount_c", "sbqq_additional_discount_amount_c", "sbqq_prorated_price_c", "sbqq_previous_segment_uplift_c", "sbqq_list_price_c", "sbqq_component_cost_c", "sbqq_original_unit_cost_c", "sbqq_gross_profit_c", "sbqq_customer_price_c", "sbqq_net_price_c", "sbqq_component_list_total_c", "sbqq_uplift_amount_c", "sbqq_term_discount_c"] ) }}

{% endif %}
