{{
    config(

        materialized='table',        
        dist='opportunity_id' 
        
        )
}}

with base_data as 
/*3 ARR types need identical data except start,end,activate and deactivate dates*/
(
    select 'True' ARR_Type, * from {{ ref("stg_arr_base") }}
    union all
    select 'Preliminary' ARR_Type, * from {{ ref("stg_arr_base") }}
    union all
    select 'Backdated' ARR_Type, * from {{ ref("stg_arr_base") }}
)
/*extended rawdata to all what's needed for ARR and excluding what's not needed - step 1*/
, ARR_Data_base_1 as (
select 
distinct
d.ARR_Type,
fo.opportunity_id,
fo.stage_name,
fo.account_id,
a.sfdc_billing_state_code state_code,
fo.invoiced_date ,
fo.close_date,
fo.start_date ,
fo.end_date,
fo.renewal_opportunity_id,
fro.stage_name renewal_stage_name,
fro.invoiced_date renewal_invoiced_date,
fro.close_date renewal_close_date,
fro.start_date renewal_start_date,
fro.end_date renewal_end_date,
d.sfdc_product_id ,
d.bucket ,
d.total_price ,
d.parent_total_price 
from base_data d
join {{ ref("fact_opportunity") }} fo
on fo.opportunity_id=d.opportunity_id
left outer join (select fro.* from {{ ref("fact_opportunity") }} fro join {{ ref("stg_valid_opportunities") }} ooi on fro.opportunity_id = ooi.opportunity_id) as fro
on fro.opportunity_id=fo.renewal_opportunity_id
join {{ ref("dim_sfdc_product") }} dsp
on d.sfdc_product_id = dsp.sfdc_product_id
join {{ ref("dim_account") }} a
on a.account_id = fo.account_id
/*assuming renewal is for the same account as a parent. It is not true, but at least they should be in the same state*/
where dsp.sfdc_product_name not ilike '%wire transfer%'
)
/*valid for ARR parent opportunities info*/
,parents_info as (
select
pfo.renewal_opportunity_id opportunity_id,
max(pfo.end_date) max_parent_end_date
from {{ ref("fact_opportunity") }} pfo
join ARR_Data_base_1 ooi
on pfo.opportunity_id = ooi.opportunity_id
where pfo.renewal_opportunity_id!='Unknown'
group by pfo.renewal_opportunity_id
)
/*extending ARR_Data_base_1 to valid parent info*/
,ARR_Data_base_2 as 
(select
distinct
ARR_Type,
case when parents_info.max_parent_end_date is not null then true else false end HasParent,
fb.opportunity_id,
stage_name,
account_id,
state_code,
invoiced_date ,
close_date,
start_date,
end_date,
isnull(renewal_opportunity_id,'{{ var("default_varchar") }}') as renewal_opportunity_id,
isnull(renewal_stage_name,'{{ var("default_varchar") }}') as renewal_stage_name,
isnull(renewal_invoiced_date,'{{ var("default_date") }}') as renewal_invoiced_date,
isnull(renewal_close_date,'{{ var("default_date") }}') as renewal_close_date,
isnull(renewal_start_date,'{{ var("default_date") }}') as renewal_start_date,
isnull(renewal_end_date,'{{ var("default_date") }}') as renewal_end_date,
sfdc_product_id ,
bucket ,
isnull(total_price ,'{{ var("default_numeric") }}') as total_price,
isnull(parent_total_price ,'{{ var("default_numeric") }}') as parent_total_price,
isnull(parents_info.max_parent_end_date, '{{ var("default_date") }}')  as max_parent_end_date
from ARR_Data_base_1 fb
left outer join parents_info 
on fb.opportunity_id = parents_info.opportunity_id
)
select
ARR_Type::varchar(20),
HasParent::boolean,
opportunity_id::varchar(300),
stage_name::varchar(780),
account_id::varchar(300),
state_code:: varchar(30),
invoiced_date::date ,
close_date::date,
start_date::date,
end_date::date,
renewal_opportunity_id::varchar(300),
isnull(renewal_stage_name,'Unknown')::varchar(780) as renewal_stage_name,
isnull(renewal_invoiced_date,'1900-01-01'::date) as renewal_invoiced_date,
isnull(renewal_close_date,'1900-01-01'::date) as renewal_close_date,
isnull(renewal_start_date,'1900-01-01'::date) as renewal_start_date,
isnull(renewal_end_date,'1900-01-01'::date) as renewal_end_date,
sfdc_product_id::varchar(300) ,
bucket::varchar(100) ,
total_price::numeric(38,10) ,
parent_total_price ::numeric(38,10),
max_parent_end_date::date,
'{{ var("loaddate") }}'::timestamp as loaddate
from ARR_Data_base_2
