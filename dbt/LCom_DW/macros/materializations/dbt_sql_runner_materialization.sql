{% materialization sql_runner, default %}

{% set target_table = model.get('alias', model.get('name')) %}

{% set target_relation_exists, target_relation = get_or_create_relation(
          database=model.database,
          schema=model.schema,
          identifier=target_table,
          type='table') %}
  
{{ run_hooks(pre_hooks, inside_transaction=False) }}

-- `BEGIN` happens here:
{{ run_hooks(pre_hooks, inside_transaction=True) }}

{# Run model SQL (as a stored procedure call)#}
{% if not flags.EMPTY %}
{% set run_sp_operation %}

 
 {{ model['compiled_code'] }}
 


 {% endset %}

{% do run_query(run_sp_operation) %}
{% endif %}

{# Placeholder for dbt materialization requirement (a SP can be called from here but does not run) #}

{% call statement('main') %}

select 1

 {% endcall %}


{{ run_hooks(post_hooks, inside_transaction=True) }}

  {% set should_revoke = should_revoke(target_relation_exists, full_refresh_mode=False) %}
  {% do apply_grants(target_relation, grant_config, should_revoke=should_revoke) %}

  {% do persist_docs(target_relation, model) %}

  -- `COMMIT` happens here

  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}


 {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}