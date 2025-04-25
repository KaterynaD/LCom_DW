-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_product_option_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_product_option_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_discount_amount_c", "sbqq_unit_price_c"] ) }}

{% endif %}
