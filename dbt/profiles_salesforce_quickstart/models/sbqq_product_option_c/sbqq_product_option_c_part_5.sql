-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_product_option_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_product_option_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_product_quantity_scale_c", "sbqq_quantity_c", "sbqq_discount_c", "sbqq_component_description_position_c", "sbqq_component_code_position_c", "sbqq_max_quantity_c", "sbqq_min_quantity_c", "sbqq_existing_quantity_c", "sbqq_number_c"] ) }}

{% endif %}
