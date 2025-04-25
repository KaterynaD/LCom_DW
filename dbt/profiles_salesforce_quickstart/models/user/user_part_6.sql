-- depends_on: {{ source("fivetran_salesforce_quickstart","user") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","user"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["postal_code", "sender_email", "start_day", "db_region_c", "mobile_phone", "title", "created_by_id", "extension", "sbqq_default_product_lookup_tab_c", "fax", "medium_banner_photo_url", "locale_sid_key", "ns_id_c", "small_photo_url", "email", "last_name", "codester_id_c", "street", "user_type", "country", "default_group_notification_frequency", "middle_name", "department", "department_historical_c", "time_zone_sid_key", "dstore_store_c", "state_code", "first_name", "delegated_approver_id", "profile_id", "stay_in_touch_note", "badge_text", "call_center_id", "individual_id", "state", "email_encoding_key", "id", "country_code", "language_locale_key", "community_nickname", "end_day", "sender_name", "username", "learning_com_territory_c", "account_id", "employee_number", "sbqq_product_sort_preference_c", "stay_in_touch_signature", "medium_photo_url", "phone"] ) }}

{% endif %}
