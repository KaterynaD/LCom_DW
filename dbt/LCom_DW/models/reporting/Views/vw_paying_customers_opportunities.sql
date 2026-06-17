{{ config(materialized='view',
   bind=False,
   post_hook = [
                    '{{ validate_view() }}'
                   ]
)
 }}

select
pah.account_id as sfdc_ultimate_parent_id,
pah.sfdc_name as sfdc_ultimate_parent_name,
fo.sfdc_account_id ,
ah.sfdc_name,
fo.opportunity_number ,
fo.name,
fo.opportunity_id,
fo.Stage_Name,
case when fo.created_date != '1900-01-01'::date then trunc(fo.created_date) end created_date,
case when fo.close_date != '1900-01-01'::date then fo.close_date end close_date,
case when fo.invoiced_date != '1900-01-01'::date then fo.invoiced_date end invoiced_date ,
case when fo.start_date != '1900-01-01'::date then fo.start_date end start_date,
case when fo.end_date != '1900-01-01'::date then fo.end_date end end_date,
fo.opp_record_type,
replace(fo.loss_reason,'Unknown','') loss_reason,
replace(fo.loss_notes,'Unknown','') loss_notes,
greatest(fo.true_arr,fo.arr, fo.arr_upsell, arr_renewal, arr_new_business) amount
from {{ ref("fact_opportunity") }} fo --??change/add for opportunity history
join {{ ref("dim_account") }} ah
on fo.account_id=ah.account_id 
join {{ ref("dim_account") }} pah
on ah.sfdc_ultimate_parent_id=pah.sfdc_account_id 
