-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_product_option_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_product_option_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_price_editable_c", "product_family_filter_c"] ) }}

{% endif %}
