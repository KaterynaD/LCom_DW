-- depends_on: {{ source("fivetran_salesforce_quickstart","account") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","account"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["nps_sum_c", "ultimate_parent_total_renewal_arr_2_c", "parent_et_tam_c", "district_total_tam_c", "current_renewal_arr_c", "open_opportunity_amount_c", "district_expansion_potential_c", "easy_code_tam_6_8_c", "district_easy_code_tam_c", "annual_revenue", "district_easy_tech_tam_c", "competitor_spend_since_2018_c", "contracted_roll_up_c", "beginning_arr_c", "vidcode_arr_c", "easy_code_tam_k_5_c", "fiscal_title_i_funding_c", "total_renewal_arr_c", "codesters_arr_c", "easy_tech_tam_c", "codesters_expansion_tam_c"] ) }}

{% endif %}
