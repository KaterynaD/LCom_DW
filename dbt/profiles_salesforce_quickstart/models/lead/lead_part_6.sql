-- depends_on: {{ source("fivetran_salesforce_quickstart","lead") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","lead"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["master_record_id", "acct_org_type_c", "gong_current_flow_id_c", "gong_current_flow_step_type_c"] ) }}

{% endif %}
