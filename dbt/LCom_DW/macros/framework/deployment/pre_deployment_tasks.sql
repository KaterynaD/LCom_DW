{% macro pre_deployment_tasks() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Starting pre deployment tasks', info=True) }}

 {% set pre_deployment_sql %}

 {% set target_db = (target.database | string) %}

 {% if target_db | upper == 'QA' %}

--deploying stored procedure based model even with deps did not create needed models in QA automatically

create or replace view qa.common.dim_account as select * from dw.common.dim_account  limit 10 with no schema binding;
create or replace view qa.revenue.fact_opportunity as select * from dw.revenue.fact_opportunity  limit 10 with no schema binding;
create or replace view qa.support.fact_case as select * from dw.support.fact_case  limit 10 with no schema binding;
create or replace view qa.content_delivery_usage.fact_training_session as select * from dw.content_delivery_usage.fact_training_session  limit 10 with no schema binding;
create or replace view qa.licensing.fact_license_order as select * from dw.licensing.fact_license_order  limit 10 with no schema binding;
create or replace view qa.licensing.dim_license_order_school as select * from dw.licensing.dim_license_order_school  limit 10 with no schema binding;


 {% endif %} 
					


 {% endset %}

    {% if pre_deployment_sql | trim %}
        {% do run_query(pre_deployment_sql) %}
        {{ log('Finished pre deployment tasks', info=True) }}
    {% else %}
        {{ log('No pre deployment tasks to execute', info=True) }}
    {% endif %}


{% endif %}
 
 {% endmacro %}