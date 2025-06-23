{{ config(
        
        materialized='incremental',
        unique_key='mon_year',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns',
        dist='even',
        sort='mon_year'
)
 }}

with dim_school_year as (select distinct SchoolYear, SchoolYear_StartDate, SchoolYear_Mon, mon_year, mon_lastday 
from {{ source("common","dim_calendar") }} 
where 

{% if var("processing_mon_year")=="Current" %}
  cal_date=trunc(GetDate())
{% else %}
  mon_year={{ var("processing_mon_year") }}
{% endif %}


)
,data_all as (
select distinct
dsy.SchoolYear, 
dsy.SchoolYear_StartDate, 
dsy.SchoolYear_Mon, 
dsy.mon_year, 
dsy.mon_lastday,
c.Product_Category,
coalesce(dseqlo.learning_object_id, dlslo.learning_object_id) as learning_object_id,
greatest(c.fromdate,dsy.SchoolYear_StartDate) fromdate,
least(c.todate,dsy.mon_lastday) todate
from {{ ref("dim_product_category")}} c
left outer join {{ ref("dim_lcom_sku_learning_object") }} dlslo 
on c.product_id=dlslo.sku_id 
and c.product_type='sku'
left outer join  {{ ref("dim_sequence_learning_object") }}  dseqlo 
on c.product_id=dseqlo .sequence_id 
and c.product_type='seq'
join dim_school_year dsy
on c.fromdate<=dsy.mon_lastday
and c.todate>dsy.SchoolYear_StartDate
)
,final_data as (
--data all    
select 
SchoolYear, 
SchoolYear_StartDate, 
SchoolYear_Mon, 
mon_year, 
mon_lastday,
Product_Category,
learning_object_id,
fromdate,
todate
from data_all
--
union all
--EasyTech without Common Sense Education Seq
select 
SchoolYear, 
SchoolYear_StartDate, 
SchoolYear_Mon, 
mon_year, 
mon_lastday,
'EasyTech without Common Sense Education' Product_Category,
learning_object_id,
SchoolYear_StartDate fromdate,
mon_lastday todate
from 
(
select distinct
dlslo.learning_object_id as learning_object_id
from {{ ref("dim_product_category")}} c
--
join {{ ref("dim_lcom_sku_learning_object") }} dlslo 
on c.product_id=dlslo.sku_id 
and c.Product_Category='EasyTech'
--
join dim_school_year dsy
on c.fromdate<=dsy.mon_lastday
and c.todate>dsy.SchoolYear_StartDate

except

select distinct
dseqlo.learning_object_id as learning_object_id
from {{ ref("dim_product_category")}} c
--
join {{ ref("dim_sequence_learning_object") }}  dseqlo 
on c.product_id=dseqlo.sequence_id 
and c.Product_Category='Common Sense Education'
--
join dim_school_year dsy
on c.fromdate<=dsy.mon_lastday
and c.todate>dsy.SchoolYear_StartDate
) data
join dim_school_year dsy
on 1=1
)
select
SchoolYear, 
SchoolYear_StartDate, 
SchoolYear_Mon, 
mon_year, 
mon_lastday,
Product_Category,
learning_object_id,
SchoolYear_StartDate fromdate,
mon_lastday todate
from final_data