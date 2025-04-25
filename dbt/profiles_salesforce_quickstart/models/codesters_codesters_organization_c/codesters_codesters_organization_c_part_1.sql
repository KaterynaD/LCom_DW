-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_organization_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_organization_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_is_pending_c", "codesters_is_expired_c", "_fivetran_deleted", "codesters_linked_c", "is_deleted", "codesters_master_c", "codesters_admin_members_only_c"] ) }}

{% endif %}
