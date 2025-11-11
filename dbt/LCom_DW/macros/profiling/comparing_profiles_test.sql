{% test comparing_profiles_test(
model, 
database_name, 
schema_name, 
table_name, 
profile_name_base, 
profile_name_compared, 
metrics=[dict(name='pct_nulls',threshold=10), dict(name='pct_uniqs',threshold=10),]
 ) 
%}




{% for m in metrics %}
select 
sfp.profile_column_id as base_profile_column_id,
sryp.profile_column_id as compared_profile_column_id,
sfp.profile_name as base_profile_name,
sryp.profile_name as compared_profile_name,
sfp.database_name,
sfp.schema_name,
sfp.table_name,
sfp.column_name,
sfp.data_type,
'{{ m.name }}' as metric_name,
sfp.{{ m.name }} base_value,
sryp.{{ m.name }} compared_value
from {{ model }}  sfp 
join {{ model }} sryp
on  sfp.database_name =sryp.database_name
and sfp.schema_name =sryp.schema_name
and sfp.table_name =sryp.table_name
and sfp.column_name =sryp.column_name
where 

{% if database_name %}
sfp.database_name = '{{ database_name | lower }}'
{% else %}
1=1
{% endif %}

{% if schema_name %}
and sfp.schema_name = '{{ schema_name | lower }}'
{% endif %}

{% if table_name %}
and sfp.table_name = '{{ table_name | lower }}'
{% endif %}

and sfp.profile_name = '{{ profile_name_base  }}'
and sryp.profile_name = '{{ profile_name_compared  }}'
and
(


{% if "pct" in m.name %}
  abs(sfp.{{ m.name }} - sryp.{{ m.name }})> {{ m.threshold }}
{% else %}
  abs(sfp.{{ m.name }} - sryp.{{ m.name }})/NULLIF(sfp.{{ m.name }}, 0) > {{ m.threshold }}
{% endif %}

)

{% if not loop.last %} union all {% endif %}
{% endfor %}


  
 
{% endtest %}