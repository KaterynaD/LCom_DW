-- depends_on: {{ source("fivetran_salesforce_quickstart","lead") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lead"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["codesters_i_2_c_student_completion_c", "codesters_classes_c", "codesters_students_c", "codesters_i_2_c_18_student_avg_c", "codesters_i_2_c_18_student_completion_c", "codesters_i_2_c_student_avg_c", "codesters_highest_module_completion_c", "longitude", "district_enrollment_c", "latitude"] ) }}

{% endif %}
