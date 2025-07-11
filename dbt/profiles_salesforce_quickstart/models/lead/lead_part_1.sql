-- depends_on: {{ source("fivetran_salesforce_quickstart","lead") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lead"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["synced_to_org_c", "codesters_lti_c", "_fivetran_deleted", "agileed_connect_link_do_not_update_hierarchy_c", "agileed_agile_ed_up_to_date_c", "agileed_agile_ed_insert_c", "do_not_call", "agileed_agile_ed_do_not_update_c", "is_priority_record", "is_deleted", "is_converted", "migrated_c", "agileed_connect_link_email_hard_bounce_c", "has_opted_out_of_fax", "is_unread_by_owner", "gong_actively_being_in_a_flow_c", "has_opted_out_of_email"] ) }}

{% endif %}
