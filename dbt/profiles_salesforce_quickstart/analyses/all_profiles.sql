

/*This is a union all of all tables profiles*/
{% set tables = list_of_main_models() %}
with data as (
{% for profile_table in tables|list %}


{% if  profile_table.endswith("_") %}
{% set original_table_name = profile_table[:-1] %}
{% else %}
{% set original_table_name = profile_table %}
{% endif %}


select 
'{{original_table_name}}' as table_name,
p.column_name,
p.row_count ,
p.data_type ,
p.not_null_proportion ,
p.distinct_proportion ,
p.distinct_count ,
p.is_unique
from {{ database }}.{{ target.schema }}.{{profile_table}} p




{% if not loop.last %} union all {% endif %}

{% endfor %}
)
, sfdc_metadata as
(


select 
lower(e.qualified_api_name) as sfdc_table_name,
e.Label as sfdc_table_label,
lower(f.qualified_api_name) as sfdc_column_name,
f.Label as sfdc_column_label,
f.is_calculated as sfdc_is_calculated,
f.data_type as sfdc_data_type,
f.length as sfdc_length,
f.service_data_type_id as sfdc_service_data_type,
f.is_field_history_tracked as sfdc_is_field_history_tracked,
f.is_nillable as sfdc_is_nillable,
f.description as sfdc_description,
m.table_name,
m.column_name 
from {{ source("fivetran_salesforce","entity_definition") }} e  
join {{ source("fivetran_salesforce","field_definition") }} f 
on e.durable_id = f.entity_definition_id
left outer join  {{ ref("mapping") }} m
on lower(e.qualified_api_name)=m.sfdc_table_name 
and lower(f.qualified_api_name)=m.sfdc_column_name
where m.table_name is not null

)
select 
data.* ,
m.sfdc_table_name,
m.sfdc_table_label,
m.sfdc_column_name,
m.sfdc_column_label,
m.sfdc_is_calculated,
m.sfdc_data_type,
m.sfdc_length,
m.sfdc_service_data_type,
m.sfdc_is_field_history_tracked,
m.sfdc_is_nillable,
m.sfdc_description
from data
left outer join sfdc_metadata m
on data.table_name=m.table_name 
and data.column_name=m.column_name