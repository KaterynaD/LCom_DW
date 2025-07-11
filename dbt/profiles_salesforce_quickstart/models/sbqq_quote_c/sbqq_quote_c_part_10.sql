-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["progressive_payment_date_3_c", "progressive_payment_date_2_c", "quote_expiration_ram_renewals_c", "progressive_payment_date_5_c", "progressive_payment_date_4_c", "_fivetran_synced", "created_date", "sbqq_last_saved_on_c", "last_modified_date", "last_viewed_date", "last_referenced_date", "system_modstamp", "sbqq_last_calculated_on_c"] ) }}

{% endif %}
