{{
    config(
        materialized='table',        
        sort='sfdc_product_id', 
        dist='opportunity_id',
		sql_header = 'SET enable_numeric_rounding TO ON;'                    
         )
}}


  

with rawdata as (select
     {{ safe_select_list_from_profiles(
        table_name='opportunity_line_item',
        alias='sfdc_opp_line_item',
        used_columns=[ 
			'combine_new_biz_arr_c','combine_renewal_arrs_c','combine_upsell_arrs_c',
'created_date',
'end_date_c','id',
'last_modified_date','list_price','name',
'net_price_display_c','net_unit_price_c','netsuite_sku_c',
'opp_probability_c','opportunity_id',
'opportunity_product_arr_c','opportunity_product_line_id_c','pricebook_entry_id',
'pricebook_id_c','pro_rate_adj_term_c','product_2_id','product_code',
'product_description_c','quantity','record_type_c','sbqq_quote_line_c',
'start_date_c','subscription_term_c','total_price','unit_price',
'weighted_total_price_c','business_type_opty_product_c','class_c','is_deleted'
			],
        profile_src=('profiles','vw_sfdc_schema_audit'),
        base_profile='base',
        current_profile='current'
    ) }}
			from {{ source('fivetran_salesforce_quickstart', 'opportunity_line_item') }} as sfdc_opp_line_item)
