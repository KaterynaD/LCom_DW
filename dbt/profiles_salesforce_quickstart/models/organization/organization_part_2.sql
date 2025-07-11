-- depends_on: {{ source("fivetran_salesforce_quickstart","organization") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","organization"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["postal_code", "language_locale_key", "time_zone_sid_key", "state_code", "ui_skin", "organization_type", "default_calendar_access", "created_by_id", "default_account_access", "default_campaign_access", "default_contact_access", "default_pricebook_access", "name", "namespace_prefix", "fax", "web_to_case_default_origin", "compliance_bcc_email", "default_case_access", "instance_name", "phone", "state", "last_modified_by_id", "geocode_accuracy", "signup_country_iso_code", "street", "default_opportunity_access", "city", "division", "id", "country_code", "default_locale_sid_key", "default_lead_access", "primary_contact", "country"] ) }}

{% endif %}
