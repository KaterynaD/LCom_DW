{% macro pre_deployment_tasks() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Starting pre deployment tasks', info=True) }}

 {% set pre_deployment_sql %}

 {% set target_db = (target.database | string) %}

 {% if target_db | upper == 'QA' %}

   create table qa.revenue.fact_opportunity_history as select * from dw.revenue.fact_opportunity_history;

 {% endif %} 
					
alter table revenue.fact_opportunity_history add column multi_year_discount_rate numeric(7,2) NOT NULL default 0;


update revenue.fact_opportunity_history
set
multi_year_discount_rate = fo.multi_year_discount_rate
from revenue.fact_opportunity fo
where fo.opportunity_id=revenue.fact_opportunity_history.opportunity_id;


update revenue.fact_opportunity_history
set scd_hash = md5(coalesce(cast(stage_name as varchar ), '')
         || '|' || coalesce(cast(name as varchar ), '')
         || '|' || coalesce(cast(amount as varchar ), '')
         || '|' || coalesce(cast(amount_won as varchar ), '')
         || '|' || coalesce(cast(arr as varchar ), '')
         || '|' || coalesce(cast(arr_new_business as varchar ), '')
         || '|' || coalesce(cast(arr_renewal as varchar ), '')
         || '|' || coalesce(cast(arr_upsell as varchar ), '')
         || '|' || coalesce(cast(arr_won as varchar ), '')
         || '|' || coalesce(cast(combined_arr as varchar ), '')
         || '|' || coalesce(cast(downsell as varchar ), '')
         || '|' || coalesce(cast(multi_year_arr as varchar ), '')
         || '|' || coalesce(cast(new_biz_arr_trigger as varchar ), '')
         || '|' || coalesce(cast(nnarr as varchar ), '')
         || '|' || coalesce(cast(nrr_renewal as varchar ), '')
         || '|' || coalesce(cast(po_amount as varchar ), '')
         || '|' || coalesce(cast(price_increase_arr as varchar ), '')
         || '|' || coalesce(cast(probability as varchar ), '')
         || '|' || coalesce(cast(quote_list_amount as varchar ), '')
         || '|' || coalesce(cast(quote_total_discount as varchar ), '')
         || '|' || coalesce(cast(remaining_quota as varchar ), '')
         || '|' || coalesce(cast(renewable_revenue as varchar ), '')
         || '|' || coalesce(cast(total_arr_bookings as varchar ), '')
         || '|' || coalesce(cast(true_arr as varchar ), '')
         || '|' || coalesce(cast(true_arr_formula as varchar ), '')
         || '|' || coalesce(cast(true_renewal_arr as varchar ), '')
         || '|' || coalesce(cast(last_modified_date as varchar ), '')
         || '|' || coalesce(cast(invoiced_date as varchar ), '')
         || '|' || coalesce(cast(close_date as varchar ), '')
         || '|' || coalesce(cast(start_date as varchar ), '')
         || '|' || coalesce(cast(end_date as varchar ), '')
         || '|' || coalesce(cast(opp_record_type as varchar ), '')
         || '|' || coalesce(cast(license_unenforced as varchar ), '')
         || '|' || coalesce(cast(disable_auto_renewal_opp as varchar ), '')
         || '|' || coalesce(cast(number_of_schools as varchar ), '')
         || '|' || coalesce(cast(number_of_students as varchar ), '')
         || '|' || coalesce(cast(multi_year_discount_rate as varchar ), '')
        );

 {% endset %}

    {% if pre_deployment_sql | trim %}
        {% do run_query(pre_deployment_sql) %}
        {{ log('Finished pre deployment tasks', info=True) }}
    {% else %}
        {{ log('No pre deployment tasks to execute', info=True) }}
    {% endif %}


{% endif %}
 
 {% endmacro %}