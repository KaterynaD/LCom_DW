-- depends_on: {{ source("fivetran_salesforce_quickstart","product_2") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","product_2"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_sort_order_c", "sbqq_compound_discount_rate_c", "sbqq_default_quantity_c", "multiplier_c", "sbqq_subscription_percent_c", "sbqq_quantity_scale_c", "nyc_license_quantity_c", "sbqq_upgrade_ratio_c", "sbqq_subscription_term_c", "students_with_licenses_c", "sbqq_batch_quantity_c"] ) }}

{% endif %}
