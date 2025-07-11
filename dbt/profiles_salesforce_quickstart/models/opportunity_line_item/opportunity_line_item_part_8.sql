-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity_line_item") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity_line_item"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["weighted_total_price_c", "weighted_opp_product_arr_c", "opportunity_product_arr_c", "opp_probability_c", "pro_rate_adj_term_c", "net_price_display_c", "quantity_for_services_c", "subscription_term_c", "easy_tech_arr_c", "quantity_for_service_only_c", "quantity", "license_durations_c", "number_of_learning_com_orders_created_c", "discount", "no_of_buildings_c", "no_of_licenses_c"] ) }}

{% endif %}
