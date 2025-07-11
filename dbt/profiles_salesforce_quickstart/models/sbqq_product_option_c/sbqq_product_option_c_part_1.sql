-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_product_option_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_product_option_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "sbqq_uplifted_by_package_c", "sbqq_selected_c", "sbqq_required_c", "sbqq_applied_immediately_c", "sbqq_quantity_editable_c", "sbqq_bundled_c", "sbqq_system_c", "is_deleted", "sbqq_discounted_by_package_c"] ) }}

{% endif %}
