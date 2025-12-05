{% macro Dropping_all_FK()  %}

{% set fks %}

SELECT  
'ALTER TABLE '+ constraint_schema + '.'+ table_name +' DROP CONSTRAINT '+constraint_name+';' drop_FK_SQL
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY'
and constraint_schema in ('licensing','revenue','content_delivery_usage','support','common')
ORDER BY constraint_schema, table_name;

{% endset %}

{% set fks_to_drop = run_query(fks) %}

{% if fks_to_drop | length == 0 %}
      {{ log('⚠️ No FKs found to drop', info=True) }}
{% else %}
     {% for row in fks_to_drop.rows %}
        {% set drop_FK_SQL = row[0] %}
        {{ log('Dropping FK: ' ~ drop_FK_SQL, info=True) }}
        {% do run_query(drop_FK_SQL) %}
    {% endfor %}
{% endif %}

{% endmacro  %}