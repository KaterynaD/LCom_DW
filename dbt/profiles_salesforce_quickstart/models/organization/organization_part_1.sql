-- depends_on: {{ source("fivetran_salesforce_quickstart","organization") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","organization"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["_fivetran_deleted", "is_read_only", "is_sandbox", "uses_start_date_as_fiscal_year_name", "preferences_require_opportunity_products", "receives_info_emails", "preferences_email_sender_id_compliance", "receives_admin_info_emails"] ) }}

{% endif %}
