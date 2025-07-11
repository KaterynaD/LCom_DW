-- depends_on: {{ source("fivetran_salesforce_quickstart","order_item") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","order_item"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_order_product_bookings_c", "quantity", "sbqq_subscription_term_c", "sbqq_quoted_quantity_c", "available_quantity", "sbqq_default_subscription_term_c", "sbqq_prorate_multiplier_c", "sbqq_segment_index_c", "sbqq_ordered_quantity_c"] ) }}

{% endif %}
