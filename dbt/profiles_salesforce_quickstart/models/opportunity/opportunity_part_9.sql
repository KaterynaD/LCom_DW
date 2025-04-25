-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["quote_created_date_c", "quote_expiry_date_c", "created_month_c", "quote_start_date_c", "license_expiration_notice_date_c", "date_assigned_c", "close_date_new_c", "paid_date_c", "date_of_reminder_c", "commit_date_c", "expected_start_date_c", "qualified_date_c", "subscription_start_date_c", "start_date_c", "last_activity_changed_date_c", "expected_po_date_c", "end_date_c", "customer_churned_c", "second_call_date_c", "subscription_end_date_c", "propose_date_c", "validated_date_c", "close_date", "churn_date_c", "present_date_c", "last_activity_date", "original_close_date_c", "stakeholder_demo_date_c", "invoiced_date_c", "po_received_date_c", "license_expiration_notice_stop_date_c", "initial_call_date_c"] ) }}

{% endif %}
