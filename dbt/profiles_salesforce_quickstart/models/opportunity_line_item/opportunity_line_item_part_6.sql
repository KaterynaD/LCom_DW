-- depends_on: {{ source("fivetran_salesforce_quickstart","opportunity_line_item") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("fivetran_salesforce_quickstart","opportunity_line_item"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=["net_unit_price_c", "combine_renewal_arrs_c", "combine_new_biz_arr_c", "combine_upsell_arrs_c", "unit_price", "total_price", "subtotal", "list_price"] ) }}

{% endif %}
