-- depends_on: {{ source("fivetran_salesforce_quickstart","campaign") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","campaign"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["pipe_bucket_c", "codesters_pd_class_key_c", "codesters_license_classroom_name_c", "type", "created_by_id", "campaign_member_record_type_id", "status", "name", "codesters_license_suite_c", "codesters_utm_medium_c", "webinar_id_c", "codesters_codesters_token_c", "parent_id", "codesters_codesters_page_title_c", "account_executive_c", "last_modified_by_id", "owner_id", "description", "codesters_utm_campaign_c", "learning_sbxid_c", "vidcode_org_id_c", "id", "codesters_codesters_campaign_c", "codesters_utm_source_c", "codesters_id_c", "db_campaign_tactic_c", "codesters_opportunity_name_extension_c"] ) }}

{% endif %}
