-- depends_on: {{ source("fivetran_salesforce_quickstart","sbqq_quote_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","sbqq_quote_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["opp_start_date_c", "opportunity_invoiced_date_c", "opp_end_date_c", "progressive_payment_date_1_c", "sbqq_first_segment_term_end_date_c", "sbqq_end_date_c", "sbqq_start_date_c", "sbqq_expiration_date_c", "last_activity_date", "quote_date_c"] ) }}

{% endif %}
