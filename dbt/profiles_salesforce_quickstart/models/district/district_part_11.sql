-- depends_on: {{ source("fivetran_salesforce_quickstart","account") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","account"), where_clause="org_type_c='District'" , exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["next_renewal_date_c", "account_last_activity_date_c", "start_date_c", "onboarding_date_c", "churn_date_c", "otc_provisioned_date_c", "prospecting_ended_c", "prospecting_started_c", "last_activity_logged_on_c", "sbqq_price_hold_end_c", "first_contact_c", "end_date_c", "agileed_agile_ed_latest_update_date_c", "customer_since_c", "school_year_end_c", "last_activity_date", "school_year_start_c"] ) }}

{% endif %}
