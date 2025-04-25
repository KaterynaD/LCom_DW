-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["discount_c", "regular_discount_amounttbd_c", "mr_discount_c", "sbqq_list_amount_c", "sbqq_average_customer_discount_c", "multiyear_discount_amount_c", "rep_total_dis_amount_c", "sbqq_average_partner_discount_c", "sbqq_customer_amount_c", "sbqq_additional_discount_amount_c", "sbqq_net_amount_c", "discountable_list_price_c", "avg_rep_discount_c", "sbqq_total_customer_discount_amount_c", "sbqq_regular_amount_c", "progressive_payment_amount_1_a_c", "sbqq_distributor_discount_c", "sbqq_customer_discount_c", "sbqq_renewal_uplift_rate_c", "sbqq_markup_rate_c", "count_of_gold_services_c", "quote_has_premium_service_c", "nyc_license_quantity_c", "sbqq_renewal_term_c", "sbqq_subscription_term_c", "reps_discount_c", "sbqq_partner_discount_c", "total_credit_c"] ) }}

{% endif %}
