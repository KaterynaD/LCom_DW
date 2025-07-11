-- depends_on: {{ source("fivetran_salesforce_quickstart","account") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","account"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["net_suite_link_c", "owner_c", "zendesk_domain_c", "data_quality_description_c", "ultimate_account_owner_c", "account_management_type_c", "parent_account_owner_c", "last_name_c", "first_name_c", "name_with_lcom_organization_info_c", "enrollment_band_c", "enrollment_tier_c", "customer_type_c", "ae_or_isr_c", "renewal_forecast_segment_c", "national_school_id_c", "owner_name_text_c", "csm_name_c", "grade_level_detail_c", "national_district_id_c", "current_total_ultimate_parent_c", "related_activity_c", "time_zone_transformed_c"] ) }}

{% endif %}
