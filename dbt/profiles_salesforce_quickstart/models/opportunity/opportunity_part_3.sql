-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["paid_month_c", "close_month_c", "po_1_c", "data_quality_score_c", "created_month_1_c", "created_year_c", "close_year_c", "invoice_month_c", "po_received_counter_c", "paid_year_c", "running_user_for_reporting_c", "invoice_year_c", "gong_gong_count_c"] ) }}

{% endif %}
