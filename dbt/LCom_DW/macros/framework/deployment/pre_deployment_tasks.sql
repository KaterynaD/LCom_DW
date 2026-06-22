{% macro pre_deployment_tasks() %}

{% if execute and flags.WHICH in ('run','run-operation', 'build') and var("deploy_flag", False) %}


 {{ log('Starting pre deployment tasks', info=True) }}

 {% set pre_deployment_sql %}

 {% set target_db = (target.database | string) %}
 {% if target_db | upper == 'QA' %}

   create table qa.revenue.dim_opportunity_line as select * from dw.revenue.dim_opportunity_line;
   create table qa.revenue.dim_opportunity_line_history as select * from dw.revenue.dim_opportunity_line_history;

 {% endif %}

alter table revenue.dim_opportunity_line_history add column additional_discount_amount NUMERIC(35,17) NOT NULL default 0;
alter table revenue.dim_opportunity_line_history add column additional_discount_rate NUMERIC(35,17) NOT NULL default 0;
alter table revenue.dim_opportunity_line_history add column additional_discount_type VARCHAR(20) NOT NULL default 'Unknown';
alter table revenue.dim_opportunity_line_history add column total_discount_rate NUMERIC(35,17) NOT NULL default 0;
alter table revenue.dim_opportunity_line_history add column total_discount_amount  NUMERIC(35,17) NOT NULL default 0;



update revenue.dim_opportunity_line_history
set
discount_applied = 'Not Used',
additional_discount_amount = da.additional_discount_amount,
additional_discount_rate = da.additional_discount_rate,
additional_discount_type = da.additional_discount_type,
total_discount_rate = da.total_discount_rate,
total_discount_amount = da.total_discount_amount
from revenue.dim_opportunity_line da
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