-- depends_on: {{ source("fivetran_salesforce_quickstart","codesters_codesters_member_c") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","codesters_codesters_member_c"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_codesters_profile_i_2_c_18_avg_c", "codesters_codesters_profile_classes_c", "codesters_codesters_profile_pd_0_points_c", "codesters_codesters_profile_i_2_c_avg_c", "codesters_codesters_profile_students_c"] ) }}

{% endif %}
