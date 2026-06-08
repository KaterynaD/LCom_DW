{% macro post_deployment_tasks() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Starting post deployment tasks', info=True) }}

 {% set post_deployment_sql %}

 update staging.d_product
 set created_date = data.created_date
 from (
    select id, created_date
    from {{ source('fivetran_salesforce_quickstart', 'product_2') }}
 ) data
 where staging.d_product.id = data.id and
    staging.d_product.created_date is null;

 {% endset %}


    {% if post_deployment_sql | trim %}
        {% do run_query(post_deployment_sql) %}
        {{ log('Finished post deployment tasks', info=True) }}
    {% else %}
        {{ log('No post deployment tasks to execute', info=True) }}
    {% endif %}


{% endif %}
 
 {% endmacro %}