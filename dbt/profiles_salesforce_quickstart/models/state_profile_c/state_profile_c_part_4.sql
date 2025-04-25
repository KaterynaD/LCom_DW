-- depends_on: {{ source("fivetran_salesforce_quickstart","state_profile_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","state_profile_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["last_audit_of_profile_of_a_grad_section_c", "last_audit_of_this_page_c", "state_standards_adoption_revision_c", "last_audit_of_bullying_c", "last_audit_of_online_assessments_section_c", "last_audit_of_computer_science_section_c", "do_r_renewal_date_c", "sos_renewal_date_c", "last_audit_of_media_literacy_section_c", "last_audit_of_c", "last_audit_of_digital_equity_section_c"] ) }}

{% endif %}
