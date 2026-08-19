{% macro pre_deployment_tasks() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Starting pre deployment tasks', info=True) }}

 {% set pre_deployment_sql %}

 {% set target_db = (target.database | string) %}

 {% if target_db | upper == 'QA' %}

--deploying stored procedure based model even with deps did not create needed models in QA automatically
create or replace view qa.common.dim_month as select * from dw.common.dim_month  limit 10 with no schema binding;
create or replace view qa.common.dim_district as select * from dw.common.dim_month  limit 10 with no schema binding;
create or replace view qa.content_delivery_usage.dim_learning_object as select * from dw.content_delivery_usage.dim_learning_object  limit 10 with no schema binding;
create or replace view qa.content_delivery_usage.dim_product_category as select * from dw.content_delivery_usage.dim_product_category limit 10   with no schema binding;
create or replace view qa.content_delivery_usage.dim_product_category_learning_object_monthly as select * from dw.content_delivery_usage.dim_product_category_learning_object_monthly limit 10 with no schema binding;

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