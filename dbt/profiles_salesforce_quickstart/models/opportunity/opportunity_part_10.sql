-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["nrr_renewal_c", "source_opp_arr_c", "progressive_term_length_c", "arr_won_c", "renewal_biz_trigger_c", "days_open_c", "days_past_due_c", "amount_won_c", "multi_year_arr_c", "renewable_revenue_c", "renewal_at_79_c", "arr_upsell_c", "days_since_last_activity_c", "close_date_minus_last_activity_date_c", "owner_sales_quota_c", "new_biz_arr_trigger_c", "order_processing_time_c", "arr_new_business_c", "combined_arr_c", "variance_c", "total_arr_bookings_c", "arr_renewal_c", "new_nrr_c", "expected_revenue", "original_new_business_arr_c", "true_arr_c", "amount", "initial_renewal_arr_c", "potential_amount_c", "original_upsell_arr_c", "initial_new_business_arr_c", "po_amount_c"] ) }}

{% endif %}