,data as (
select
isnull(ol.combine_new_biz_arr_c, {{ var("default_numeric") }}) as combine_new_biz_arr	,
isnull(ol.combine_renewal_arrs_c, {{ var("default_numeric") }}) as combine_renewal_arrs	,
isnull(ol.combine_upsell_arrs_c, {{ var("default_numeric") }}) as combine_upsell_arrs	,
isnull(ol.created_date	 AT TIME ZONE 'America/Los_Angeles'	,	 '{{ var("default_date") }}'  ) as created_date	,
/*--------------------------------------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------------------  Discounts  ----------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------*/
case
    when ql.sbqq_additional_discount_amount_c is not null
    then ql.sbqq_additional_discount_amount_c
    when ql.sbqq_discount_c is not null
    then ol.list_price * ql.sbqq_discount_c / 100.0
	else 
	 {{ var("default_numeric") }}
end as additional_discount_amount,
case
    when ql.sbqq_discount_c is not null
    then ql.sbqq_discount_c / 100.0
    when ql.sbqq_additional_discount_amount_c is not null
         and nullif(ol.list_price, 0) is not null
    then ql.sbqq_additional_discount_amount_c / nullif(ol.list_price, 0)
	else 
	 {{ var("default_numeric") }}	
end as additional_discount_rate,
case
    when ql.sbqq_additional_discount_amount_c is not null
    then 'AMOUNT'
    when ql.sbqq_discount_c is not null
    then 'PERCENT'
	else 
	 '{{ var("default_varchar") }}'
end as additional_discount_type,
/*--------------------------------------------------------------------------------------------------------------------------------------*/
isnull(ql.sbqq__totaldiscountrate_c, {{ var("default_numeric") }}) as total_discount_rate ,
isnull(ql.sbqq__totaldiscountamount_c, {{ var("default_numeric") }}) as total_discount_amount ,
/*--------------------------------------------------------------------------------------------------------------------------------------*/
isnull(ol.end_date_c,  '{{ var("default_date") }}'  ) as end_date	,
isnull(ol.id,  '{{ var("default_ID") }}'  ) as opportunity_line_id	,
isnull(ol.last_modified_date	 AT TIME ZONE 'America/Los_Angeles'	,	 '{{ var("default_date") }}'  ) as last_modified_date	,
isnull(ol.list_price, {{ var("default_numeric") }}) as list_price	,
isnull(ol.name,  '{{ var("default_varchar") }}'  ) as name	,
isnull(ol.net_price_display_c, {{ var("default_numeric") }}) as net_price_display	,
isnull(ol.net_unit_price_c, {{ var("default_numeric") }}) as net_unit_price	,
isnull(ol.netsuite_sku_c,  '{{ var("default_varchar") }}'  ) as netsuite_sku	,
isnull(ol.opp_probability_c, {{ var("default_numeric") }}) as opp_probability	,
isnull(ol.opportunity_id,  '{{ var("default_ID") }}'  ) as opportunity_id	,
isnull(ol.opportunity_product_arr_c, {{ var("default_numeric") }}) as opportunity_product_arr	,
isnull(ol.opportunity_product_line_id_c,  '{{ var("default_varchar") }}'  ) as opportunity_product_line_id	,
isnull(ol.pricebook_entry_id,  '{{ var("default_varchar") }}'  ) as pricebook_entry_id	,
isnull(ol.pricebook_id_c,  '{{ var("default_varchar") }}'  ) as pricebook_id	,
isnull(ol.pro_rate_adj_term_c, {{ var("default_numeric") }}) as pro_rate_adj_term	,
isnull(ol.product_2_id,  '{{ var("default_ID") }}'  ) as sfdc_product_id	,
isnull(ol.product_code,  '{{ var("default_varchar") }}'  ) as sfdc_product_code	,
isnull(ol.product_description_c,  '{{ var("default_varchar") }}'  ) as sfdc_product_description	,
isnull(ol.quantity, {{ var("default_numeric") }}) as quantity	,
isnull(ol.record_type_c, '{{ var("default_varchar") }}') as record_type	,
isnull(ol.sbqq_quote_line_c,  '{{ var("default_varchar") }}'  ) as sbqq_quote_line	,
isnull(ol.start_date_c,  '{{ var("default_date") }}'  ) as start_date	,
isnull(ol.subscription_term_c, {{ var("default_numeric") }}) as subscription_term	,
isnull(ol.total_price, {{ var("default_numeric") }}) as total_price	,
isnull(ol.unit_price, {{ var("default_numeric") }}) as unit_price	,
isnull(ol.weighted_total_price_c, {{ var("default_numeric") }}) as weighted_total_price	,
isnull(ol.business_type_opty_product_c,  '{{ var("default_varchar") }}'  ) as business_type_opty_product	,
coalesce(ol.class_c,  ol.business_type_opty_product_c, '{{ var("default_varchar") }}'  ) as class
from
rawdata as ol
join {{ ref('fact_opportunity') }} as o
on ol.opportunity_id = o.opportunity_id
join {{ ref("dim_sfdc_product") }} as p
on ol.product_2_id = p.sfdc_product_id
left outer join {{ ref('stg_sbqq_quote_line') }} ql
on ol.sbqq_quote_line_c = ql.id
where ol.is_deleted=False
)
,final_data as (
select
     opportunity_line_id
	,sfdc_product_id
	,opportunity_id
	,start_date
	,end_date
	,subscription_term
	,quantity
	,total_price
	,unit_price
	,weighted_total_price
	,combine_new_biz_arr
	,combine_renewal_arrs
	,combine_upsell_arrs
	,name
	,netsuite_sku
	,additional_discount_amount
	,additional_discount_rate
	,additional_discount_type
	,total_discount_rate
	,total_discount_amount
	,list_price
	,net_price_display
	,net_unit_price
	,opp_probability
	,opportunity_product_arr
	,pricebook_entry_id
	,pricebook_id
	,pro_rate_adj_term
	,record_type
	,sfdc_product_code
	,sfdc_product_description
	,sbqq_quote_line
	,business_type_opty_product
    ,class
	,created_date
	,last_modified_date
from data
union all
select
'{{ var("default_ID") }}' as opportunity_line_id	,
'{{ var("default_ID") }}' as sfdc_product_id	,
'{{ var("default_ID") }}' as opportunity_id	,
'{{ var("default_date") }}' as start_date	,
'{{ var("default_date") }}' as end_date	,
{{ var("default_numeric") }} as subscription_term	,
{{ var("default_numeric") }} as quantity	,
{{ var("default_numeric") }} as total_price	,
{{ var("default_numeric") }} as unit_price	,
{{ var("default_numeric") }} as weighted_total_price	,
{{ var("default_numeric") }} as combine_new_biz_arr	,
{{ var("default_numeric") }} as combine_renewal_arrs	,
{{ var("default_numeric") }} as combine_upsell_arrs	,
'{{ var("default_varchar") }}' as name	,
'{{ var("default_varchar") }}' as netsuite_sku	,
{{ var("default_numeric") }} as additional_discount_amount	,
{{ var("default_numeric") }} as additional_discount_rate	,
'{{ var("default_varchar") }}' as additional_discount_type	,
{{ var("default_numeric") }} as total_discount_rate	,
{{ var("default_numeric") }} as total_discount_amount	,
{{ var("default_numeric") }} as list_price	,
{{ var("default_numeric") }} as net_price_display	,
{{ var("default_numeric") }} as net_unit_price	,
{{ var("default_numeric") }} as opp_probability	,
{{ var("default_numeric") }} as opportunity_product_arr	,
'{{ var("default_varchar") }}' as pricebook_entry_id	,
'{{ var("default_varchar") }}' as pricebook_id	,
{{ var("default_numeric") }} as pro_rate_adj_term	,
'{{ var("default_varchar") }}' as record_type	,
'{{ var("default_varchar") }}' as sfdc_product_code	,
'{{ var("default_varchar") }}' as sfdc_product_description	,
'{{ var("default_varchar") }}' as sbqq_quote_line	,
'{{ var("default_varchar") }}' as business_type_opty_product	,
'{{ var("default_varchar") }}' as class	,
 '{{ var("default_date") }}' as created_date	,
'{{ var("default_date") }}' as last_modified_date
)
select
     opportunity_line_id::VARCHAR(300) as opportunity_line_id
	,sfdc_product_id::VARCHAR(300) as sfdc_product_id
	,opportunity_id::VARCHAR(300) as opportunity_id
	,start_date::DATE as start_date
	,end_date::DATE as end_date
	,round(subscription_term::numeric(38,10),2)::numeric(16,2) as subscription_term
	,quantity::INTEGER as quantity
	,round(total_price::numeric(38,10),2)::numeric(16,2) as total_price
	,round(unit_price::numeric(38,10),2)::numeric(16,2) as unit_price
	,round(weighted_total_price::numeric(38,10),2)::numeric(16,2) as weighted_total_price
	,round(combine_new_biz_arr::numeric(38,10),2)::numeric(16,2) as combine_new_biz_arr
	,round(combine_renewal_arrs::numeric(38,10),2)::numeric(16,2) as combine_renewal_arrs
	,round(combine_upsell_arrs::numeric(38,10),2)::numeric(16,2) as combine_upsell_arrs
	,name::VARCHAR(1200) as name
	,netsuite_sku::VARCHAR(90) as netsuite_sku
	,round(additional_discount_amount::numeric(38,10),2)::numeric(16,2) as additional_discount_amount
	,round(additional_discount_rate::numeric(38,10),4)::numeric(16,4) as additional_discount_rate
	,additional_discount_type::VARCHAR(20) as additional_discount_type
	,round(total_discount_rate::numeric(38,10),4)::numeric(16,4) as total_discount_rate
	,round(total_discount_amount::numeric(38,10),2)::numeric(16,2) as total_discount_amount
	,round(list_price::numeric(38,10),2)::numeric(16,2) as list_price
	,round(net_price_display::numeric(38,10),2)::numeric(16,2) as net_price_display
	,round(net_unit_price::numeric(38,10),2)::numeric(16,2) as net_unit_price
	,round(opp_probability::numeric(38,10),2)::numeric(16,2) as opp_probability
	,round(opportunity_product_arr::numeric(38,10),2)::numeric(16,2) as opportunity_product_arr
	,pricebook_entry_id::VARCHAR(18) as pricebook_entry_id
	,pricebook_id::VARCHAR(18) as pricebook_id
	,round(pro_rate_adj_term::numeric(38,10),2)::numeric(16,2) as pro_rate_adj_term
	,record_type::VARCHAR(765) as record_type
	,sfdc_product_code::VARCHAR(765) as sfdc_product_code
	,sfdc_product_description::VARCHAR(4000) as sfdc_product_description
	,sbqq_quote_line::VARCHAR(50) as sbqq_quote_line
	,business_type_opty_product::VARCHAR(765) as business_type_opty_product
    ,class::VARCHAR(765) as class
	,created_date::TIMESTAMP WITHOUT TIME ZONE as created_date
	,last_modified_date::TIMESTAMP WITHOUT TIME ZONE as last_modified_date
    ,'{{ var("loaddate") }}'::timestamp as loaddate
from final_data