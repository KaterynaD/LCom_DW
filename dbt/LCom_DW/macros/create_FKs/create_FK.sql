{% macro create_FK(database, schema, table, column, refschema,reftable, refcolumn) %}

{%- set relation = adapter.get_relation(
      database=database,
      schema=schema,
      identifier=table) -%}

{%- set refrelation = adapter.get_relation(
      database=database,
      schema=refschema,
      identifier=reftable) -%}      

{% if relation and refrelation %}

 {% set create_FKs_operation %}

ALTER TABLE {{ relation }} ADD FOREIGN KEY ({{ column }}) REFERENCES {{ refrelation }}({{ refcolumn }});


{% endset %}

{% do run_query(create_FKs_operation) %}

 {% endif %}

{% endmacro %} 