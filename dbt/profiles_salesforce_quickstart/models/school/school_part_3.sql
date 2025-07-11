-- depends_on: {{ source("fivetran_salesforce_quickstart","account") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","account"), where_clause="org_type_c='School'", exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["po_1_c", "data_quality_score_c", "rpm_user_id_c", "parent_and_child_match_c", "userid_c", "gong_gong_count_c"] ) }}

{% endif %}
