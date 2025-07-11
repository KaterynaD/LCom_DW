-- depends_on: {{ source("fivetran_salesforce_quickstart","user") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","user"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["user_role_id", "city", "division", "digest_frequency", "stay_in_touch_subject", "manager_id", "primary_demo_district_c", "user_calendly_link_c", "contact_id", "name", "company_name", "alias", "suffix", "federation_identifier", "banner_photo_url", "full_photo_url", "last_modified_by_id", "sbqq_theme_c", "geocode_accuracy", "small_banner_photo_url", "out_of_office_message", "about_me", "signature"] ) }}

{% endif %}
