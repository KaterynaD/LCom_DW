-- depends_on: {{ source("fivetran_salesforce_quickstart","contact") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","contact"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["net_suite_link_c", "district_enrollment_level_c", "contact_time_zone_c", "is_contact_a_dr_c", "data_quality_description_c", "rcsfl_send_sms_c", "full_name_c", "codesters_url_c", "bad_contact_c", "name_c", "account_owner_c"] ) }}

{% endif %}
