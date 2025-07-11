-- depends_on: {{ source("fivetran_salesforce_quickstart","order") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","order"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["sbqq_order_bookings_c", "billing_latitude", "sbqq_renewal_uplift_rate_c", "shipping_latitude", "shipping_longitude", "billing_longitude", "sbqq_renewal_term_c"] ) }}

{% endif %}
