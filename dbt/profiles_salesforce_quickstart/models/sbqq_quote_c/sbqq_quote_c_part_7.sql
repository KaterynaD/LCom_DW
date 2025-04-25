-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["standard_discount_c", "prorated_list_price_c", "sbqq_days_quote_open_c", "account_current_arr_c", "progressive_payment_amount_3_c", "progressive_payment_amount_5_c", "texas_savings_v_2_c", "progressive_payment_amount_2_c", "sbqq_target_customer_amount_c", "net_amount_without_services_c", "progressive_payment_amount_4_c", "premium_service_amount_c"] ) }}

{% endif %}
