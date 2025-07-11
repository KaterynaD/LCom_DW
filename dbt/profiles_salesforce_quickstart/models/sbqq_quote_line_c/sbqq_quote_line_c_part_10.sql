-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_partner_discount_c", "sbqq_prorate_multiplier_c", "sbqq_guidance_c", "sbqq_batch_quantity_c", "sbqq_segment_index_c", "sbqq_number_c"] ) }}

{% endif %}
