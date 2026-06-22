{% macro pre_deployment_tasks() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Starting pre deployment tasks', info=True) }}

 {% set pre_deployment_sql %}

 {% set target_db = (target.database | string) %}
 {% if target_db | upper == 'QA' %}

   create table qa.revenue.dim_opportunity_line_history as select * from dw.revenue.dim_opportunity_line_history;

 {% endif %}

alter table revenue.dim_opportunity_line_history add column additional_discount_amount NUMERIC(35,17) NOT NULL default 0;
alter table revenue.dim_opportunity_line_history add column additional_discount_rate NUMERIC(35,17) NOT NULL default 0;
alter table revenue.dim_opportunity_line_history add column additional_discount_type VARCHAR(20) NOT NULL default 'Unknown';
alter table revenue.dim_opportunity_line_history add column total_discount_rate NUMERIC(35,17) NOT NULL default 0;
alter table revenue.dim_opportunity_line_history add column total_discount_amount  NUMERIC(35,17) NOT NULL default 0;


create or replace view staging.stg_sbqq_quote_line as
with rawdata as (select
     sfdc_quote_line.id as id,
    sfdc_quote_line.sbqq_pricing_method_c as sbqq_pricing_method_c,
    sfdc_quote_line.sbqq_existing_c as sbqq_existing_c,
    sfdc_quote_line.sbqq_carryover_line_c as sbqq_carryover_line_c,
    sfdc_quote_line.sbqq_quantity_c as sbqq_quantity_c,
    sfdc_quote_line.sbqq_prior_quantity_c as sbqq_prior_quantity_c,
    sfdc_quote_line.sbqq_upgraded_quantity_c as sbqq_upgraded_quantity_c,
    sfdc_quote_line.sbqq_allow_asset_refund_c as sbqq_allow_asset_refund_c,
    sfdc_quote_line.sbqq_subscription_pricing_c as sbqq_subscription_pricing_c,
    sfdc_quote_line.sbqq_bundled_c as sbqq_bundled_c,
    sfdc_quote_line.sbqq_prorated_list_price_c as sbqq_prorated_list_price_c,
    sfdc_quote_line.sbqq_customer_price_c as sbqq_customer_price_c,
    sfdc_quote_line.sbqq_discount_schedule_type_c as sbqq_discount_schedule_type_c,
    sfdc_quote_line.sbqq_additional_discount_amount_c as sbqq_additional_discount_amount_c,
    sfdc_quote_line.sbqq_discount_c as sbqq_discount_c
			from rawdata.fivetran_salesforce.sbqq_quote_line_c as sfdc_quote_line
 )
,data as (
select
id
,CASE
WHEN sbqq_discount_schedule_type_c = 'Slab'
OR sbqq_pricing_method_c = 'Block'
THEN
CASE
WHEN (
NOT sbqq_existing_c
AND NOT sbqq_carryover_line_c
AND sbqq_quantity_c = 0
)
OR (
(sbqq_existing_c OR sbqq_carryover_line_c)
AND (
sbqq_quantity_c = sbqq_prior_quantity_c - sbqq_upgraded_quantity_c
OR (
NOT sbqq_allow_asset_refund_c
AND sbqq_subscription_pricing_c = ''
AND sbqq_quantity_c < sbqq_prior_quantity_c - sbqq_upgraded_quantity_c
)
)
)
THEN 0
ELSE 1
END
ELSE
CASE
WHEN NOT sbqq_existing_c
AND NOT sbqq_carryover_line_c
THEN sbqq_quantity_c
WHEN sbqq_quantity_c >= sbqq_prior_quantity_c - sbqq_upgraded_quantity_c
THEN
CASE
WHEN sbqq_subscription_pricing_c = 'Percent Of Total'
THEN sbqq_quantity_c
ELSE sbqq_quantity_c - sbqq_prior_quantity_c + sbqq_upgraded_quantity_c
END
ELSE
CASE
WHEN NOT sbqq_allow_asset_refund_c
AND sbqq_subscription_pricing_c = ''
THEN 0
ELSE sbqq_quantity_c - sbqq_prior_quantity_c + sbqq_upgraded_quantity_c
END
END
end as sbqq_effective_quantity_c,
/*--------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------ Total Discount (Amt) ----------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------*/
CASE
WHEN SBQQ_Bundled_c THEN 0
WHEN sbqq_discount_schedule_type_c = 'Slab'
AND NOT sbqq_existing_c
THEN
(sbqq_prorated_list_price_c * SBQQ_Quantity_c - sbqq_customer_price_c)
WHEN sbqq_discount_schedule_type_c = 'Slab'
AND sbqq_existing_c
THEN
(sbqq_prorated_list_price_c * (SBQQ_Quantity_c - sbqq_prior_quantity_c) - sbqq_customer_price_c)
ELSE
(sbqq_prorated_list_price_c - sbqq_customer_price_c) * sbqq_effective_quantity_c
end as SBQQ__TotalDiscountAmount_c,
/*--------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------ Total Discount (%) -----------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------------------------------------------------*/
CASE
WHEN sbqq_prorated_list_price_c = 0 THEN 0
WHEN sbqq_discount_schedule_type_c = 'Slab'
AND NOT sbqq_existing_c
THEN
CASE
WHEN sbqq_quantity_c = 0 THEN 0
ELSE
(
sbqq_prorated_list_price_c * sbqq_quantity_c
- sbqq_customer_price_c
)
/
NULLIF(
sbqq_quantity_c * sbqq_prorated_list_price_c,
0
)
END
WHEN sbqq_discount_schedule_type_c = 'Slab'
AND sbqq_existing_c
THEN
CASE
WHEN sbqq_quantity_c = sbqq_prior_quantity_c THEN 0
ELSE
(
sbqq_prorated_list_price_c
* (sbqq_quantity_c - sbqq_prior_quantity_c)
- sbqq_customer_price_c
)
/
NULLIF(
(sbqq_quantity_c - sbqq_prior_quantity_c)
* sbqq_prorated_list_price_c,
0
)
END
ELSE
(sbqq_prorated_list_price_c - sbqq_customer_price_c)
/ NULLIF(sbqq_prorated_list_price_c, 0)
END AS SBQQ__TotalDiscountRate_c,
sbqq_additional_discount_amount_c,
sbqq_discount_c
from rawdata
)
select
ol.id as opportunity_line_id,
case
    when ql.sbqq_additional_discount_amount_c is not null
    then ql.sbqq_additional_discount_amount_c
    when ql.sbqq_discount_c is not null
    then ol.list_price * ql.sbqq_discount_c / 100.0
	else 
	 0
end as additional_discount_amount,
case
    when ql.sbqq_discount_c is not null
    then ql.sbqq_discount_c / 100.0
    when ql.sbqq_additional_discount_amount_c is not null
         and nullif(ol.list_price, 0) is not null
    then ql.sbqq_additional_discount_amount_c / nullif(ol.list_price, 0)
	else 
	 0	
end as additional_discount_rate,
case
    when ql.sbqq_additional_discount_amount_c is not null
    then 'AMOUNT'
    when ql.sbqq_discount_c is not null
    then 'PERCENT'
	else 
	 'Unknown'
end as additional_discount_type,
/*--------------------------------------------------------------------------------------------------------------------------------------*/
isnull(ql.sbqq__totaldiscountrate_c, 0) as total_discount_rate ,
isnull(ql.sbqq__totaldiscountamount_c, 0) as total_discount_amount
from rawdata.fivetran_salesforce_quickstart.opportunity_line_item ol
join data ql
on ol.sbqq_quote_line_c = ql.id
with no schema binding;

update revenue.dim_opportunity_line_history
set
discount_applied = 'Not Used',
additional_discount_amount = da.additional_discount_amount,
additional_discount_rate = da.additional_discount_rate,
additional_discount_type = da.additional_discount_type,
total_discount_rate = da.total_discount_rate,
total_discount_amount = da.total_discount_amount
from staging.stg_sbqq_quote_line da
where da.opportunity_line_id = revenue.dim_opportunity_line_history.opportunity_line_id;

update revenue.dim_opportunity_line_history								
set scd_hash =md5(coalesce(cast(sfdc_product_id as varchar ), '')
         || '|' || coalesce(cast(opportunity_id as varchar ), '')
         || '|' || coalesce(cast(pricebook_entry_id as varchar ), '')
         || '|' || coalesce(cast(pricebook_id as varchar ), '')
         || '|' || coalesce(cast(netsuite_id as varchar ), '')
         || '|' || coalesce(cast(netsuite_sku as varchar ), '')
         || '|' || coalesce(cast(sbqq_quote_line as varchar ), '')
         || '|' || coalesce(cast(name as varchar ), '')
         || '|' || coalesce(cast(quantity as varchar ), '')
         || '|' || coalesce(cast(total_price as varchar ), '')
         || '|' || coalesce(cast(unit_price as varchar ), '')
         || '|' || coalesce(cast(weighted_total_price as varchar ), '')
         || '|' || coalesce(cast(combine_new_biz_arr as varchar ), '')
         || '|' || coalesce(cast(combine_renewal_arrs as varchar ), '')
         || '|' || coalesce(cast(combine_upsell_arrs as varchar ), '')
         || '|' || coalesce(cast(discount_applied as varchar ), '')
         || '|' || coalesce(cast(list_price as varchar ), '')
         || '|' || coalesce(cast(net_price_display as varchar ), '')
         || '|' || coalesce(cast(net_unit_price as varchar ), '')
         || '|' || coalesce(cast(opportunity_product_arr as varchar ), '')
         || '|' || coalesce(cast(pro_rate_adj_term as varchar ), '')
         || '|' || coalesce(cast(record_type as varchar ), '')
         || '|' || coalesce(cast(business_type_opty_product as varchar ), '')
         || '|' || coalesce(cast(class as varchar ), '')
         || '|' || coalesce(cast(additional_discount_amount as varchar ), '')
         || '|' || coalesce(cast(additional_discount_rate as varchar ), '')
         || '|' || coalesce(cast(additional_discount_type as varchar ), '')
         || '|' || coalesce(cast(total_discount_rate as varchar ), '')
         || '|' || coalesce(cast(total_discount_amount as varchar ), '')
        );								


 {% endset %}

    {% if pre_deployment_sql | trim %}
        {% do run_query(pre_deployment_sql) %}
        {{ log('Finished pre deployment tasks', info=True) }}
    {% else %}
        {{ log('No pre deployment tasks to execute', info=True) }}
    {% endif %}


{% endif %}
 
 {% endmacro %}