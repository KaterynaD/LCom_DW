-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_line_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_line_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_special_price_type_c", "sbqq_block_price_c", "sbqq_term_discount_schedule_c", "last_modified_by_id", "sbqq_description_c", "sbqq_special_price_description_c", "sbqq_favorite_c", "sbqq_dynamic_option_id_c", "id", "sbqq_billing_frequency_c", "sbqq_subscribed_asset_ids_c", "sbqq_discount_tier_c", "sbqq_subscription_pricing_c"] ) }}

{% endif %}
