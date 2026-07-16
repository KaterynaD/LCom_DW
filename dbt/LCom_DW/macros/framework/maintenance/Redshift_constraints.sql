{% macro generate_not_null_rebuild_sql(model_name) %}

    {%do log('Applying model contract Not Null constraint for model: ' ~ model_name, info=true) %}

    {% set ns = namespace(model_node=none) %}

    {% for node in graph.nodes.values() %}a
        {% if node.resource_type == 'model' and node.name == model_name %}
            {% set ns.model_node = node %}
        {% endif %}
    {% endfor %}

    {% if ns.model_node is none %}
        {{ exceptions.raise_compiler_error(
            "Model '" ~ model_name ~ "' was not found."
        ) }}
    {% endif %}

    {% set model_node = ns.model_node %}

    {% set schema_name = model_node.schema %}
    {% set table_name = model_node.alias %}
    {% set new_table_name = table_name ~ '__new' %}
    {% set backup_table_name = table_name ~ '__old' %}

    {% set dist = model_node.config.get('dist') %}
    {% set sort = model_node.config.get('sort') %}
    {% set sort_type = model_node.config.get('sort_type', 'compound') %}

    {% set physical_design_sql %}

{% if dist %}
    {% if dist | lower in ['all', 'even', 'auto'] %}
diststyle {{ dist | lower }}
    {% else %}
distkey({{ dist }})
    {% endif %}
{% endif %}

{% if sort %}
    {% if sort is string %}
{{ sort_type | lower }} sortkey({{ sort }})
    {% else %}
{{ sort_type | lower }} sortkey(
        {{ sort | join(', ') }}
)
    {% endif %}
{% endif %}

    {% endset %}

    {% set sql %}

create table {{ schema_name }}.{{ new_table_name }}
(
{% for column_name, column in model_node.columns.items() %}
    {{ column.name | default(column_name, true) }} {{ column.data_type }}{% if column.constraints is defined %}{% for constraint in column.constraints %}{% if constraint.type == 'not_null' %} not null{% endif %}{% endfor %}{% endif %}{% if not loop.last %},{% endif %}
{% endfor %}
)
{{ physical_design_sql | trim }}
;

insert into {{ schema_name }}.{{ new_table_name }}
(
{% for column_name, column in model_node.columns.items() %}
    {{ column.name | default(column_name, true) }}{% if not loop.last %},{% endif %}
{% endfor %}
)
select
{% for column_name, column in model_node.columns.items() %}
    {{ column.name | default(column_name, true) }}{% if not loop.last %},{% endif %}
{% endfor %}
from {{ schema_name }}.{{ table_name }};

alter table {{ schema_name }}.{{ table_name }}
rename to {{ backup_table_name }};

alter table {{ schema_name }}.{{ new_table_name }}
rename to {{ table_name }};

drop table {{ schema_name }}.{{ backup_table_name }};

    {% endset %}


    {% set dry_run = var('dry_run', true) %}

    {% if dry_run %}
     {% do log(sql, info=true) %}
    {% else %}
         {% if execute %}  
          {% do run_query(sql) %}
         {% endif %}
    {% endif %}

    
    

   
    {%do log('Done: ' ~ model_name, info=true) %}




{% endmacro %}

{-- ======================================================================================================================== --}

{% macro generate_primary_key_sql(model_name) %}

    {%do log('Creating model contract Primary Key constraint for model: ' ~ model_name, info=true) %}

    {% set model_node = graph.nodes.values()
        | selectattr('resource_type', 'equalto', 'model')
        | selectattr('name', 'equalto', model_name)
        | first %}

    {% if not model_node %}
        {{ exceptions.raise_compiler_error("Model '" ~ model_name ~ "' not found.") }}
    {% endif %}

    {% set ns = namespace(pk_column=None) %}

    {% for column_name, column in model_node.columns.items() %}
        {% for constraint in column.get('constraints', []) %}
            {% if constraint.get('type') == 'primary_key' %}
                {% set ns.pk_column = column_name %}
            {% endif %}
        {% endfor %}
    {% endfor %}

    {% if ns.pk_column is none %}
        {{ exceptions.raise_compiler_error("No primary_key constraint found for model '" ~ model_name ~ "'.") }}
    {% endif %}

    {% set sql %}
alter table {{ ref(model_name) }} add primary key ({{ ns.pk_column }});
    {% endset %}

    {% set dry_run = var('dry_run', true) %}

    {% if dry_run %}
     {% do log(sql, info=true) %}
    {% else %}
         {% if execute %}  
          {% do run_query(sql) %}
         {% endif %}
    {% endif %}

 {%do log('Done: ' ~ model_name, info=true) %}

{% endmacro %}