{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select 
grade_level_code,
grade_level_name,
primary_secondary,
school_level_el_ms_hi,
school_level_el_jr_sr,
sort_order
from content_delivery_usage.dbo.grade_level
union all
select 
'00' grade_level_code,
'{{ var("default_varchar") }}' grade_level_name,
'{{ var("default_varchar") }}' primary_secondary,
'{{ var("default_varchar") }}' school_level_el_ms_hi,
'{{ var("default_varchar") }}' school_level_el_jr_sr,
'{{ var("default_numeric") }}' sort_order