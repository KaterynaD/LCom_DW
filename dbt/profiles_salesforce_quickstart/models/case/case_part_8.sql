-- depends_on: {{ source("fivetran_salesforce_quickstart","case") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","case"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_i_2_c_student_completion_c", "codesters_classes_c", "codesters_students_c", "case_created_hour_c", "codesters_i_2_c_student_avg_c"] ) }}

{% endif %}
