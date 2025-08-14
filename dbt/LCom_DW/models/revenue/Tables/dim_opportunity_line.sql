{{
    config(
        materialized='table',        
        sort='sfdc_product_id', 
        dist='opportunity_id'                                                 
         )
}}


  

with data as (
select
isnull(ol.combine_new_biz_arr_c, {{ var("default_numeric") }}) as combine_new_biz_arr	,
isnull(ol.combine_renewal_arrs_c, {{ var("default_numeric") }}) as combine_renewal_arrs	,
isnull(ol.combine_upsell_arrs_c, {{ var("default_numeric") }}) as combine_upsell_arrs	,
isnull(ol.created_date	 AT TIME ZONE 'PST'	,	 '{{ var("default_date") }}'  ) as created_date	,
isnull(ol.description,  '{{ var("default_varchar") }}'  ) as description	,
isnull(ol.discount, {{ var("default_numeric") }}) as discount	,
isnull(ol.discount_applied_c,  '{{ var("default_varchar") }}'  ) as discount_applied	,
isnull(ol.easy_tech_arr_c, {{ var("default_numeric") }}) as easy_tech_arr	,
isnull(ol.end_date_c,  '{{ var("default_date") }}'  ) as end_date	,
isnull(ol.gold_service_on_quote_c, {{ var("default_numeric") }}) as gold_service_on_quote	,
isnull(ol.id,  '{{ var("default_varchar") }}'  ) as opportunity_line_id	,
isnull(ol.is_active_opp_product_c,   {{ var("default_boolean") }}) as is_active_opp_product	,
isnull(ol.last_modified_date	 AT TIME ZONE 'PST'	,	 '{{ var("default_date") }}'  ) as last_modified_date	,
isnull(ol.learning_sbxid_c,  '{{ var("default_varchar") }}'  ) as learning_sbxid	,
isnull(ol.list_price, {{ var("default_numeric") }}) as list_price	,
isnull(ol.name,  '{{ var("default_varchar") }}'  ) as name	,
isnull(ol.net_price_display_c, {{ var("default_numeric") }}) as net_price_display	,
isnull(ol.net_unit_price_c, {{ var("default_numeric") }}) as net_unit_price	,
isnull(ol.netsuite_id_c,  '{{ var("default_varchar") }}'  ) as netsuite_id	,
isnull(ol.netsuite_sku_c,  '{{ var("default_varchar") }}'  ) as netsuite_sku	,
isnull(ol.no_of_buildings_c, {{ var("default_numeric") }}) as no_of_buildings	,
isnull(ol.no_of_licenses_c, {{ var("default_numeric") }}) as no_of_licenses	,
isnull(ol.opp_probability_c, {{ var("default_numeric") }}) as opp_probability	,
isnull(ol.opportunity_id,  '{{ var("default_varchar") }}'  ) as opportunity_id	,
isnull(ol.opportunity_product_arr_c, {{ var("default_numeric") }}) as opportunity_product_arr	,
isnull(ol.opportunity_product_line_id_c,  '{{ var("default_varchar") }}'  ) as opportunity_product_line_id	,
isnull(ol.pricebook_entry_id,  '{{ var("default_varchar") }}'  ) as pricebook_entry_id	,
isnull(ol.pricebook_id_c,  '{{ var("default_varchar") }}'  ) as pricebook_id	,
isnull(ol.pro_rate_adj_term_c, {{ var("default_numeric") }}) as pro_rate_adj_term	,
isnull(ol.product_2_id,  '{{ var("default_varchar") }}'  ) as sfdc_product_id	,
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
isnull(ol.class_c,  '{{ var("default_varchar") }}'  ) as class
from
{{ source('fivetran_salesforce_quickstart', 'opportunity_line_item') }} as ol
join {{ ref('fact_opportunity') }} as o
on ol.opportunity_id = o.opportunity_id
join {{ ref("dim_sfdc_product") }} as p
on ol.product_2_id = p.sfdc_product_id
where ol.is_deleted=False
)
select
     opportunity_line_id::VARCHAR(50) 
	,sfdc_product_id::VARCHAR(50)
	,opportunity_id::VARCHAR(300) 
	,start_date::DATE
	,end_date::DATE
	,subscription_term::NUMERIC(35,17)
	,quantity::INTEGER
	,total_price::NUMERIC(35,17)
	,unit_price::NUMERIC(35,17)
	,weighted_total_price::NUMERIC(35,17)
	,combine_new_biz_arr::NUMERIC(36,17)
	,combine_renewal_arrs::NUMERIC(37,17)
	,combine_upsell_arrs::NUMERIC(37,17)
	,name::VARCHAR(1200)
	,description::VARCHAR(1200)
	,netsuite_id::VARCHAR(50)
	,netsuite_sku::VARCHAR(90)
	,no_of_buildings::INTEGER
	,no_of_licenses::INTEGER
	,discount::NUMERIC(35,17)
	,discount_applied::VARCHAR(25)
	,easy_tech_arr::NUMERIC(35,17)
	,gold_service_on_quote::INTEGER
	,is_active_opp_product::BOOLEAN
	,learning_sbxid::VARCHAR(55)
	,list_price::NUMERIC(35,17)
	,net_price_display::NUMERIC(35,17)
	,net_unit_price::NUMERIC(35,17)
	,opp_probability::NUMERIC(35,17)
	,opportunity_product_arr::NUMERIC(35,17)
	,pricebook_entry_id::VARCHAR(18)
	,pricebook_id::VARCHAR(18)
	,pro_rate_adj_term::NUMERIC(35,17)
	,record_type::VARCHAR(765)
	,sfdc_product_code::VARCHAR(765)
	,sfdc_product_description::VARCHAR(4000)
	,sbqq_quote_line::VARCHAR(50)
	,business_type_opty_product::VARCHAR(765)	
    ,class::VARCHAR(765)
	,created_date::TIMESTAMP WITHOUT TIME ZONE
	,last_modified_date::TIMESTAMP WITHOUT TIME ZONE
    ,'{{ var("loaddate") }}'::timestamp as loaddate
from data